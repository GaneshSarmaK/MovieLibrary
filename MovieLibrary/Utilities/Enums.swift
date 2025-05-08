//
//  Enums.swift
//  MovieLibrary
//
//  Created by NVR4GET on 6/4/2025.
//

import SwiftUI

/**
 Filter options for querying actors from the database.
 
 These filter cases can be combined to narrow down actor search results.
 */
enum ActorFilter {
    /// Filter actors by name (partial, case-insensitive match)
    case name(name: String)
    
    /// Filter actors by favorite status
    case favourite(isFav: Bool)
    
    /// Filter actors by the movies they appear in (using movie IDs)
    case movies(movies: Set<String>)
}

/**
 Filter options for querying movies from the database.
 
 These filter cases can be combined to create complex movie queries.
 */
enum MovieFilter {
    /// Filter movies by title (partial, case-insensitive match)
    case name(name: String)
    
    /// Filter movies by favorite status
    case favourite(isFav: Bool)
    
    /// Filter movies by exact rating value
    case rating(rating: Int)
    
    /// Filter movies by exact release year
    case releaseYear(year: Int)
    
    /// Filter movies by genres (using genre IDs)
    case genres(genres: Set<String>)
    
    /// Filter movies by actors (using actor IDs)
    case movieActor(movieActors: Set<String>)
}

/**
 Filter options for querying genres from the database.
 
 These filter cases can be combined to narrow down genre search results.
 */
enum GenreFilter {
    /// Filter genres by name (partial, case-insensitive match)
    case name(name: String)
    
    /// Filter genres by favorite status
    case favourite(isFav: Bool)
    
    /// Filter genres by the movies belonging to them (using movie IDs)
    case movies(movies: Set<String>)
}

