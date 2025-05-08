//
//  GenreSectionView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 8/4/2025.
//


import SwiftUI

/**
 Displays all genres with their associated movies on the landing page.
 
 Iterates through all genres and displays each as a section with a header and
 horizontal list of movies. Refreshes genre data when view appears.
 
 ## Features
 - Genre name headers
 - Horizontal movie lists per genre (via MoviesListView)
 - Dividers between sections
 - Auto-refresh on appear
 */
struct GenreSectionView: View {
    
    @Environment(GenreViewModel.self) var genreViewModel
    @Environment(MovieViewModel.self) var movieViewModel
        
    var body: some View {
        
        ForEach(genreViewModel.genres) { genre in
            Divider()
            
            HStack {
                Text("\(genre.name)")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal, 10)
            
            MoviesListView(genre: genre)
        }
        .onAppear() {
            Task {
                await genreViewModel.fetchAll()
            }
        }
        
    }
}
