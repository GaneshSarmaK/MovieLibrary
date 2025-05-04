//
//  MovieCreationView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 7/4/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct MovieCreationView: View {
    
    @Environment(ActorViewModel.self) var actorViewModel
    @Environment(MovieViewModel.self) var movieViewModel
    @Environment(GenreViewModel.self) var genreViewModel
    @Environment(NavigationRouter.self) var router
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @State private var photoPickerItem: PhotosPickerItem? = nil
    @State private var photoData: Data? = nil
    @State private var selectedGenres: Set<String> = []
    @State private var selectedActors: Set<String> = []
    @State private var movieTitle: String = ""
    @State private var movieSummary: String = ""
    @State private var releaseYear: Int = Calendar.current.component(.year, from: .now)
    @State private var rating: Int = 0
    
    var movie: Movie?
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 8) {
                    photoInput()
                    
                    Group {
                        titleInput()
                        
                        summaryInput()
                        
                        yearInput()
                        
                        ratingInput()
                        
                        actorInput()
                        
                        genreInput()
                    }
                    .padding(.horizontal, 12)
                    
                    Spacer()
                    
                    
                }
            }
            addNewMovie()
        }
//        .ignoresSafeArea(.keyboard)
        .onAppear {
            if let movie = movie {
                movieTitle = movie.name
                movieSummary = movie.summary
                releaseYear = movie.releaseYear
                rating = movie.rating
                selectedActors = Set(movie.movieActors.map { $0.id })
                selectedGenres = Set(movie.genres.map { $0.id })
                photoData = ImageManager.loadImageDataSmart(filename: movie.photoURL!)
            }
        }
        .onChange(of: photoPickerItem) {
            Task {
                if let imageData = try await photoPickerItem?.loadTransferable(type: Data.self) {
                    photoData = imageData
                } else {
                    print("Phtot failed")
                }
            }
        }
    }
    
    @ViewBuilder private func photoInput() -> some View {
        (photoData?.toImage ?? Image(systemName: "person.circle"))
            .resizable()
            .scaledToFit()
            .frame(width: 150)
            .clipShape(.circle)
        
        PhotosPicker("Select Image", selection: $photoPickerItem, matching: .images)
        
    }
    
    @ViewBuilder private func titleInput() -> some View {
        Text("Movie title: ")
            .padding(.bottom, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        TextField("Enter movie title", text: $movieTitle)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder private func summaryInput() -> some View {
        Text("Movie summary: ")
            .padding(.bottom, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        TextField("Enter movie summary", text: $movieSummary)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder private func yearInput() -> some View {
        HStack {
            Text("Release year: ")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            let years = Array(1900...Calendar.current.component(.year, from: Date()))
            Picker("Release Year", selection: $releaseYear) {
                ForEach(years, id: \.self) { year in
                    //String cast to ignore locale conversion on year
                    Text(String(year)).tag(year)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
    }
    
    @ViewBuilder private func ratingInput() -> some View {
        HStack {
            Text("Rating: ")
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .onTapGesture {
                            rating = index
                        }
                }
            }
        }
        .padding(.bottom, 5)
        
    }
    
    @ViewBuilder private func actorInput() -> some View {
        Text("Select Actors: ")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 2)
        
        ActorListView(selectedActors: $selectedActors)
            .frame(height: SizeClass.actorImageSize(for: sizeClass) + 60)
            .padding(.horizontal, -12)
    }
    
    @ViewBuilder private func genreInput() -> some View {
        Text("Select Genres: ")
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 2)
        
        GenreListView(selectedGenres: $selectedGenres)
            .frame(height: 40)
            .padding(.horizontal, -12)

    }
    
    @ViewBuilder private func addNewMovie() -> some View {
        Button(action: {
            if let movie = movie {
                updateMovie(movie: movie)
            } else {
                addMovie()
            }
            router.path.removeLast()
        }, label: {
            Text(movie == nil ? "Add new Movie" : "Update Movie")
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
        })
        .disabled(movieTitle.isEmpty || movieSummary.isEmpty || photoData == nil )
    }
}

extension MovieCreationView {
    
    func updateMovie(movie: Movie) {
        Task {
            var photoURL: String? = nil
            
            if let photoData = photoData {
                photoURL = ImageManager.saveImageToDocuments(data: photoData) ?? ""
            }
            
            let genres: [Genre] = genreViewModel.genres.filter { genre in selectedGenres.contains { $0 == genre.id } }
            let movieActors: [MovieActor] = actorViewModel.movieActors.filter { movieActor in selectedActors.contains { $0 == movieActor.id } }
            
            await movieViewModel.update(name: movieTitle, summary: movieSummary, photoURL: photoURL ?? "", rating: rating, movieActors: movieActors, genres: genres, releaseYear: releaseYear, movie: movie)
        }
    }
    
    func addMovie() {
        Task {
            var photoURL: String? = nil
            
            if let photoData = photoData {
                photoURL = ImageManager.saveImageToDocuments(data: photoData) ?? ""
            }
            
            let genres: [Genre] = genreViewModel.genres.filter { genre in selectedGenres.contains { $0 == genre.id } }
            let movieActors: [MovieActor] = actorViewModel.movieActors.filter { movieActor in selectedActors.contains { $0 == movieActor.id } }

            let newMovie = Movie(name: movieTitle, photoURL: photoURL ?? "" , summary: movieSummary, rating: rating, movieActors: movieActors, genres: genres, releaseYear: releaseYear)
            
            await movieViewModel.add(newMovie)
        }
    }
}
