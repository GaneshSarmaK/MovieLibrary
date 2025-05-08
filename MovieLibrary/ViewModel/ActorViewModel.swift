//
//  ActorViewModel.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//


import SwiftUI
import SwiftData

/**
 A view model that manages actor-related business logic and state.
 
 The `ActorViewModel` handles CRUD operations for actors, manages the in-memory
 actor collection, and coordinates with the `ActorDataSource` for persistence.
 
 This class is marked with `@Observable` to automatically update SwiftUI views
 when the `movieActors` array changes.
 
 ## Example Usage
 ```swift
 @Environment(ActorViewModel.self) private var actorViewModel
 
 // Fetch all actors
 await actorViewModel.fetchAll()
 
 // Add a new actor
 await actorViewModel.add(
     name: "Leonardo DiCaprio",
     photoData: imageData,
     summary: "Academy Award-winning actor"
 )
 ```
 */
@Observable
final class ActorViewModel {
    
    /// The data source responsible for persisting actors using SwiftData
    @ObservationIgnored let dataSource: ActorDataSource
    
    /// An in-memory collection of actors that drives the UI
    var movieActors: [MovieActor] = []
    
    init() {
        let container = ModelContainer.sharedModelContainer
        dataSource = ActorDataSource(modelContainer: container)
    }
    
    /**
     Fetches actors matching the specified filters.
     
     - Parameter filters: Optional array of filters to apply (name, favorite status, etc.)
     */
    func fetch(filters: [ActorFilter]?) async {
        movieActors = await dataSource.fetch(filters: filters)
    }
    
    /**
     Fetches all actors from the database.
     
     This method retrieves all persisted actors and updates the `movieActors` property.
     */
    func fetchAll() async {
        let items = await dataSource.fetchAll()
        movieActors = items
    }
    
    /**
     Deletes an actor from the library.
     
     - Parameter movieActor: The actor to delete
     
     - Important: This method will crash if the actor doesn't exist in the local collection
     */
    func delete(_ movieActor: MovieActor) async {
        await dataSource.delete(movieActors.first(where: { $0.id == movieActor.id })!)
        movieActors.removeAll(where: { movieActor.id == $0.id })
    }
    
    /**
     Updates an existing actor with new values.
     
     - Parameters:
        - name: Optional new actor name
        - summary: Optional new summary/biography
        - movies: New array of movies the actor appears in (default: empty)
        - movieActor: The actor to update
     
     - Important: This method will crash if the actor doesn't exist in the local collection
     */
    func update(name: String? = nil, summary: String? = nil, movies: [Movie] = [], movieActor: MovieActor) async {
        await dataSource.update(name: name, summary: summary, movies: movies, movieActor: movieActors.first(where: { $0.id == movieActor.id })!)
    }
    
    /**
     Toggles the favorite status of an actor.
     
     - Parameter movieActor: The actor to toggle
     
     - Important: This method will crash if the actor doesn't exist in the local collection
     */
    func toggleFavourite(_ movieActor: MovieActor) async {
        await dataSource.toggleFavourite(movieActors.first(where: { $0.id == movieActor.id })!)
    }
    
    /**
     Adds an existing actor object to the library.
     
     This method checks for duplicate actor names before adding. If an actor with
     the same name exists, the operation is silently skipped.
     
     - Parameter movieActor: The actor object to add
     */
    func add(_ movieActor: MovieActor) async {
        movieActors.forEach { item in
            if item.name == movieActor.name {
                return
            }
        }
        await dataSource.add(movieActor)
        movieActors.append(movieActor)
    }
    
    /**
     Creates and adds a new actor to the library.
     
     This method constructs a new `MovieActor` object, saves any photo data to disk,
     and persists the actor.
     
     - Parameters:
        - name: The full name of the actor
        - photoData: Optional image data for the actor's profile photo
        - summary: A biography or description of the actor
        - movies: Array of movies the actor appears in (default: empty array)
     
     - Note: Photos are saved to the documents directory with a unique UUID-based filename
     */
    func add(name: String, photoData: Data? = nil, summary: String, movies: [Movie] = []) async {
        var photoURL: String? = nil
        
        if let photoData = photoData {
            photoURL = ImageManager.shared.save(photoData) ?? ""
        }
        let newActor = MovieActor(name: name, photoURL: photoURL ?? "", summary: summary, movies: movies)
        await dataSource.add(newActor)
        movieActors.append(newActor)
    }
}

