//
//  GenreCreationView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 7/4/2025.
//

import SwiftUI
import SwiftData

struct GenreCreationView: View {
    
    @Environment(MovieViewModel.self) var movieViewModel
    @Environment(GenreViewModel.self) var genreViewModel
    @Environment(NavigationRouter.self) var router
    
    @State private var genreName: String = ""
    @State private var genreSummary: String = ""
    @State private var selectedMovies: Set<String> = []
    
    var genre: Genre?
    
    var body: some View {
        
        VStack(spacing: 15) {
            
                titleInput()
                summaryInput()
            if genre != nil {
                    movieSelection()
                }

            Spacer()
            
            Button(action: {
                if let genre = genre {
                    updateGenre(genre)
                } else {
                    addGenre()
                }
                router.path.removeLast()
            }, label: {
                Text(genre == nil ? "Add new Genre" : "Update Genre")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            })
            .disabled(genreName.isEmpty || genreSummary.isEmpty )
            
        }
        .onAppear {
            if let genre = genre {
                genreName = genre.name
                genreSummary = genre.summary
                selectedMovies = Set(genre.movies.map { $0.id })

            }
        }
        
    }
    
    @ViewBuilder private func titleInput() -> some View {
        Text("Genre Name: ")
            .padding(.bottom, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        TextField("Enter Genre name", text: $genreName)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder private func summaryInput() -> some View {
        Text("Genre summary: ")
            .padding(.bottom, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        TextField("Enter Genre summary", text: $genreSummary)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder private func movieSelection() -> some View {
        Text("Select Movies")
            .padding(.bottom, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: 15) {
                ForEach(movieViewModel.movies) { movie in
                    let isSelected = selectedMovies.contains(movie.id)

                    MovieCardView(movie: movie)
                        .onTapGesture {
                            toggleSelection(movie.id)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? Color.green : Color.clear, lineWidth: 5)
                        )
                }
                
            }
        }
    }
    
    private func toggleSelection(_ id: String) {
        if selectedMovies.contains(id) {
            selectedMovies.remove(id)
        } else {
            selectedMovies.insert(id)
        }
    }
    
    private func addGenre() {
        Task {
            let movies: [Movie] = movieViewModel.movies.filter { movie in selectedMovies.contains { $0 == movie.id } }
            let newGenre = Genre(name: genreName, summary: genreSummary, movies: movies)
            await genreViewModel.add(newGenre)
        }
    }
    
    private func updateGenre(_ genre: Genre) {
        Task {
            let movies: [Movie] = movieViewModel.movies.filter { movie in selectedMovies.contains { $0 == movie.id } }
            await genreViewModel.update(name: genreName, summary: genreSummary, movies: movies, genre: genre)
        }
    }
}

