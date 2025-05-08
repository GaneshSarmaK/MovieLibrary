//
//  ImageCacher.swift
//  MovieLibrary
//
//  Created by NVR4GET on 6/12/2025.
//

import UIKit
import Foundation

// MARK: - Image Cacher

/// Image caching utility using NSCache for automatic memory management
final class ImageCacher {
    // MARK: - Singleton
    
    /// Shared singleton instance
    /// Cache for tab snapshot images with automatic memory management
    /// Limits to ~50MB (assuming ~1MB per snapshot) and ~100 visible tabs
    static let shared: ImageCacher = {
        let cache = ImageCacher()
        cache.maxCacheCount = 100 // Maximum number of snapshots in cache
        cache.maxCacheCost = 500 * 1024 * 1024 // 500MB limit
        return cache
    }()
    
    // MARK: - Properties
    /// UIImage cache using NSCache for automatic memory management
    private let imageCache = NSCache<NSString, UIImage>()
    
    /// Maximum cache count (0 means no limit)
    var maxCacheCount: Int {
        get { imageCache.countLimit }
        set { imageCache.countLimit = newValue }
    }
    
    private var totalImageCount: Int = 0
    private var totalImageCost: Int = 0
    
    /// Maximum total cost in bytes (0 means no limit)
    var maxCacheCost: Int {
        get { imageCache.totalCostLimit }
        set { imageCache.totalCostLimit = newValue }
    }
}

// MARK: - UIImage Cache Operations

extension ImageCacher {
    /// Retrieves cached UIImage for a given key
    /// - Parameter key: Cache key (typically file path or unique identifier)
    /// - Returns: Cached UIImage, or nil if not found
    func getCachedImage(forKey key: String) -> UIImage? {
        return imageCache.object(forKey: key as NSString)
    }
    
    /// Stores UIImage in cache
    /// - Parameters:
    ///   - image: UIImage to cache
    ///   - key: Cache key (typically file path or unique identifier)
    ///   - cost: Optional cost in bytes (defaults to estimated image size)
    func cacheImage(_ image: UIImage, forKey key: String, cost: Int? = nil) {
        let cacheCost = cost ?? Int(image.size.width * image.size.height * 4) // Estimate: width * height * 4 bytes (RGBA)
        
        if (imageCache.object(forKey: key as NSString) == nil) {
            totalImageCount += 1
            totalImageCost += cacheCost
        }
        imageCache.setObject(image, forKey: key as NSString)
    }
    
    /// Removes a specific UIImage from cache
    /// - Parameter key: Cache key to remove
    func removeImageFromCache(forKey key: String) {
        imageCache.removeObject(forKey: key as NSString)
    }
}


