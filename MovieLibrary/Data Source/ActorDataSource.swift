//
//  ActorDataSource.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import SwiftData

@ModelActor
final actor ActorDataSource {
    
    func fetchAll() -> [MovieActor] {
        var movieActors: [MovieActor] = []
        do {
            movieActors = try modelContext.fetch(
                FetchDescriptor<MovieActor>(
                    sortBy: [SortDescriptor(\.name)]
                )
            )
        } catch {
            print("Error fetching movieActors: \(error)")
        }
        return movieActors
        
    }
        
    func fetch(filters: [ActorFilter]?) -> [MovieActor] {
        
        var nameFilter: String?
        var isFavFilter: Bool?
        var movieFilter: Set<String>?
        var movieActors: [MovieActor] = []
        
        if let filters {
            for filter in filters {
                switch filter {
                    case .name(let name):
                        nameFilter = name
    
                    case .favourite(let isFav):
                        isFavFilter = isFav
                        
                    case .movies(let movies):
                        movieFilter = movies
                }
            }
        }
        let namePredicate = #Predicate<MovieActor> {
            nameFilter == nil ? true : $0.name.localizedStandardContains( nameFilter! )
        }
        
        let favPredicate = #Predicate<MovieActor> {
            isFavFilter == nil ? true : isFavFilter! == $0.isFavourited
        }
        
        let predicate = #Predicate<MovieActor> { namePredicate.evaluate($0) && favPredicate.evaluate($0) }
        
        var fetchDescriptor = FetchDescriptor<MovieActor>()
        fetchDescriptor.sortBy = [SortDescriptor(\.name)]
        fetchDescriptor.predicate = predicate

        do {
            let allActors = try modelContext.fetch(fetchDescriptor)
            if let movieFilter {
                movieActors = allActors.filter { actor in
                    actor.movies.contains { movie in
                        movieFilter.contains { movie.id == $0 } }
                }
            }
            movieActors = allActors
            
        } catch {
            print("Error fetching movieActors: \(error)")
        }
        
        return movieActors
    }

    
    func update(name: String? = nil, photoURL: String? = nil, summary: String? = nil, movies: [Movie] = [], movieActor: MovieActor) {
        if let name = name {
            movieActor.name = name
        }
        if let photoURL = photoURL {
            movieActor.photoURL = photoURL
        }
        if let summary = summary {
            movieActor.summary = summary
        }
        if !movies.isEmpty {
            movieActor.movies = movies
        }
        save()
    }
    
    func toggleFavourite(_ movieActor: MovieActor){
        movieActor.isFavourited.toggle()
        save()
    }
    
    func add(_ movieActor: MovieActor) {
        modelContext.insert(movieActor)
        save()
    }
    
    func delete(_ movieActor: MovieActor) {
        modelContext.delete(movieActor)
        save()
    }
    
    func save() {
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}


