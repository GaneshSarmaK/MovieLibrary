//
//  GenreViewModel.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import SwiftData

/**
 A view model that manages genre-related business logic and state.
 
 The `GenreViewModel` coordinates between the UI and the data layer for all genre operations,
 including CRUD operations, filtering, and managing the in-memory genre collection.
 
 This class is marked with `@Observable` to automatically update SwiftUI views when
 the `genres` array changes.
 
 ## Example Usage
 ```swift
 @Environment(GenreViewModel.self) private var genreViewModel
 
 // Fetch all genres
 await genreViewModel.fetchAll()
 
 // Add a new genre
 await genreViewModel.add(
     name: "Science Fiction",
     summary: "Futuristic and speculative narratives"
 )
 ```
 */
@Observable
final class GenreViewModel {
    
    /// The data source responsible for persisting genres using SwiftData
    let dataSource: GenreDataSource
    
    /// An in-memory collection of genres that drives the UI
    var genres: [Genre] = []
    
    init() {
        let container = ModelContainer.sharedModelContainer
        dataSource = GenreDataSource(modelContainer: container)
    }
    
    /**
     Fetches all genres from the database.
     
     This method retrieves all persisted genres and updates the `genres` property.
     */
    func fetchAll() async {
        let items = await dataSource.fetchAll()
        genres = items
    }
    
    /**
     Fetches genres matching the specified filters.
     
     - Parameter filters: Optional array of filters to apply (name, favorite status, etc.)
     */
    func fetch(filters: [GenreFilter]?) async {
        genres = await dataSource.fetch(filters: filters)
    }
    
    /**
     Deletes a genre from the library.
     
     - Parameter genre: The genre to delete
     
     - Important: This method will crash if the genre doesn't exist in the local collection
     */
    func delete(_ genre: Genre) async {
        await dataSource.delete(genres.first(where: { $0.id == genre.id })!)
        genres.removeAll(where: { genre.id == $0.id })
    }
    
    /**
     Updates an existing genre with new values.
     
     - Parameters:
        - name: Optional new genre name
        - summary: Optional new summary
        - movies: New array of movies in this genre (default: empty)
        - genre: The genre to update
     
     - Important: This method will crash if the genre doesn't exist in the local collection
     */
    func update(name: String? = nil, summary: String? = nil, movies: [Movie] = [], genre: Genre) async {
        await dataSource.update(name: name, summary: summary, movies: movies, genre: genres.first(where: { $0.id == genre.id })!)
    }
    
    /**
     Toggles the favorite status of a genre.
     
     - Parameter genre: The genre to toggle
     
     - Important: This method will crash if the genre doesn't exist in the local collection
     */
    func toggleFavourite(_ genre: Genre) async {
        await dataSource.toggleFavourite(genres.first(where: { $0.id == genre.id })!)
    }
    
    /**
     Adds an existing genre object to the library.
     
     This method checks for duplicate genre names before adding. If a genre with
     the same name exists, the operation is silently skipped.
     
     - Parameter genre: The genre object to add
     */
    func add(_ genre: Genre) async {
        genres.forEach { item in
            if item.name == genre.name {
                return
            }
        }
        await dataSource.add(genre)
        genres.append(genre)
    }
    
    /**
     Creates and adds a new genre to the library.
     
     - Parameters:
        - name: The name of the genre
        - summary: A description of the genre
        - movies: Array of movies in this genre (default: empty array)
     */
    func add(name: String, summary: String, movies: [Movie] = []) async {
        let newGenre = Genre(name: name, summary: summary, movies: movies)
        await dataSource.add(newGenre)
        genres.append(newGenre)
    }
}
