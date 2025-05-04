//
//  MovieListView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 6/4/2025.
//

import SwiftUI
import SwiftData

struct MovieGridView: View {
    
    @Environment(GlobalSearchViewModel.self) var globalSearchViewModel
    @Environment(MovieViewModel.self) var movieViewModel
    @Environment(NavigationRouter.self) var router
    @Environment(\.horizontalSizeClass) var sizeClass

    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: SizeClass.columns(for: sizeClass), spacing: 15) {
                ForEach(globalSearchViewModel.movies) { movie in
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
        
    }
    
    @ViewBuilder private func card(movie: Movie) -> some View {
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
                        .offset(y: 30)
                }
                
        }
        .padding(.bottom, 40)
    }
}
