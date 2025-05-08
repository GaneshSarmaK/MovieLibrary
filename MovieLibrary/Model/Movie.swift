//
//  Movie.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import SwiftData

/**
 A SwiftData model representing a movie in the library.
 
 The `Movie` class stores comprehensive information about a movie including its metadata,
 relationships with actors and genres, and user preferences. This class is persisted using
 SwiftData and supports querying, filtering, and relationship management.
 
 ## Relationships
 - Many-to-many relationship with `MovieActor` through `movieActors`
 - Many-to-many relationship with `Genre` through `genres`
 
 ## Example Usage
 ```swift
 let movie = Movie(
     name: "Inception",
     photoURL: "inception.jpg",
     summary: "A thief who steals corporate secrets...",
     rating: 9,
     movieActors: actors,
     genres: genres,
     releaseYear: 2010
 )
 ```
 */
@Model
final class Movie: Identifiable {
    /// Unique identifier for the movie, automatically generated
    @Attribute(.unique) private(set) var id: String = UUID().uuidString
    
    /// The title of the movie
    var name: String
    
    /// Optional URL/filename for the movie's poster image
    var photoURL: String?
    
    /// A brief description or synopsis of the movie
    var summary: String
    
    /// User rating for the movie (typically 1-10)
    var rating: Int
    
    /// The year the movie was released
    var releaseYear: Int
    
    /// Indicates whether the user has marked this movie as a favorite
    var isFavourited: Bool
    
    /// Collection of actors associated with this movie
    var movieActors: [MovieActor]
    
    /// Collection of genres that categorize this movie
    var genres: [Genre]
    
    /**
     Creates a new movie instance.
     
     - Parameters:
        - name: The title of the movie
        - photoURL: The URL or filename for the movie's poster image
        - summary: A brief description of the movie
        - rating: User rating (typically 1-10)
        - movieActors: Array of actors in the movie (default: empty array)
        - genres: Array of genres for the movie (default: empty array)
        - releaseYear: The year the movie was released
     
     - Note: The `isFavourited` property is automatically set to `false` on initialization
     */
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

/// Equatable conformance for comparing movies based on all their properties
extension Movie: Equatable {
    /**
     Determines if two movies are equal by comparing all properties.
     
     - Parameters:
        - lhs: The left-hand side movie to compare
        - rhs: The right-hand side movie to compare
     
     - Returns: `true` if all properties match, `false` otherwise
     */
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

/// Hashable conformance for using movies in sets and as dictionary keys
extension Movie: Hashable {
    /**
     Generates a hash value for the movie based on its unique identifier.
     
     - Parameter hasher: The hasher to use when combining components
     */
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


