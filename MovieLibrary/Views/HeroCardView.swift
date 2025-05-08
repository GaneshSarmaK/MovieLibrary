//
//  HeroCardView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 6/12/2025.
//

import SwiftUI

/**
 Card view for displaying a single movie in the hero carousel.
 
 Shows movie poster with title overlaid at bottom using thin material background.
 Aspect ratio is set to fill to maintain consistent card sizing in carousel.
 */
struct HeroCardView: View {
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.imageManager) var imageManager
    
    let movie: Movie
    
    var body: some View {
        imageManager.loadSmart(filename: movie.photoURL!)
            .resizable()
            .scaledToFill()
//            .frame(width: SizeClass.imageSize(for: sizeClass), height: SizeClass.imageSize(for: sizeClass))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(alignment: .bottomLeading) {
                Text("\(movie.name)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
                    .background(.thinMaterial)
            }
    }
}
