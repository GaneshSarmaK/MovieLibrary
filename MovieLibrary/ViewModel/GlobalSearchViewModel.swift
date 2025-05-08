//
//  GlobalSearchViewModel.swift
//  MovieLibrary
//
//  Created by NVR4GET on 10/4/2025.
//

import SwiftUI
import SwiftData

/**
 A view model that manages global search functionality across movies, actors, and genres.
 
 The `GlobalSearchViewModel` provides a unified search interface that can query and filter
 across all three main entity types (movies, actors, and genres) simultaneously. It maintains
 separate collections for each entity type and coordinates with the `GlobalSearchDataSource`.
 
 This class is marked with `@Observable` to automatically update SwiftUI views when
 any of the collection properties change.
 
 ## Example Usage
 ```swift
 @Environment(GlobalSearchViewModel.self) private var searchViewModel
 
 // Search across all entities
 await searchViewModel.fetchByPartialString("inception")
 
 // Apply filters to movies
 await searchViewModel.fetchMoviesByFilter(filters: [.rating(9)])
 ```
 */
@Observable
final class GlobalSearchViewModel {
    
    /// The data source responsible for querying across multiple entity types
    var dataSource: GlobalSearchDataSource
    
    /// Collection of actors matching current search/filter criteria
    var movieActors: [MovieActor] = []
    
    /// Collection of movies matching current search/filter criteria
    var movies: [Movie] = []
    
    /// Collection of genres matching current search/filter criteria
    var genres: [Genre] = []
    
    init() {
        let container = ModelContainer.sharedModelContainer
        self.dataSource = GlobalSearchDataSource(modelContainer: container)
    }
    
    /**
     Fetches all entities (movies, actors, genres) that partially match the search parameter.
     
     This method performs a case-insensitive partial string match across names and summaries
     of all entity types and updates the respective collection properties.
     
     - Parameter searchParam: The search string to match against entity names and summaries
     */
    func fetchByPartialString(_ searchParam: String) async {
        
        movieActors = await dataSource.fetchMovieActorsByPartialString(searchParam)
        movies = await dataSource.fetchMoviesByPartialString(searchParam)
        genres = await dataSource.fetchGenresByPartialString(searchParam)  
    }
    
    /**
     Fetches all movies, actors, and genres from the database.
     
     This method retrieves complete collections of all three entity types without any filtering.
     */
    func fetchAll() async {
        movieActors = await dataSource.fetchAllActors()
        movies = await dataSource.fetchAllMovies()
        genres = await dataSource.fetchAllGenres()
    }
    
    /**
     Fetches movies matching the specified filters.
     
     - Parameter filters: Optional array of movie-specific filters (name, rating, year, genres, actors)
     */
    func fetchMoviesByFilter(filters: [MovieFilter]?) async {
        let items = await dataSource.fetchMoviesByFilter(filters: filters)
        AppLogger.component.info("Fetch complete: \(items.count) movies")
        movies = items
    }
    
    /**
     Fetches genres matching the specified filters.
     
     - Parameter filters: Optional array of genre-specific filters
     
     - Note: The method name has a typo ("fetct" instead of "fetch")
     */
    func fetctGenresByFilter(filters: [GenreFilter]?) async {
        let items = await dataSource.fetchGenresByFilter(filters: filters)
        AppLogger.component.info("Fetch complete: \(items.count) genres")
        genres = items
    }
    
    /**
     Fetches actors matching the specified filters.
     
     - Parameter filters: Optional array of actor-specific filters
     */
    func fetchMovieActorsByFilter(filters: [ActorFilter]?) async {
        let items = await dataSource.fetchActorsByFilter(filters: filters)
        AppLogger.component.info("Fetch complete: \(items.count) actors")
        movieActors = items
    }
    
    
}

//struct ItemWithScore {
//    
//    var score: Int = 0
//    var movie: Movie? = nil
//    var genre: Genre? = nil
//    var movieActor: MovieActor? = nil
//    
//    init(movie: Movie? = nil, genre: Genre? = nil, movieActor: MovieActor? = nil, searchParam: String){
//        if let movie = movie {
//            if movie.name.contains(searchParam) {
//                score += 4
//            }
//            if movie.summary.contains(searchParam){
//                score += 2
//            }
//            self.movie = movie
//        }
//        
//        if let genre = genre {
//            if genre.name.contains(searchParam) {
//                score += 3
//            }
//            if genre.summary.contains(searchParam){
//                score += 1
//            }
//            self.genre = genre
//        }
//        
//        if let movieActor = movieActor {
//            if movieActor.name.contains(searchParam) {
//                score += 2
//            }
//            if movieActor.summary.contains(searchParam){
//                score += 1
//            }
//            self.movieActor = movieActor
//        }
//        
//    }
//}
//
