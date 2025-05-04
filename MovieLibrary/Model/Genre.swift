//
//  Genre.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import SwiftData

@Model
class Genre {
    @Attribute(.unique) private(set) var id: String = UUID().uuidString
    var name: String
    var summary: String
    var isFavourited: Bool

    @Relationship(inverse: \Movie.genres) var movies: [Movie]

    init(name: String, summary: String, movies: [Movie] = []) {
        self.name = name
        self.summary = summary
        self.movies = movies
        self.isFavourited = false
    }
}

extension Genre: Equatable {
    static func == (lhs: Genre, rhs: Genre) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.summary == rhs.summary
    }
}

extension Genre: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
