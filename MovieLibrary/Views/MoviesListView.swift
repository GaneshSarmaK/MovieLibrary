//
//  MoviesListView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 8/4/2025.
//

import SwiftUI

struct MoviesListView: View {
    
    @Environment(NavigationRouter.self) var router
    @Environment(MovieViewModel.self) var movieViewModel
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var movies: [Movie]
    
    init(movies: [Movie]) {
        self.movies = movies
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 15) {
                ForEach(movies) { movie in
                    card(movie: movie)
                        .onTapGesture {
                            router.path.append(.movieView(movie))
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                Task {
                                    await movieViewModel.deleteMovie(movie)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button(role: .cancel) {
                                router.path.append(.movieCreationView(movie))
                            } label: {
                                Label("Update", systemImage: "arrow.clockwise")
                            }
                        }
                }
            }
        }
        .contentMargins(.horizontal, 10, for: .scrollContent)
    }
    
    @ViewBuilder private func card(movie: Movie) -> some View {
        VStack(alignment: .leading) {
            ImageManager.loadImageSmart(filename: movie.photoURL!)
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

