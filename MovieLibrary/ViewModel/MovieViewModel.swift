//
//  MovieViewModel.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import SwiftData

@Observable
final class MovieViewModel {
    
    @ObservationIgnored let dataSource: MovieDataSource
    
    var movies: [Movie] = []
    
    init() {
        let container = ModelContainer.sharedModelContainer
        dataSource = MovieDataSource(modelContainer: container)
    }
    
    func add(_ movie: Movie) async {
        movies.forEach { item in
            if item.name == movie.name {
                return
            }
        }
        await dataSource.add(movie)
        movies.append(movie)
    }
    
    func add(name: String, photoData: Data? = nil, summary: String, rating: Int, movieActors: [MovieActor] = [], genres: [Genre] = [], releaseYear: Int) async {
        
        var photoURL: String? = nil
        
        if let photoData = photoData {
            photoURL = ImageManager.saveImageToDocuments(data: photoData) ?? ""
        }
        
        let newMovie = Movie(
            name: name,
            photoURL: photoURL ?? "",
            summary: summary,
            rating: rating,
            movieActors: movieActors,
            genres: genres,
            releaseYear: releaseYear)
        await dataSource.add(newMovie)
        movies.append(newMovie)
    }

    func fetchAll() async {
        let items = await dataSource.fetchAll()
        movies = items
    }
    
    func fetch(filters: [MovieFilter]?) async {
        let items = await dataSource.fetch(filters: filters)
        print("Fetch complete \(items.count)")
        movies = items
    }
    
    func update(name: String? = nil, summary: String? = nil, photoURL: String? = nil, rating: Int? = nil, movieActors: [MovieActor] = [], genres: [Genre] = [], releaseYear: Int? = nil, movie: Movie) async {
        await dataSource.update(name: name, summary: summary, photoURL: photoURL, rating: rating, movieActors: movieActors, genres: genres, releaseYear: releaseYear, movie: movie)
    }
    
    func toggleFavourite(_ movie: Movie) async {
        await dataSource.toggleFavourite(movie)
    }
    
    func updateRating(_ movie: Movie, _ rating: Int) async {
        await dataSource.updateRating(movie, rating)
    }
    
    func deleteMovie(_ movie: Movie) async {
        if let url = movie.photoURL {
            ImageManager.deleteImageFromDocuments(filename: url)
        }
        movies.removeAll(where: { $0 == movie })
        await dataSource.delete(movie)
    }
    
}
