//
//  Item.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import SwiftData

@Model
final class MovieActor: Identifiable {
    @Attribute(.unique) private(set) var id: String = UUID().uuidString
    var name: String
    var photoURL: String?
    var summary: String
    var isFavourited: Bool
    
    @Relationship(inverse: \Movie.movieActors) var movies: [Movie]
    
    init( name: String, photoURL: String, summary: String, movies: [Movie] = []) {
        self.name = name
        self.photoURL = photoURL
        self.summary = summary
        self.movies = movies
        self.isFavourited = false
    }
}

extension MovieActor: Equatable {
    static func == (lhs: MovieActor, rhs: MovieActor) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.photoURL == rhs.photoURL &&
        lhs.summary == rhs.summary &&
        lhs.movies == rhs.movies
    }
}

extension MovieActor: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
