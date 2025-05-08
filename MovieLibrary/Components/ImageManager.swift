//
//  ImageManager.swift
//  MovieLibrary
//
//  Created by NVR4GET on 6/12/2025.
//

import SwiftUI

/// Environment key for accessing AppLogger in SwiftUI views
private struct ImageManagerKey: EnvironmentKey {
    static let defaultValue: ImageManager = .shared
}

extension EnvironmentValues {
    /// Access to the app logger through environment values
    var imageManager: ImageManager {
        get { self[ImageManagerKey.self] }
        set { self[ImageManagerKey.self] = newValue }
    }
}

/**
 A centralized image management system with caching, compression, and smart loading.
 
 `ImageManager` handles all image operations including saving, loading, deleting, and caching.
 It uses `ImageCacher` for automatic memory management and provides smart logic to
 distinguish between bundled assets and user-uploaded images.
 
 ## Features
 - **Compression**: Automatically compresses images on save (0.7 quality)
 - **Caching**: Uses `ImageCacher` for fast retrieval of frequently accessed images
 - **Smart Loading**: Detects source (bundle vs documents) based on filename
 - **Memory Management**: Automatic cache eviction via NSCache
 
 ## Image Source Detection
 Filenames are analyzed to determine source:
 - UUID format (contains "-") → Documents directory
 - Asset names → App bundle
 - Not found → System icon placeholder
 
 ## Usage
 ```swift
 // Save image
 if let filename = ImageManager.shared.save(imageData) {
     movie.photoURL = filename
 }
 
 // Load image (automatically cached)
 let image = ImageManager.shared.loadSmart(filename: movie.photoURL)
 ```
 */
final class ImageManager {
    
    // MARK: - Singleton
    
    /// Shared singleton instance
    static let shared: ImageManager = ImageManager()
    
    // MARK: - Properties
    
    /// Image cacher for memory optimization
    private let cacher = ImageCacher.shared
    
    /// Compression quality for saved images (0.0 - 1.0)
    private let compressionQuality: CGFloat = 0.3
    
    /// Documents directory URL
    private let documentsDirectory: URL = {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }()
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Image Processing
    
    /**
     Crops an image to circular shape.
     
     - Parameters:
       - image: The image to crop
       - rect: The rectangular area to crop
     
     - Returns: Circular cropped image, or nil if cropping fails
     */
    func crop(_ image: UIImage, rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        let bezierPath = UIBezierPath(
            ovalIn: CGRect(origin: .zero, size: rect.size)
        ).cgPath
        context?.addPath(bezierPath)
        context?.clip()
        image
            .draw(
                in: CGRect(
                    origin: CGPoint(x: -rect.origin.x, y: -rect.origin.y),
                    size: image.size
                )
            )
        let cropped = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return cropped
    }
    
    /**
     Crops an image to 16:9 aspect ratio (1.777:1).
     
     This method crops from the center to maintain the best composition.
     If the image is wider than 16:9, it crops the height (top/bottom).
     If the image is taller than 16:9, it crops the width (left/right).
     
     - Parameter image: The image to crop
     
     - Returns: Image cropped to 16:9 aspect ratio, or original if cropping fails
     
     ## Examples
     - Portrait photo (3:4) → Crops sides to 16:9
     - Landscape photo (4:3) → Crops top/bottom to 16:9
     - Already 16:9 → Returns unchanged
     */
    private func cropTo16x10(_ image: UIImage) -> UIImage {
        let targetAspectRatio: CGFloat = 16.0 / 10.0
        let currentAspectRatio = image.size.width / image.size.height
        
        // Already 16:9 (within tolerance)
        if abs(currentAspectRatio - targetAspectRatio) < 0.01 {
            return image
        }
        
        var cropRect: CGRect
        
        if currentAspectRatio > targetAspectRatio {
            // Image is wider than 16:9 → Crop width (sides)
            let newWidth = image.size.height * targetAspectRatio
            let xOffset = (image.size.width - newWidth) / 2
            cropRect = CGRect(x: xOffset, y: 0, width: newWidth, height: image.size.height)
        } else {
            // Image is taller than 16:9 → Crop height (top/bottom)
            let newHeight = image.size.width / targetAspectRatio
            let yOffset = (image.size.height - newHeight) / 2
            cropRect = CGRect(x: 0, y: yOffset, width: image.size.width, height: newHeight)
        }
        
        // Perform the crop
        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
            AppLogger.dataStore.warning("Failed to crop image to 16:9, using original")
            return image
        }
        
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
    
    // MARK: - Save Operations
    
    /**
     Saves image data to documents directory with 16:9 crop, compression, and caching.
     
     Images are automatically:
     1. Cropped to 16:9 aspect ratio (center crop)
     2. Compressed to reduce disk space (30% quality)
     3. Cached in memory for fast access
     
     - Parameter data: Raw image data to save (typically from PhotosPicker)
     
     - Returns: Generated filename (UUID format) on success, or `nil` on failure
     
     ## Example
     ```swift
     if let imageData = try await photoPicker.loadTransferable(type: Data.self),
        let filename = ImageManager.shared.save(imageData) {
         movie.photoURL = filename
     }
     ```
     
     ## Processing Pipeline
     1. Convert Data → UIImage
     2. Crop to 16:9 aspect ratio
     3. Compress to JPEG (30% quality)
     4. Save to documents directory
     5. Cache in memory
     */
    func save(_ data: Data?) -> String? {
        guard let data = data,
              let uiImage = UIImage(data: data) else {
            AppLogger.dataStore.error("Invalid image data provided to save")
            return nil
        }
        
        // 1. Crop to 16:9 aspect ratio
        let croppedImage = cropTo16x10(uiImage)
        
        // 2. Compress image to reduce file size
        guard let compressedData = croppedImage.jpegData(compressionQuality: compressionQuality) else {
            AppLogger.dataStore.error("Failed to compress image data")
            return nil
        }
        
        // Generate unique filename
        let filename = "\(UUID().uuidString).jpg"
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        do {
            // 3. Save compressed image to disk
            try compressedData.write(to: fileURL)
            
            // 4. Cache the cropped image for immediate reuse
            cacher.cacheImage(croppedImage, forKey: filename)
            
            // 5. Log success with compression stats
            let originalSize = data.count
            let finalSize = compressedData.count
            let originalAspect = uiImage.size.width / uiImage.size.height
            let croppedAspect = croppedImage.size.width / croppedImage.size.height
            
            AppLogger.dataStore.info("""
                Image saved: \(filename)
                - Aspect ratio: \(String(format: "%.2f", originalAspect)):1 → 16:9 (cropped) (cropped aspect: \(croppedAspect))
                - Size: \(originalSize) → \(finalSize) bytes (\(Int((1.0 - Double(finalSize)/Double(originalSize)) * 100))% reduction)
                - Dimensions: \(Int(uiImage.size.width))×\(Int(uiImage.size.height)) → \(Int(croppedImage.size.width))×\(Int(croppedImage.size.height))
                """)
            return filename
        } catch {
            AppLogger.dataStore.error("Failed to write image to disk: \(error)")
            return nil
        }
    }
    
    // MARK: - Load Operations
    
    /**
     Loads image intelligently with automatic caching.
     
     This method determines the image source and loads accordingly:
     1. Checks memory cache first (fastest)
     2. For UUID filenames: loads from documents and caches
     3. For asset names: loads from bundle
     4. Returns placeholder if not found
     
     - Parameter filename: Filename or asset name to load
     
     - Returns: SwiftUI Image from cache, disk, or bundle
     
     ## Performance
     - Cache hit: ~0.1ms
     - Cache miss (disk): ~10ms
     - Subsequent loads: instant (cached)
     */
    func loadSmart(filename: String) -> Image {
        // Check if it's a user-uploaded image (UUID format)
        if filename.contains("-") {
            return loadFromDocuments(filename: filename)
        }
        // Check if it's a bundled asset
        else if UIImage(named: filename) != nil {
            return Image(filename)
        }
        // Fallback to placeholder
        else {
            return Image(systemName: "person.circle")
        }
    }
    
    /**
     Loads image from documents directory with caching.
     
     - Parameter filename: Filename in documents directory
     
     - Returns: SwiftUI Image if found, or error icon placeholder
     
     ## Caching Strategy
     1. Check cache first
     2. If not cached, load from disk
     3. Cache the loaded image
     4. Return image
     */
    func loadFromDocuments(filename: String) -> Image {
        // 1. Check cache first (fastest path)
        if let cachedImage = cacher.getCachedImage(forKey: filename) {
            return Image(uiImage: cachedImage)
        }
        
        // 2. Load from disk
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        if let uiImage = UIImage(contentsOfFile: fileURL.path) {
            // 3. Cache for next time
            cacher.cacheImage(uiImage, forKey: filename)
            return Image(uiImage: uiImage)
        } else {
            AppLogger.dataStore.warning("Failed to load image: \(filename)")
            return Image(systemName: "exclamationmark.triangle")
        }
    }
    
    /**
     Loads image data intelligently from cache or disk.
     
     Used for editing operations where raw data is needed (e.g., pre-filling edit forms).
     
     - Parameter filename: Filename or asset name
     
     - Returns: Image data in JPEG format, or empty Data if not found
     */
    func loadDataSmart(filename: String) -> Data {
        // UUID format → Documents directory
        if filename.contains("-") {
            return loadDataFromDocuments(filename: filename)
        }
        // Asset name → Bundle
        else {
            guard let image = UIImage(named: filename),
                  let data = image.jpegData(compressionQuality: 1.0) else {
                return Data()
            }
            return data
        }
    }
    
    /**
     Loads raw image data from documents directory.
     
     - Parameter filename: Filename to load
     
     - Returns: Image data if found, empty Data otherwise
     */
    func loadDataFromDocuments(filename: String) -> Data {
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        if let data = try? Data(contentsOf: fileURL) {
            return data
        } else {
            return Data()
        }
    }
    
    // MARK: - Asset Migration
    
    /**
     Migrates all asset images to file storage with 16:9 crop and compression.
     
     This function processes asset images through the standard save pipeline
     (16:9 crop + compression) and returns a mapping for updating seed data.
     
     - Parameter assetNames: Array of asset image names to migrate
     
     - Returns: Dictionary mapping original asset names to new file URLs
     
     ## Usage in Seed Data
     ```swift
     func saveDummyMovies() {
         let imageMapping = ImageManager.shared.migrateAssetImagesToStorage(
             assetNames: ["movie1", "movie2", "actor1"]
         )
         
         // Update dummy data
         for movie in dummyMovies {
             if let newURL = imageMapping[movie.photoURL] {
                 movie.photoURL = newURL
             }
         }
     }
     ```
     
     ## Example Output
     ```
     [
         "movie1": "A1B2C3D4-E5F6-7890-ABCD-EF1234567890.jpg",
         "movie2": "B2C3D4E5-F6G7-8901-BCDE-FG2345678901.jpg",
         "actor1": "C3D4E5F6-G7H8-9012-CDEF-GH3456789012.jpg"
     ]
     ```
     
     ## Processing Steps
     For each asset:
     1. Load from bundle
     2. Crop to 16:9
     3. Compress to 30% quality
     4. Save to documents with UUID filename
     5. Cache in memory
     */
    func migrateAssetImagesToStorage(assetNames: [String]) -> [String: String] {
        var mapping: [String: String] = [:]
        
        AppLogger.dataStore.info("Starting asset migration for \(assetNames.count) images")
        
        for assetName in assetNames {
            // Load image from assets
            guard let assetImage = UIImage(named: assetName) else {
                AppLogger.dataStore.warning("Asset not found: \(assetName)")
                continue
            }
            
            // Convert to JPEG data (high quality for processing)
            guard let assetData = assetImage.jpegData(compressionQuality: 1.0) else {
                AppLogger.dataStore.error("Failed to convert asset to data: \(assetName)")
                continue
            }
            
            // Process through standard save pipeline (crops to 16:9 and compresses)
            if let newFilename = save(assetData) {
                mapping[assetName] = newFilename
                AppLogger.dataStore.info("✓ Migrated: \(assetName) → \(newFilename)")
            } else {
                AppLogger.dataStore.error("Failed to save asset: \(assetName)")
            }
        }
        
        AppLogger.dataStore.info("Asset migration complete: \(mapping.count)/\(assetNames.count) successful")
        
        return mapping
    }
    
    /**
     Convenience method to migrate assets from a collection of decodable objects.
     
     Automatically extracts unique photo URLs from dummy data and migrates them.
     
     - Parameter dummyMovies: Array of DummyMovie objects
     
     - Returns: Dictionary mapping asset names to file URLs
     
     ## Usage
     ```swift
     let mapping = ImageManager.shared.migrateAssetsFromDummies(dummyMovies)
     ```
     */
    func migrateAssetsFromDummies(_ dummyMovies: [DummyMovie]) -> [String: String] {
        // Extract all unique image names from movies and actors
        var assetNames = Set<String>()
        
        for movie in dummyMovies {
            // Add movie poster
            if !movie.photoURL.isEmpty && !movie.photoURL.contains("-") {
                assetNames.insert(movie.photoURL)
            }
            
            // Add actor photos
            for actor in movie.movieActors {
                if !actor.photoURL.isEmpty && !actor.photoURL.contains("-") {
                    assetNames.insert(actor.photoURL)
                }
            }
        }
        
        AppLogger.dataStore.info("Detected \(assetNames.count) unique asset images to migrate")
        
        return migrateAssetImagesToStorage(assetNames: Array(assetNames))
    }
    
    // MARK: - Delete Operations
    
    /**
     Deletes image from both disk and cache.
     
     Only deletes user-uploaded images (UUID format). Bundled assets are ignored
     to prevent errors.
     
     - Parameter filename: Filename to delete
     
     ## Example
     ```swift
     if let photoURL = movie.photoURL {
         ImageManager.shared.delete(photoURL)
     }
     ```
     */
    func delete(_ filename: String) {
        // Only delete user-uploaded images (UUID format)
        guard filename.contains("-") else {
            return
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(filename)
        
        // Remove from cache
        cacher.removeImageFromCache(forKey: filename)
        
        // Remove from disk
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                AppLogger.dataStore.info("Deleted image: \(filename)")
            } catch {
                AppLogger.dataStore.error("Failed to delete image: \(error.localizedDescription)")
            }
        } else {
            AppLogger.dataStore.warning("File does not exist: \(fileURL.path())")
        }
    }
}

// MARK: - Legacy Static API (Deprecated)

//extension ImageManager {
//    /**
//     Legacy static methods for backward compatibility.
//     These methods delegate to the shared instance.
//     
//     - Note: Prefer using `ImageManager.shared` directly for new code.
//     */
//    
//    @available(*, deprecated, message: "Use ImageManager.shared.save() instead")
//    static func saveImageToDocuments(data: Data?) -> String? {
//        return shared.save(data)
//    }
//    
//    @available(*, deprecated, message: "Use ImageManager.shared.delete() instead")
//    static func deleteImageFromDocuments(filename: String) {
//        shared.delete(filename)
//    }
//    
//    @available(*, deprecated, message: "Use ImageManager.shared.loadSmart() instead")
//    static func loadImageSmart(filename: String) -> Image {
//        return shared.loadSmart(filename: filename)
//    }
//    
//    @available(*, deprecated, message: "Use ImageManager.shared.loadFromDocuments() instead")
//    static func loadImageFromDocuments(filename: String) -> Image {
//        return shared.loadFromDocuments(filename: filename)
//    }
//    
//    @available(*, deprecated, message: "Use ImageManager.shared.loadDataSmart() instead")
//    static func loadImageDataSmart(filename: String) -> Data {
//        return shared.loadDataSmart(filename: filename)
//    }
//    
//    @available(*, deprecated, message: "Use ImageManager.shared.loadDataFromDocuments() instead")
//    static func loadImageasDataFromDocuments(filename: String) -> Data {
//        return shared.loadDataFromDocuments(filename: filename)
//    }
//}
