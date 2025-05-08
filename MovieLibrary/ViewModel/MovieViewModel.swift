//
//  MovieViewModel.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import SwiftData

/**
 A view model that manages movie-related business logic and state.
 
 The `MovieViewModel` serves as the intermediary between the UI and the data layer,
 handling CRUD operations for movies, managing the in-memory movie collection,
 and coordinating with the `MovieDataSource` for persistence.
 
 This class is marked with `@Observable` to enable SwiftUI views to automatically
 update when the `movies` array changes.
 
 ## Example Usage
 ```swift
 @Environment(MovieViewModel.self) private var movieViewModel
 
 // Fetch all movies
 await movieViewModel.fetchAll()
 
 // Add a new movie
 await movieViewModel.add(
     name: "Inception",
     photoData: imageData,
     summary: "A mind-bending thriller",
     rating: 9,
     movieActors: selectedActors,
     genres: selectedGenres,
     releaseYear: 2010
 )
 ```
 */
@Observable
final class MovieViewModel {
    
    /// The data source responsible for persisting movies using SwiftData
    @ObservationIgnored let dataSource: MovieDataSource
    
    /// An in-memory collection of movies that drives the UI
    var movies: [Movie] = []
    
    init() {
        let container = ModelContainer.sharedModelContainer
        dataSource = MovieDataSource(modelContainer: container)
    }
    
    /**
     Adds an existing movie object to the library.
     
     This method checks for duplicate movie names before adding. If a movie with
     the same name exists, the operation is silently skipped.
     
     - Parameter movie: The movie object to add
     
     - Note: This method persists the movie to SwiftData and updates the in-memory collection
     */
    func add(_ movie: Movie) async {
        movies.forEach { item in
            if item.name == movie.name {
                return
            }
        }
        await dataSource.add(movie)
        movies.append(movie)
    }
    
    /**
     Creates and adds a new movie to the library.
     
     This method constructs a new `Movie` object from the provided parameters,
     saves any photo data to the documents directory, and persists the movie.
     
     - Parameters:
        - name: The title of the movie
        - photoData: Optional image data for the movie poster. If provided, it's saved to disk
        - summary: A brief description of the movie
        - rating: User rating (typically 1-10)
        - movieActors: Array of actors in the movie (default: empty array)
        - genres: Array of genres for the movie (default: empty array)
        - releaseYear: The year the movie was released
     
     - Note: Photos are saved to the documents directory with a unique UUID-based filename
     */
    func add(name: String, photoData: Data? = nil, summary: String, rating: Int, movieActors: [MovieActor] = [], genres: [Genre] = [], releaseYear: Int) async {
        
        var photoURL: String? = nil
        
        if let photoData = photoData {
            photoURL = ImageManager.shared.save(photoData) ?? ""
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

    /**
     Fetches all movies from the database.
     
     This method retrieves all persisted movies and updates the `movies` property,
     triggering UI updates in any observing views.
     */
    func fetchAll() async {
        let items = await dataSource.fetchAll()
        movies = items
    }
    
    /**
     Fetches movies matching the specified filters.
     
     - Parameter filters: Optional array of filters to apply (name, rating, year, genres, actors, etc.)
     
     - Note: Pass `nil` to fetch all movies. Multiple filters are combined with AND logic
     */
    func fetch(filters: [MovieFilter]?) async {
        let items = await dataSource.fetch(filters: filters)
        AppLogger.component.info("Fetch complete: \(items.count) movies")
        movies = items
    }
    
    /**
     Updates an existing movie with new values.
     
     Only the provided (non-nil) parameters will be updated. This method finds the
     movie in the local collection by ID before updating.
     
     - Parameters:
        - name: Optional new movie title
        - summary: Optional new summary
        - photoURL: Optional new photo URL/filename
        - rating: Optional new rating
        - movieActors: New array of actors (default: empty, meaning no update)
        - genres: New array of genres (default: empty, meaning no update)
        - releaseYear: Optional new release year
        - movie: The movie to update
     
     - Important: This method will crash if the movie doesn't exist in the local collection
     */
    func update(name: String? = nil, summary: String? = nil, photoURL: String? = nil, rating: Int? = nil, movieActors: [MovieActor] = [], genres: [Genre] = [], releaseYear: Int? = nil, movie: Movie) async {
        await dataSource.update(name: name, summary: summary, photoURL: photoURL, rating: rating, movieActors: movieActors, genres: genres, releaseYear: releaseYear, movie: movies.first(where: { $0.id == movie.id })!)
    }
    
    /**
     Toggles the favorite status of a movie.
     
     - Parameter movie: The movie to toggle
     
     - Returns: `true` if the movie was found and toggled, `false` otherwise
     */
    func toggleFavourite(_ movie: Movie) async -> Bool {
        AppLogger.component.debugLog("Toggling favourite for movie: \(movie.id)")
        let movie = movies.first(where: { $0.id == movie.id })
        if movie != nil {
            await dataSource.toggleFavourite(movie!)
        }
        return movie != nil

    }
    
    /**
     Updates the rating of a specific movie.
     
     - Parameters:
        - movie: The movie to update
        - rating: The new rating value
     
     - Returns: `true` if the movie was found and updated, `false` otherwise
     */
    func updateRating(_ movie: Movie, _ rating: Int) async -> Bool {
        let movie = movies.first(where: { $0.id == movie.id })
        if let movieName = movie?.name {
            AppLogger.component.debugLog("Updating rating for movie: \(movieName)")
        }

        if movie != nil {
            await dataSource.updateRating(movie!, rating)
        }
        
        return movie != nil
    }
    
    /**
     Deletes a movie from the library.
     
     This method removes the movie from both persistent storage and the in-memory collection.
     It also deletes the associated photo file from the documents directory if one exists.
     
     - Parameter movie: The movie to delete
     
     - Important: This method will crash if the movie doesn't exist in the local collection
     */
    func deleteMovie(_ movie: Movie) async {
        if let url = movie.photoURL {
            ImageManager.shared.delete(url)
        }
        AppLogger.component.debugLog("Movies count before deletion: \(movies.count)")
        await dataSource.delete(movies.first(where: { $0.id == movie.id })!)
        movies.removeAll(where: { $0.id == movie.id })
        AppLogger.component.debugLog("Movies count after deletion: \(movies.count)")
    }
    
}
