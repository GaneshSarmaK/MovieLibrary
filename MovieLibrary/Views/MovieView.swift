//
//  MovieView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 7/4/2025.
//

import SwiftUI
import SwiftData

struct MovieView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(NavigationRouter.self) var router
    
    @State private var movieViewModel: MovieViewModel = MovieViewModel()
    @State private var genreViewModel: GenreViewModel = GenreViewModel()
    @State private var actorViewModel = ActorViewModel()
    
    var movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    var body: some View {
        
        ZStack {
            
//            ImageManager.loadImageFromDocuments(filename: movie.photoURL!)
//                        .resizable()
//                        .scaledToFill()
//                        .ignoresSafeArea()
//                        .blur(radius: 75)
//        
            
            VStack (spacing: 12) {
                ImageManager.loadImageSmart(filename: movie.photoURL!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: SizeClass.largeImageSize(for: sizeClass), height: SizeClass.largeImageSize(for: sizeClass))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.gray.opacity(0.5), lineWidth: 2)
                    }
                
                titleAndIsFav()
                
                yearAndRating()

                genres()
                    .frame(height: 60)
                    .background(.gray)
                    

                Text(movie.summary)
                    .font(.caption2)
                    .lineLimit(4)
                    .frame(width: SizeClass.largeImageSize(for: sizeClass))
                
                
                movieActors()
                
                
            }
        }
        
  
    }
    
    @ViewBuilder private func titleAndIsFav() -> some View {
        ZStack {
            Text(movie.name)
                .font(.title)
                .foregroundStyle(.primary)
                .padding(10)
            
            HStack {
                Spacer()
                
                Image(systemName: movie.isFavourited ? "heart.fill" : "heart")
                    .resizable()
                    .frame(width: SizeClass.favIconSize(for: sizeClass), height: SizeClass.favIconSize(for: sizeClass))
                    .foregroundColor(movie.isFavourited ? .pink : .yellow)
                    .padding(8)
                    .contentTransition(.symbolEffect(.replace))
                    .onTapGesture {
                        Task{
                            await movieViewModel.toggleFavourite(movie)
                        }
                    }
            }
        }
    }
    
    @ViewBuilder private func yearAndRating() -> some View {
        HStack {
            Spacer ()
            Text("Year: \(String(movie.releaseYear))")
            
            Spacer()
            
            HStack {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= movie.rating ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            Task {
                                await movieViewModel.updateRating(movie, index)
                            }
                        }
                    
                }
            }
            Spacer()
        }
    }
    
    @ViewBuilder private func genres() -> some View {
        Text("\(movie.genres.count)")
    }
    
    @ViewBuilder private func movieActors() -> some View {
        Text("\(movie.movieActors.count)")
        
    }
}

