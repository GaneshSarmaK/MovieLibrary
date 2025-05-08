//
//  Utils.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import UIKit

/**
 Recursively adds colored borders to a view and all its subviews for layout debugging.
 
 This function assigns a random pastel color to each view's border, making it easy to
 visualize the view hierarchy during development.
 
 - Parameter view: The root view to add borders to (recursively includes all subviews)
 */
func addDebugBorders(to view: UIView) {
    view.layer.borderWidth = 2
    view.layer.borderColor = UIColor(
        red: .random(in: 0.6...1),
        green: .random(in: 0.6...1),
        blue: .random(in: 0.6...1),
        alpha: 1
    ).cgColor

    for subview in view.subviews {
        addDebugBorders(to: subview)
    }
}

/**
 Enables layout debugging by adding colored borders to all windows in the current scene.
 
 Call this function from the main thread to visualize the entire view hierarchy.
 Useful for debugging layout issues and understanding view boundaries.
 
 - Note: Must be called from `@MainActor` context
 */
@MainActor
func enableLayoutDebugBorders() {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

    for window in windowScene.windows {
        addDebugBorders(to: window)
    }
}


/// Extension providing a random color generator for debugging and UI purposes
extension Color {
    /**
     Generates a random mid-tone color.
     
     RGB values are constrained to 0.2-0.8 range to avoid very dark or very bright colors.
     
     - Returns: A SwiftUI Color with random RGB components
     */
    static var random: Color {
        return Color(
            red: .random(in: 0.2...0.8),
            green: .random(in: 0.2...0.8),
            blue: .random(in: 0.2...0.8)
        )
    }
}


/// Extension to convert Data to SwiftUI Image
extension Data {
    /**
     Converts image data to a SwiftUI Image.
     
     - Returns: A SwiftUI Image if the data represents a valid image, or `nil` otherwise
     */
    var toImage: Image? {
        guard let uiImage = UIImage(data: self) else { return nil }
        return Image(uiImage: uiImage)
    }
}

/**
 A utility struct providing adaptive sizing values for different device size classes.
 
 `SizeClass` helps create responsive layouts that adapt between iPhone and iPad.
 All methods return larger values for `.regular` size class (iPad) and smaller values
 for `.compact` size class (iPhone).
 */
struct SizeClass {
    
    /// Access to the horizontal size class environment value
    @Environment(\.horizontalSizeClass) var sizeClass
    
    /**
     Returns appropriate rotation effect value based on size class.
     
     - Parameter sizeClass: The horizontal size class
     - Returns: 25 for regular (iPad), 10 for compact (iPhone)
     */
    static func rotationEffectValue(for sizeClass: UserInterfaceSizeClass?) -> Double {
        return (sizeClass == .regular) ? 25 : 10
    }
    
    /**
     Returns appropriate offset value based on size class.
     
     - Parameter sizeClass: The horizontal size class
     - Returns: 100 for regular (iPad), 300 for compact (iPhone)
     */
    static func offsetValue(for sizeClass: UserInterfaceSizeClass?) -> Double {
        return (sizeClass == .regular) ? 100 : 300
    }
    
    /**
     Returns large image size based on size class.
     
     - Parameter sizeClass: The horizontal size class
     - Returns: 600 for regular (iPad), 300 for compact (iPhone)
     */
    static func largeImageSize(for sizeClass: UserInterfaceSizeClass?) -> Double {
        return (sizeClass == .regular) ? 600 : 300
    }
    
    /**
     Returns small image size based on size class.
     
     - Parameter sizeClass: The horizontal size class
     - Returns: 150 for regular (iPad), 80 for compact (iPhone)
     */
    static func smallImageSize(for sizeClass: UserInterfaceSizeClass?) -> Double {
        return (sizeClass == .regular) ? 150 : 80
    }
    
    /**
     Returns favorite icon size based on size class.
     
     - Parameter sizeClass: The horizontal size class
     - Returns: 30 for regular (iPad), 20 for compact (iPhone)
     */
    static func favIconSize(for sizeClass: UserInterfaceSizeClass?) -> Double {
        return (sizeClass == .regular) ? 30 : 20
    }
    
    /**
     Returns standard image size based on size class.
     
     - Parameter sizeClass: The horizontal size class
     - Returns: 300 for regular (iPad), 175 for compact (iPhone)
     */
    static func imageSize(for sizeClass: UserInterfaceSizeClass?) -> Double {
        return (sizeClass == .regular) ? 300.0 : 175.0
    }
    
    /**
     Returns actor image size based on size class.
     
     - Parameter sizeClass: The horizontal size class
     - Returns: 250 for regular (iPad), 100 for compact (iPhone)
     */
    static func actorImageSize(for sizeClass: UserInterfaceSizeClass?) -> Double {
        return (sizeClass == .regular) ? 250 : 100
    }
    
    /**
     Returns grid columns configuration based on size class.
     
     - Parameter sizeClass: The horizontal size class
     - Returns: 3-column grid for regular (iPad), 2-column grid for compact (iPhone)
     */
    static func columns(for sizeClass: UserInterfaceSizeClass?) -> [GridItem] {
        let count = (sizeClass == .regular) ? 3 : 2
        return Array(repeating: GridItem(.flexible(), spacing: 10), count: count)
    }
    
}

/// View modifier extension for creating stacked card effects
extension View {
    /**
     Applies a stacked offset to create a card deck effect.
     
     Each item in a collection can call this with its position to create
     a cascading/stacked visual effect.
     
     - Parameters:
        - position: The index/position of this item in the stack
        - total: The total number of items in the stack
     
     - Returns: A view with offset applied based on position
     */
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(position) * 10
        return self.offset(CGSize(width: offset, height: offset))
    }
}

/// View modifier extension for debug visualization
extension View {
    /**
     Overlays a debug border with a random color for layout debugging.
     
     This is useful during development to visualize view boundaries and debug layout issues.
     
     - Parameter width: The width of the border stroke (default: 0.5)
     
     - Returns: The view with a colored debug border overlay
     */
    func debugBorder(width: CGFloat = 0.5) -> some View {
        let color = Color(
            red: .random(in: 0.2...1),
            green: .random(in: 0.2...1),
            blue: .random(in: 0.2...1)
        )

        return self.overlay(
            Rectangle()
                .stroke(color, lineWidth: width)
        )
    }
}

