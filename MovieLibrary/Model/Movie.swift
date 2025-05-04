//
//  Movie.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import SwiftData

@Model
final class Movie: Identifiable {
    @Attribute(.unique) private(set) var id: String = UUID().uuidString
    var name: String
    var photoURL: String?
    var summary: String
    var rating: Int
    var releaseYear: Int
    var isFavourited: Bool
    
    var movieActors: [MovieActor]
    var genres: [Genre]
    
    
    init(name: String, photoURL: String, summary: String, rating: Int, movieActors: [MovieActor] = [], genres: [Genre] = [], releaseYear: Int) {
        self.name = name
        self.photoURL = photoURL
        self.summary = summary
        self.rating = rating
        self.movieActors = movieActors
        self.genres = genres
        self.releaseYear = releaseYear
        self.isFavourited = false
    }
}

extension Movie: Equatable {
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.photoURL == rhs.photoURL &&
        lhs.summary == rhs.summary &&
        lhs.rating == rhs.rating &&
        lhs.movieActors == rhs.movieActors &&
        lhs.genres == rhs.genres &&
        lhs.releaseYear == rhs.releaseYear
    }
}

extension Movie: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


