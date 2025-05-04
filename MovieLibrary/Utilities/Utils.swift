//
//  Utils.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0.2...0.8),
            green: .random(in: 0.2...0.8),
            blue: .random(in: 0.2...0.8)
        )
    }
}

struct ImageManager {
    
    static func saveImageToDocuments(data: Data?) -> String? {
        guard let data = data else { return nil }
        let filename = "\(UUID().uuidString).jpg"
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = directory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
            print(fileURL.path())
            return filename
        } catch {
            print("Failed to write image data: \(error)")
            return nil
        }
    }
    
    static func deleteImageFromDocuments(filename: String) {
        if !filename.contains("-") {
            return
        }
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = directory.appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Deleted image: \(filename)")
            } catch {
                print("Failed to delete image: \(error.localizedDescription)")
            }
        } else {
            print("File does not exist at path: \(fileURL.path())")
        }
    }
    
    static func loadImageSmart(filename: String) -> Image {
        if filename.contains("-") {
            return loadImageFromDocuments(filename: filename)
        } else if UIImage(named: filename) != nil {
            return Image(filename)
        } else {
            return Image(systemName: "person.circle")
        }
    }
    
    static func loadImageFromDocuments(filename: String) -> Image {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = directory.appendingPathComponent(filename)
        
        if let uiImage = UIImage(contentsOfFile: fileURL.path) {
            return Image(uiImage: uiImage)
        } else {
            print(" Failed to load image at: \(fileURL.path())")
            return Image(systemName: "exclamationmark.triangle")
        }
    }
    
    static func loadImageDataSmart(filename: String) -> Data {
        
        // If it has an extension, assume it's from Documents
        if filename.contains("-") {
            return loadImageasDataFromDocuments(filename: filename)
        } else {
            guard let image = UIImage(named: filename),
                  let data = image.jpegData(compressionQuality: 1.0) else {
                return Data()
            }
            return data
        }
    }
    
    static func loadImageasDataFromDocuments(filename: String) -> Data {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = directory.appendingPathComponent(filename)
        
        if let data = try? Data(contentsOf: fileURL) {
            return data
        } else {
            return Data()
        }
    }
}

extension Data {
    var toImage: Image? {
        guard let uiImage = UIImage(data: self) else { return nil }
        return Image(uiImage: uiImage)
    }
}

@Observable
final class NavigationRouter {
    var path: [NavigationDestinations] = []
}

struct SizeClass {
    
    @Environment(\.horizontalSizeClass) var sizeClass
    
    static func rotationEffectValue(for sizeClass: UserInterfaceSizeClass?) -> Double {
        return (sizeClass == .regular) ? 25 : 10
    }
    
    static func offsetValue(for sizeClass: UserInterfaceSizeClass?) -> Double {
        return (sizeClass == .regular) ? 100 : 300
    }
    
    static func largeImageSize(for sizeClass: UserInterfaceSizeClass?) -> Double {
        return (sizeClass == .regular) ? 600 : 300
    }
    
    static func smallImageSize(for sizeClass: UserInterfaceSizeClass?) -> Double {
        return (sizeClass == .regular) ? 150 : 80
    }
    
    static func favIconSize(for sizeClass: UserInterfaceSizeClass?) -> Double {
        return (sizeClass == .regular) ? 30 : 20
    }
    
    static func imageSize(for sizeClass: UserInterfaceSizeClass?) -> Double {
        return (sizeClass == .regular) ? 300.0 : 175.0
    }
    
    static func actorImageSize(for sizeClass: UserInterfaceSizeClass?) -> Double {
        return (sizeClass == .regular) ? 250 : 100
    }
    
    static func columns(for sizeClass: UserInterfaceSizeClass?) -> [GridItem] {
        let count = (sizeClass == .regular) ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 10), count: count)
    }
    
}

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(position) * 10
        return self.offset(CGSize(width: offset, height: offset))
    }
}
