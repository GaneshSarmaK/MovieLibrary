//
//  MovieGridView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 6/4/2025.
//

import SwiftUI
import SwiftData

/**
 Vertical grid displaying movies from search results.
 
 Shows movie cards with posters and titles. Supports tap navigation to movie details
 and context menu for delete/update actions. Used in SearchView.
 
 ## Features
 - Adaptive column layout (2-3 columns based on device size)
 - Tap to view movie details
 - Context menu (Delete, Update)
 - Refreshes global search after deletion
 */
struct MovieGridView: View {
    
    @Environment(GlobalSearchViewModel.self) var globalSearchViewModel
    @Environment(MovieViewModel.self) var movieViewModel
    @Environment(NavigationRouter.self) var router
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.imageManager) var imageManager
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: SizeClass.columns(for: sizeClass), spacing: 15) {
                
                ForEach(globalSearchViewModel.movies) { movie in
                    card(movie: movie)
                        .onTapGesture {
                            router.path.append(.movieView(movieViewModel.movies.first(where: {$0.id == movie.id }) ?? movie))
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                Task {
                                    await movieViewModel.deleteMovie(movie)
                                    await globalSearchViewModel.fetchAll()
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .glassEffect()
                            
                            Button(role: .cancel) {
                                AppLogger.shared.info("\(movie.photoURL)")
                                router.path.append(.movieCreationView(movieViewModel.movies.first(where: {$0.id == movie.id }) ?? movie))
                            } label: {
                                Label("Update", systemImage: "arrow.clockwise")
                            }
                            .glassEffect()
                        }
                }
            }
        }
        
    }
    
    /**
     Creates movie card with poster and name overlay.
     
     - Parameter movie: The movie to display
     
     Name is positioned at bottom with offset for spacing in grid.
     */
    @ViewBuilder private func card(movie: Movie) -> some View {
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
                        .offset(y: 30)
                }
                
        }
        .padding(.bottom, 40)
    }
}
