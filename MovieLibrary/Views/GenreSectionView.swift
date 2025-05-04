//
//  GenreSectionView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 8/4/2025.
//


import SwiftUI

struct GenreSectionView: View {
    
    let genre: Genre
    
    var body: some View {
        HStack {
            Text("\(genre.name)")
                .font(.headline)
            Spacer()
        }
        .padding(.horizontal, 10)
        
        MoviesListView(movies: genre.movies)
    }
}
