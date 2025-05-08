//
//  GlobalSearchDataSource.swift
//  MovieLibrary
//
//  Created by NVR4GET on 10/4/2025.
//

import SwiftUI
import SwiftData

@ModelActor
final actor GlobalSearchDataSource {
    
    
    func fetchGenresByPartialString(_ searchParam: String? = nil) -> [Genre] {
        
        var allGenres: [Genre] = []
        
        let genreNamePredicate = #Predicate<Genre> {
            searchParam == nil ? true : $0.name.localizedStandardContains( searchParam! )
        }
        let genreSummaryPredicate = #Predicate<Genre> {
            searchParam == nil ? true : $0.summary.localizedStandardContains( searchParam! )
        }

        let genrePredicate = #Predicate<Genre> { genreNamePredicate.evaluate($0) || genreSummaryPredicate.evaluate($0) }
        
        let genreFetchDescriptor = FetchDescriptor<Genre>(predicate: genrePredicate)
        
        do{
            allGenres = try modelContext.fetch(genreFetchDescriptor)
        } catch {
            AppLogger.dataStore.error("Error fetching genres: \(error)")
        }
        
        return allGenres
    }
    
    func fetchMoviesByPartialString(_ searchParam: String?) -> [Movie] {
        
        var allMovies: [Movie] = []
        let movieNamePredicate = #Predicate<Movie> {
            searchParam == nil ? true : $0.name.localizedStandardContains( searchParam! )
        }
        let movieSummaryPredicate = #Predicate<Movie> {
            searchParam == nil ? true : $0.summary.localizedStandardContains( searchParam! )
        }
        
        let moviePredicate = #Predicate<Movie> { movieNamePredicate.evaluate($0) || movieSummaryPredicate.evaluate($0) }
        
        let movieFetchDescriptor = FetchDescriptor<Movie>(predicate: moviePredicate)
        
        do{
            allMovies = try modelContext.fetch(movieFetchDescriptor)
        } catch {
            AppLogger.dataStore.error("Error fetching movies by partial string: \(error)")
        }
        return allMovies
        
        
    }
    
    func fetchMovieActorsByPartialString(_ searchParam: String?) -> [MovieActor] {
        
        var allMovieActors: [MovieActor] = []
        let movieActorNamePredicate = #Predicate<MovieActor> {
            searchParam == nil ? true : $0.name.localizedStandardContains( searchParam! )
        }
        let movieActorSummaryPredicate = #Predicate<MovieActor> {
            searchParam == nil ? true : $0.summary.localizedStandardContains( searchParam! )
        }
        
        let movieActorPredicate = #Predicate<MovieActor> { movieActorNamePredicate.evaluate($0) || movieActorSummaryPredicate.evaluate($0) }
        
        let movieActorFetchDescriptor = FetchDescriptor<MovieActor>(predicate: movieActorPredicate)
        
        do{
            allMovieActors = try modelContext.fetch(movieActorFetchDescriptor)
        } catch {
            AppLogger.dataStore.error("Error fetching actors by partial string: \(error)")
        }
        return allMovieActors
    }
    
    func fetchAllMovies() -> [Movie] {
        var movies: [Movie] = []

        do {
            movies = try modelContext.fetch(
                FetchDescriptor<Movie>(
                    sortBy: [SortDescriptor(\.name)]
                )
            )
        } catch {
            AppLogger.dataStore.error("Error fetching all movies: \(error)")
        }
        return movies

    }
    
    func fetchAllGenres() -> [Genre] {
        var genres: [Genre] = []
        
        do {
            genres = try modelContext.fetch(
                FetchDescriptor<Genre>(
                    sortBy: [SortDescriptor(\.name)]
                )
            )
        } catch {
            AppLogger.dataStore.error("Error fetching all genres: \(error)")
        }
        return genres
        
    }
    
    func fetchAllActors() -> [MovieActor] {
        var movieActors: [MovieActor] = []
        do {
            movieActors = try modelContext.fetch(
                FetchDescriptor<MovieActor>(
                    sortBy: [SortDescriptor(\.name)]
                )
            )
        } catch {
            AppLogger.dataStore.error("Error fetching all actors: \(error)")
        }
        return movieActors
        
    }
    
    func fetchActorsByFilter(filters: [ActorFilter]?) -> [MovieActor] {
        
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
            AppLogger.dataStore.error("Error fetching actors by filter: \(error)")
        }
        
        return movieActors
    }
    
    func fetchGenresByFilter(filters: [GenreFilter]?) -> [Genre] {
        
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
            AppLogger.dataStore.error("Error fetching genres by filter: \(error)")
        }
        
        return genres
        
    }
    
    func fetchMoviesByFilter(filters: [MovieFilter]?) -> [Movie] {
    
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
            AppLogger.dataStore.error("Error fetching movies by filter: \(error)")
        }
        
        return movies
        
    }
    
    
}
