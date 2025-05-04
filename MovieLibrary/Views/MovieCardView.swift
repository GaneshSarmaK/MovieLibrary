//
//  MovieCardView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 7/4/2025.
//

import SwiftUI

struct MovieCardView: View {
    
    @Environment(\.horizontalSizeClass) var sizeClass

    let movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    var body: some View {
        VStack {
            ImageManager.loadImageSmart(filename: movie.photoURL!)
                .resizable()
                .scaledToFill()
                .frame(width: SizeClass.imageSize(for: sizeClass), height: SizeClass.imageSize(for: sizeClass))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(alignment: .bottomLeading) {
                    Text("\(movie.name)")
                        .font(.headline)
                        .clipShape(Capsule())
                        .offset(x: 5, y: 30)
                }
                
        }
        .padding(.bottom, 40)
    }
}
