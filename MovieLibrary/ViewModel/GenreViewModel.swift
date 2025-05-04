//
//  MovieViewModel.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import SwiftData

@Observable
final class GenreViewModel {
    
    let dataSource: GenreDataSource
    var genres: [Genre] = []
    
    init() {
        let container = ModelContainer.sharedModelContainer
        dataSource = GenreDataSource(modelContainer: container)
    }
    
    func fetchAll() async {
        let items = await dataSource.fetchAll()
        genres = items
    }
    
    func fetch(filters: [GenreFilter]?) async {
        genres = await dataSource.fetch(filters: filters)
    }
    
    func delete(_ genre: Genre) async {
        genres.removeAll(where: { genre == $0 })
        await dataSource.delete(genre)
    }
    
    func update(name: String? = nil, summary: String? = nil, movies: [Movie] = [], genre: Genre) async {
        await dataSource.update(name: name, summary: summary, movies: movies, genre: genre)
    }
    
    func toggleFavourite(_ genre: Genre) async {
        await dataSource.toggleFavourite(genre)
    }
    
    func add(_ genre: Genre) async {
        genres.forEach { item in
            if item.name == genre.name {
                return
            }
        }
        await dataSource.add(genre)
        genres.append(genre)
    }
    
    func add(name: String, summary: String, movies: [Movie] = []) async {
        let newGenre = Genre(name: name, summary: summary, movies: movies)
        await dataSource.add(newGenre)
        genres.append(newGenre)
    }
}
