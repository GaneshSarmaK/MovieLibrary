//
//  FilterEnums.swift
//  MovieLibrary
//
//  Created by NVR4GET on 6/4/2025.
//

import SwiftUI

enum ActorFilter {
    case name(name: String)
    case favourite(isFav: Bool)
    case movies(movies: Set<String>)
}

enum MovieFilter {
    case name(name: String)
    case favourite(isFav: Bool)
    case rating(rating: Int)
    case releaseYear(year: Int)
    case genres(genres: Set<String>)
    case movieActor(movieActors: Set<String>)
}

enum GenreFilter {
    case name(name: String)
    case favourite(isFav: Bool)
    case movies(movies: Set<String>)
}

// NavDestination
enum NavigationDestinations: Hashable {
    case movieCreationView(Movie?)
    case genreCreationView(Genre?)
    case actorCreationView(MovieActor?)
    case movieView(Movie?)
    case searchView
}
