//
//  NavigationRouter.swift
//  MovieLibrary
//
//  Created by NVR4GET on 6/12/2025.
//

import SwiftUI

/**
 An observable router for managing navigation state.
 
 This class maintains a navigation path array that can be used with NavigationStack
 to manage the app's navigation state.
 
 ## Usage
 ```swift
 @State private var router = NavigationRouter()
 
 NavigationStack(path: $router.path) {
     // Your root view
 }
 ```
 */
@Observable
final class NavigationRouter {
    /// The navigation path containing pushed destinations
    var path: [NavigationDestinations] = []
}


/**
 Navigation destinations used throughout the app.
 
 This enum defines all possible navigation targets in the app's navigation stack.
 Each case can carry associated data needed by the destination view.
 */
enum NavigationDestinations: Hashable {
    /// Navigate to movie creation/editing view (nil for new movie, Movie object for editing)
    case movieCreationView(Movie?)
    
    /// Navigate to genre creation/editing view (nil for new genre, Genre object for editing)
    case genreCreationView(Genre?)
    
    /// Navigate to actor creation/editing view (nil for new actor, MovieActor object for editing)
    case actorCreationView(MovieActor?)
    
    /// Navigate to movie detail view (nil safety, though typically should have a Movie)
    case movieView(Movie?)
    
    /// Navigate to the global search view
    case searchView
}
