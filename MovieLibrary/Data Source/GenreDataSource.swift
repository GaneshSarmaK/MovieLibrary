//
//  GenreDataSource.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import SwiftData

@ModelActor
final actor GenreDataSource {
        
    func fetch(filters: [GenreFilter]?) -> [Genre] {
        
        var nameFilter: String?
        var isFavFilter: Bool?
        var movieFilter: Set<String>?
        var genres: [Genre] = []
        
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
        
        let namePredicate = #Predicate<Genre> {
            nameFilter == nil ? true : $0.name.localizedStandardContains( nameFilter! )
        }
        
        let favPredicate = #Predicate<Genre> {
            isFavFilter == nil ? true : isFavFilter! == $0.isFavourited
        }
        
        let predicate = #Predicate<Genre> { namePredicate.evaluate($0) && favPredicate.evaluate($0) }
        
        let fetchDescriptor = FetchDescriptor<Genre>(predicate: predicate, sortBy: [SortDescriptor(\.name)])
        
        do{
            let allGenres = try modelContext.fetch(fetchDescriptor)
            
            if let movieFilter {
                genres = genres.filter { genre in
                    genre.movies.contains { movie in
                        movieFilter.contains { movie.id == $0 } }
                }
            }
            genres = allGenres
        } catch {
            AppLogger.dataStore.error("Error fetching genres: \(error)")
        }
        
        return genres
        
    }
    
    func fetchAll() -> [Genre] {
        var genres: [Genre] = []
        
        do {
            genres = try modelContext.fetch(
                FetchDescriptor<Genre>(
                    sortBy: [SortDescriptor(\.name)]
                )
            )
        } catch {
            AppLogger.dataStore.error("Error fetching genres: \(error)")
        }
        return genres
        
    }
    
    func add(_ genre: Genre) {
        modelContext.insert(genre)
        save()
    }
    
    func delete(_ genre: Genre) {
        modelContext.delete(genre)
        save()
    }
    
    func update(name: String? = nil, summary: String? = nil, movies: [Movie] = [], genre: Genre) {
        if let name = name {
            genre.name = name
        }
        if let summary = summary {
            genre.summary = summary
        }
        if !movies.isEmpty {
            genre.movies = movies
        }
        save()
    }
    
    func toggleFavourite(_ genre: Genre){
        genre.isFavourited.toggle()
        save()
    }
    
    func save(){
        do {
            try modelContext.save()
            AppLogger.dataStore.info("Genre data saved successfully")
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }
}


