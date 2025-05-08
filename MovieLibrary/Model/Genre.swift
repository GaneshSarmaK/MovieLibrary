//
//  Genre.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import SwiftData

/**
 A SwiftData model representing a movie genre.
 
 The `Genre` class categorizes movies into different types (e.g., Action, Comedy, Drama).
 It maintains a many-to-many relationship with movies and supports user preferences.
 
 ## Relationships
 - Many-to-many inverse relationship with `Movie` through the `movies` property
 
 ## Example Usage
 ```swift
 let genre = Genre(
     name: "Science Fiction",
     summary: "Explores futuristic and speculative concepts"
 )
 ```
 */
@Model
class Genre {
    /// Unique identifier for the genre, automatically generated
    @Attribute(.unique) private(set) var id: String = UUID().uuidString
    
    /// The name of the genre (e.g., "Action", "Drama", "Comedy")
    var name: String
    
    /// A brief description of what the genre represents
    var summary: String
    
    /// Indicates whether the user has marked this genre as a favorite
    var isFavourited: Bool

    /// All movies that belong to this genre (inverse relationship)
    @Relationship(inverse: \Movie.genres) var movies: [Movie]

    /**
     Creates a new genre instance.
     
     - Parameters:
        - name: The name of the genre
        - summary: A description of the genre
        - movies: Array of movies in this genre (default: empty array)
     
     - Note: The `isFavourited` property is automatically set to `false` on initialization
     */
    init(name: String, summary: String, movies: [Movie] = []) {
        self.name = name
        self.summary = summary
        self.movies = movies
        self.isFavourited = false
    }
}

/// Equatable conformance for comparing genres based on their properties
extension Genre: Equatable {
    /**
     Determines if two genres are equal by comparing their properties.
     
     - Parameters:
        - lhs: The left-hand side genre to compare
        - rhs: The right-hand side genre to compare
     
     - Returns: `true` if the id, name, and summary match, `false` otherwise
     */
    static func == (lhs: Genre, rhs: Genre) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.summary == rhs.summary
    }
}

/// Hashable conformance for using genres in sets and as dictionary keys
extension Genre: Hashable {
    /**
     Generates a hash value for the genre based on its unique identifier.
     
     - Parameter hasher: The hasher to use when combining components
     */
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

