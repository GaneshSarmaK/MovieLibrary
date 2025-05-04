//
//  GlobalSearcgViewModel.swift
//  MovieLibrary
//
//  Created by NVR4GET on 10/4/2025.
//

import SwiftUI
import SwiftData

@Observable
final class GlobalSearchViewModel {
    
    var dataSource: GlobalSearchDataSource
    
    var movieActors: [MovieActor] = []
    var movies: [Movie] = []
    var genres: [Genre] = []
    
    init() {
        let container = ModelContainer.sharedModelContainer
        self.dataSource = GlobalSearchDataSource(modelContainer: container)
    }
    
    func fetchByPartialString(_ searchParam: String) async {
        
        movieActors = await dataSource.fetchMovieActorsByPartialString(searchParam)
        movies = await dataSource.fetchMoviesByPartialString(searchParam)
        genres = await dataSource.fetchGenresByPartialString(searchParam)  
    }
    
    func fetchAll() async {
        movieActors = await dataSource.fetchAllActors()
        movies = await dataSource.fetchAllMovies()
        genres = await dataSource.fetchAllGenres()
    }
    
    func fetchMoviesByFilter(filters: [MovieFilter]?) async {
        let items = await dataSource.fetchMoviesByFilter(filters: filters)
        print("Fetch complete \(items.count)")
        movies = items
    }
    
    func fetctGenresByFilter(filters: [GenreFilter]?) async {
        let items = await dataSource.fetchGenresByFilter(filters: filters)
        print("Fetch complete \(items.count)")
        genres = items
    }
    
    func fetchMovieActorsByFilter(filters: [ActorFilter]?) async {
        let items = await dataSource.fetchActorsByFilter(filters: filters)
        print("Fetch complete \(items.count)")
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
