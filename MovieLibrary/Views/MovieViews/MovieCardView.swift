//
//  MovieCardView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 7/4/2025.
//

import SwiftUI

/**
 Reusable movie card component displaying poster and title.
 
 Simple card view used in various lists and selection UIs. Shows movie poster
 with title overlaid at the bottom. Size adapts based on device size class.
 
 ## Features
 - Square movie poster with rounded corners
 - Title overlay at bottom
 - Size class adaptation
 - Padding for spacing in grids/lists
 */
struct MovieCardView: View {
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.imageManager) var imageManager

    @Bindable var movie: Movie
    
    var body: some View {
        VStack {
            imageManager.loadSmart(filename: movie.photoURL!)
                .resizable()
                .scaledToFill()
                .frame(width: SizeClass.imageSize(for: sizeClass), height: SizeClass.imageSize(for: sizeClass))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(alignment: .bottomLeading) {
                    Text("\(movie.name)")
                        .font(.headline)
                        .lineLimit(1)
                        .clipShape(Capsule())
                        .offset(x: 5, y: 30)
                }
                
        }
        .padding(.bottom, 40)
    }
}
