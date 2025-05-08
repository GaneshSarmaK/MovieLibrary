//
//  Decodables.swift
//  MovieLibrary
//
//  Created by NVR4GET on 8/4/2025.
//

import SwiftUI

/**
 A decodable representation of a movie from JSON data.
 
 Used for parsing dummy/seed data on first app launch. This structure mirrors
 the `Movie` model but uses nested `DummyGenre` and `DummyActor` structures.
 */
struct DummyMovie: Decodable {
    /// The movie title
    let name: String
    
    /// Filename or URL of the movie poster (must exist in assets)
    let photoURL: String
    
    /// Movie synopsis/description
    let summary: String
    
    /// User rating (typically 1-10)
    let rating: Int
    
    /// The year the movie was released
    let releaseYear: Int
    
    /// Array of genres for this movie
    let genres: [DummyGenre]
    
    /// Array of actors in this movie
    let movieActors: [DummyActor]
}

/**
 A decodable representation of a genre from JSON data.
 
 Used within `DummyMovie` for parsing seed data.
 */
struct DummyGenre: Decodable {
    /// The genre name
    let name: String
    
    /// Genre description
    let summary: String
}

/**
 A decodable representation of an actor from JSON data.
 
 Used within `DummyMovie` for parsing seed data.
 */
struct DummyActor: Decodable {
    /// The actor's full name
    let name: String
    
    /// Filename or URL of the actor's photo (must exist in assets)
    let photoURL: String
    
    /// Actor biography/description
    let summary: String
}

/**
 Loads dummy movie data from a JSON file and populates the database.
 
 This function is called on first app launch to seed the database with initial content.
 It reads from `DummyData.json` in the app bundle and creates Movie, Genre, and MovieActor
 entities with proper relationships.
 
 The function handles:
 - **Image Migration**: Processes all asset images through 16:9 crop + compression
   and migrates them to file storage. Returns a mapping to update photoURLs.
 - **Entity Deduplication**: If a genre or actor already exists (by name), it reuses
   the existing entity. Otherwise, it creates a new entity.
 
 This ensures data integrity when multiple movies share the same genres or actors,
 and ensures all images are consistently formatted (16:9 aspect ratio).
 
 - Parameters:
    - genreViewModel: The genre view model for managing genre entities
    - movieViewModel: The movie view model for managing movie entities
    - actorViewModel: The actor view model for managing actor entities
 
 - Throws: An error if the JSON file is not found or if decoding fails
 
 - Note: This function should only be called once per app installation,
         typically controlled by a UserDefaults flag
         
 ## Image Processing
 All asset images are automatically:
 1. Cropped to 16:9 aspect ratio (center crop)
 2. Compressed to 30% quality
 3. Saved to documents directory with UUID filename
 4. Cached in memory for fast access
 */
func saveDummyMoviesToDatabase(genreViewModel: GenreViewModel, movieViewModel: MovieViewModel, actorViewModel: ActorViewModel) async throws {
    guard let url = Bundle.main.url(forResource: "DummyData", withExtension: "json") else {
        throw NSError(domain: "FileNotFound", code: 404)
    }
    
    let data = try Data(contentsOf: url)
    let dummyMovies = try JSONDecoder().decode([DummyMovie].self, from: data)
    
    // STEP 1: Migrate all asset images to file storage with 16:9 crop
    AppLogger.dataStore.info("📸 Starting asset image migration for seed data...")
    let imageMapping = ImageManager.shared.migrateAssetsFromDummies(dummyMovies)
    AppLogger.dataStore.info("✅ Image migration complete: \(imageMapping.count) images processed")
    
    // STEP 2: Seed database with migrated image URLs
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
                // Use migrated URL if available, otherwise use original
                let actorPhotoURL = imageMapping[a.photoURL] ?? a.photoURL
                let newActor = MovieActor(name: a.name, photoURL: actorPhotoURL, summary: a.summary)
                actors.append(newActor)
            }
        }
        
        // Use migrated URL if available, otherwise use original
        let moviePhotoURL = imageMapping[dummy.photoURL] ?? dummy.photoURL
        
        let movie = Movie(
            name: dummy.name,
            photoURL: moviePhotoURL,
            summary: dummy.summary,
            rating: dummy.rating,
            movieActors: actors,
            genres: genres,
            releaseYear: dummy.releaseYear
        )
        
        await movieViewModel.add(movie)
        await genreViewModel.fetchAll()
        await actorViewModel.fetchAll()
    }
    
    AppLogger.dataStore.info("✅ Database seeded with \(dummyMovies.count) movies (all images migrated to 16:9)")
}

