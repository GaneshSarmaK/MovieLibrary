//
//  MovieActor.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import SwiftData

/**
 A SwiftData model representing an actor in the movie library.
 
 The `MovieActor` class stores information about actors including their profile photo,
 biography, and associations with movies. It maintains a many-to-many relationship
 with movies through the `movies` property.
 
 ## Relationships
 - Many-to-many inverse relationship with `Movie` through the `movies` property
 
 ## Example Usage
 ```swift
 let actor = MovieActor(
     name: "Leonardo DiCaprio",
     photoURL: "leo.jpg",
     summary: "Academy Award-winning American actor and film producer"
 )
 ```
 */
@Model
final class MovieActor: Identifiable {
    /// Unique identifier for the actor, automatically generated
    @Attribute(.unique) private(set) var id: String = UUID().uuidString
    
    /// The full name of the actor
    var name: String
    
    /// Optional URL/filename for the actor's profile photo
    var photoURL: String?
    
    /// A brief biography or description of the actor
    var summary: String
    
    /// Indicates whether the user has marked this actor as a favorite
    var isFavourited: Bool
    
    /// All movies this actor has appeared in (inverse relationship)
    @Relationship(inverse: \Movie.movieActors) var movies: [Movie]
    
    /**
     Creates a new actor instance.
     
     - Parameters:
        - name: The full name of the actor
        - photoURL: The URL or filename for the actor's profile photo
        - summary: A brief biography or description
        - movies: Array of movies the actor appears in (default: empty array)
     
     - Note: The `isFavourited` property is automatically set to `false` on initialization
     */
    init( name: String, photoURL: String, summary: String, movies: [Movie] = []) {
        self.name = name
        self.photoURL = photoURL
        self.summary = summary
        self.movies = movies
        self.isFavourited = false
    }
}

/// Equatable conformance for comparing actors based on their properties
extension MovieActor: Equatable {
    /**
     Determines if two actors are equal by comparing their properties.
     
     - Parameters:
        - lhs: The left-hand side actor to compare
        - rhs: The right-hand side actor to compare
     
     - Returns: `true` if the id, name, photoURL, and summary match, `false` otherwise
     */
    static func == (lhs: MovieActor, rhs: MovieActor) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.photoURL == rhs.photoURL &&
        lhs.summary == rhs.summary
    }
}

/// Hashable conformance for using actors in sets and as dictionary keys
extension MovieActor: Hashable {
    /**
     Generates a hash value for the actor based on its unique identifier.
     
     - Parameter hasher: The hasher to use when combining components
     */
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

