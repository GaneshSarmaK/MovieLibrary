//
//  MovieDataSource.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftData
import SwiftUI

@ModelActor
final actor MovieDataSource {
    
    func fetch(filters: [MovieFilter]?) -> [Movie] {
    
        var nameFilter: String?
        var isFavFilter: Bool?
        var ratingFilter: Int?
        var yearFilter: Int?
        var genresFilter: Set<String>?
        var actorsFilter: Set<String>?
        var movies: [Movie] = []
        
        if let filters {
            for filter in filters {
                switch filter {
                    case .name(let name):
                        nameFilter = name
                    case .favourite(let isFav):
                        isFavFilter = isFav
                    case .rating(let rating):
                        ratingFilter = rating
                    case .releaseYear(let year):
                        yearFilter = year
                    case .genres(let genres):
                        genresFilter = genres
                    case .movieActor(let movieActors):
                        actorsFilter = movieActors
                }
            }
        }
        
        let namePredicate = #Predicate<Movie> {
            nameFilter == nil ? true : $0.name.localizedStandardContains( nameFilter!  )
        }
        
        let yearPredicate = #Predicate<Movie> {
            yearFilter == nil ? true : yearFilter! == $0.releaseYear
        }

        let favPredicate = #Predicate<Movie> {
            isFavFilter == nil ? true : isFavFilter! == $0.isFavourited
        }

        let ratingPredicate = #Predicate<Movie> {
            ratingFilter == nil ? true : ratingFilter! == $0.rating
        }
        
        let predicate = #Predicate<Movie> { namePredicate.evaluate($0) && favPredicate.evaluate($0) && ratingPredicate.evaluate($0) && yearPredicate.evaluate($0) }

        let fetchDescriptor = FetchDescriptor<Movie>(predicate: predicate, sortBy: [SortDescriptor(\.name)])

        do {
            var allMovies = try modelContext.fetch(fetchDescriptor)
            // In-memory filtering based on selected friends
            
            if let actorsFilter, !actorsFilter.isEmpty {
                movies = allMovies.filter { movie in
                    movie.movieActors.contains { actor in
                        actorsFilter.contains { actor.id == $0 }
                    }
                }
            } else {
                movies = allMovies
            }
            allMovies = movies
            if let genresFilter, !genresFilter.isEmpty {
                movies = allMovies.filter { movie in
                    movie.genres.contains { genre in
                        genresFilter.contains { genre.id == $0 }
                    }
                }
            } else {
                movies = allMovies
            }
        } catch {
            print("Error fetching movies: \(error)")
        }
        
        return movies
        
    }
    
    func fetchAll() -> [Movie] {
        var movies: [Movie] = []

        do {
            movies = try modelContext.fetch(
                FetchDescriptor<Movie>(
                    sortBy: [SortDescriptor(\.name)]
                )
            )
        } catch {
            print("Error fetching movies: \(error)")
        }
        return movies

    }
    
    func add(_ movie: Movie) {
        modelContext.insert(movie)
        save()
    }
    
    func delete(_ movie: Movie) {
        modelContext.delete(movie)
        save()
    }
    
    func update(name: String? = nil, summary: String? = nil, photoURL: String? = nil, rating: Int? = nil, movieActors: [MovieActor] = [], genres: [Genre] = [], releaseYear: Int? = nil, movie: Movie) {
        if let name = name {
            movie.name = name
        }
        if let summary = summary {
            movie.summary = summary
        }
        if let photoURL = photoURL {
            movie.photoURL = photoURL
        }
        if let rating = rating {
            movie.rating = rating
        }
        if !movieActors.isEmpty {
            movie.movieActors = movieActors
        }
        if !genres.isEmpty {
            movie.genres = genres
        }
        if let releaseYear = releaseYear {
            movie.releaseYear = releaseYear
        }
        save()
    }
    
    func updateRating(_ movie: Movie, _ rating: Int){
        movie.rating = rating
        save()
    }
    
    func toggleFavourite(_ movie: Movie){
        movie.isFavourited.toggle()
        save()
    }
    
    func save(){
        do {
            try modelContext.save()
        } catch {
            fatalError(error.localizedDescription)
        }
        
    }
}

