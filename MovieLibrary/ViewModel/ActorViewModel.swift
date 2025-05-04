//
//  ActorViewModel.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//


import SwiftUI
import SwiftData

@Observable
final class ActorViewModel {
    
    let dataSource: ActorDataSource
    var movieActors: [MovieActor] = []
    
    init() {
        let container = ModelContainer.sharedModelContainer
        dataSource = ActorDataSource(modelContainer: container)
    }
    
    func fetch(filters: [ActorFilter]?) async {
        movieActors = await dataSource.fetch(filters: filters)
    }
    
    func fetchAll() async {
        let items = await dataSource.fetchAll()
        movieActors = items
    }
    
    func delete(_ movieActor: MovieActor) async {
        movieActors.removeAll(where: { movieActor == $0 })
        await dataSource.delete(movieActor)
    }
    
    func update(name: String? = nil, summary: String? = nil, movies: [Movie] = [], movieActor: MovieActor) async {
        await dataSource.update(name: name, summary: summary, movies: movies, movieActor: movieActor)
    }
    
    func toggleFavourite(_ movieActor: MovieActor) async {
        await dataSource.toggleFavourite(movieActor)
    }
    
    func add(_ movieActor: MovieActor) async {
        movieActors.forEach { item in
            if item.name == movieActor.name {
                return
            }
        }
        await dataSource.add(movieActor)
        movieActors.append(movieActor)
    }
    
    func add(name: String, photoData: Data? = nil, summary: String, movies: [Movie] = []) async {
        var photoURL: String? = nil
        
        if let photoData = photoData {
            photoURL = ImageManager.saveImageToDocuments(data: photoData) ?? ""
        }
        let newActor = MovieActor(name: name, photoURL: photoURL ?? "", summary: summary, movies: movies)
        await dataSource.add(newActor)
        movieActors.append(newActor)
    }
}

