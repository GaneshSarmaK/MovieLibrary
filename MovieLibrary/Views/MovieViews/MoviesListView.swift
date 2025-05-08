//
//  MoviesListView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 8/4/2025.
//

import SwiftUI

/**
 Horizontal scrollable list of movies associated with a specific genre.
 
 Displays movie cards with posters and names in a horizontal layout.
 Supports tap navigation to movie details and context menu for delete/update actions.
 
 ## Features
 - Horizontal scrolling list
 - Tap to view movie details
 - Long-press context menu with Delete and Update options
 - Dynamic filtering of movies belonging to the genre
 
 ## Size Class Adaptation
 Uses `SizeClass` for responsive image sizing.
 */
struct MoviesListView: View {
    
    @Environment(\.appLogger) var logger
    @Environment(NavigationRouter.self) var router
    @Environment(ActorViewModel.self) var actorViewModel
    @Environment(MovieViewModel.self) var movieViewModel
    @Environment(GenreViewModel.self) var genreViewModel
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.imageManager) var imageManager
        
    var genre: Genre
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 15) {
                ForEach(genre.movies) { movie in
                    card(movie: movie)
                        .onTapGesture {
                            router.path.append(.movieView(movieViewModel.movies.first(where: {$0.id == movie.id }) ?? movie))
                            logger.debugLog("Navigating to movie: \(movie.id)")
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                Task {
                                    await movieViewModel.deleteMovie(movie)
                                    genre.movies.removeAll { $0 == movie }
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .glassEffect()
                            
                            Button(role: .cancel) {
                                router.path.append(.movieCreationView(movieViewModel.movies.first(where: {$0.id == movie.id }) ?? movie))
                            } label: {
                                Label("Update", systemImage: "arrow.clockwise")
                            }
                            .glassEffect()
                        }
                }
            }
        }
        .contentMargins(.horizontal, 10, for: .scrollContent)
    }
    
    /**
     Creates movie card with poster and name.
     
     - Parameter movie: The movie to display
     
     Displays movie poster with name overlaid at bottom.
     */
    @ViewBuilder private func card(movie: Movie) -> some View {
        VStack(alignment: .leading) {
            imageManager.loadSmart(filename: movie.photoURL!)
                .resizable()
                .scaledToFill()
                .frame(width: SizeClass.smallImageSize(for: sizeClass), height: SizeClass.smallImageSize(for: sizeClass))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                
            Text("\(movie.name)")
                .font(.footnote)
                .lineLimit(1)
        }
        .frame(width: SizeClass.smallImageSize(for: sizeClass))
    }
}

