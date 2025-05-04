//
//  Decodables.swift
//  MovieLibrary
//
//  Created by NVR4GET on 8/4/2025.
//

import SwiftUI

struct DummyMovie: Decodable {
    let name: String
    let photoURL: String
    let summary: String
    let rating: Int
    let releaseYear: Int
    let genres: [DummyGenre]
    let movieActors: [DummyActor]
}

struct DummyGenre: Decodable {
    let name: String
    let summary: String
}

struct DummyActor: Decodable {
    let name: String
    let photoURL: String
    let summary: String
}

func saveDummyMoviesToDatabase(genreViewModel: GenreViewModel, movieViewModel: MovieViewModel, actorViewModel: ActorViewModel) async throws {
    guard let url = Bundle.main.url(forResource: "DummyData", withExtension: "json") else {
        throw NSError(domain: "FileNotFound", code: 404)
    }
    
    let data = try Data(contentsOf: url)
    let dummyMovies = try JSONDecoder().decode([DummyMovie].self, from: data)
    
    for dummy in dummyMovies {
        var genres: [Genre] = []
        for g in dummy.genres {
            if let existing = genreViewModel.genres.first(where: { $0.name == g.name }) {
                genres.append(existing)
            } else {
                let newGenre = Genre(name: g.name, summary: g.summary)
                genres.append(newGenre)
            }
        }
        
        var actors: [MovieActor] = []
        for a in dummy.movieActors {
            if let existing = actorViewModel.movieActors.first(where: { $0.name == a.name }) {
                actors.append(existing)
            } else {
                let newActor = MovieActor(name: a.name, photoURL: a.photoURL, summary: a.summary)
                actors.append(newActor)
            }
        }
        
        let movie = Movie(
            name: dummy.name,
            photoURL: dummy.photoURL,
            summary: dummy.summary,
            rating: dummy.rating,
            movieActors: actors,
            genres: genres,
            releaseYear: dummy.releaseYear
        )
        
        await movieViewModel.add(movie)
        await genreViewModel.fetchAll()
    }
}
