//
//  MovieLibraryApp.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import SwiftData

/**
 User defaults keys used throughout the app.
 
 Centralizing keys here prevents typos and makes refactoring easier.
 */
enum UserDefaultsKeys {
    /// Key for storing whether the dummy data has been seeded to the database
    static let isDataSavedToDatabase: String = "IS_DATA_SAVED_TO_DATABASE"
}

/**
 Application lifecycle states for the MovieLibrary app.
 
 The app progresses through these states on launch:
 1. **landing**: Initial splash screen displayed briefly
 2. **storingToDatabase**: Database seeding in progress (first launch only)
 3. **ready**: App fully initialized and ready for user interaction
 */
enum AppState {
    /// Initial landing screen state
    case landing
    
    /// Database population in progress
    case storingToDatabase
    
    /// App ready for normal operation
    case ready
}

/**
 The main entry point for the MovieLibrary iOS application.
 
 This struct sets up the SwiftUI app structure, manages initialization state,
 and coordinates the database seeding process on first launch. It uses a state machine
 approach to manage the app lifecycle.
 
 ## Architecture
 - Uses `@Observable` view models for state management
 - SwiftData for persistence with a shared model container
 - `@AppStorage` to track one-time database seeding
 
 ## Initialization Flow
 1. App launches showing "Hey, Movie buff!!" (landing state)
 2. After 0.5s, transitions to `storingToDatabase` or `ready` based on UserDefaults
 3. If first launch, populates database from DummyData.json
 4. Transitions to ready state showing LandingView with full functionality
 */
@main
struct MovieLibraryApp: App {
    
    /// Persistent flag indicating whether dummy data has been loaded (survives app restarts)
    @AppStorage(UserDefaultsKeys.isDataSavedToDatabase) var isDataSavedToDatabase: Bool = false
    
    /// Current application lifecycle state
    @State private var appState: AppState = .landing
    
    /// View model managing movie data and operations
    @State private var movieViewModel: MovieViewModel = MovieViewModel()
    
    /// View model managing genre data and operations
    @State private var genreViewModel: GenreViewModel = GenreViewModel()
    
    /// View model managing actor data and operations
    @State private var actorViewModel: ActorViewModel = ActorViewModel()
    
    /// View model managing global search across all entities
    @State private var globalSearchViewModel: GlobalSearchViewModel = GlobalSearchViewModel()

    
//    init() {
//        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
//            Task { @MainActor in
//                enableLayoutDebugBorders()
//            }
//        }
//    }

    var body: some Scene {
        
        WindowGroup {
            
            //Display a intermediate page before checking if data has been seeded. If not then seed data and show Landing view
            Group {
                switch appState {
                    case .landing:
                        Text("Hey, Moview buff!!")
                    case .storingToDatabase:
                        Text("Storing movies")
                            .font(.headline)
                            .onAppear {
                                if !isDataSavedToDatabase {
                                    saveMoviesToDatabase()
                                } else {
                                    appState = .ready
                                }
                            }
                    case .ready:
                        LandingView()
                            .environment(movieViewModel)
                            .environment(genreViewModel)
                            .environment(actorViewModel)
                            .environment(globalSearchViewModel)
                            .environment(\.appLogger, AppLogger.shared)
                            .environment(\.imageManager, ImageManager.shared)

                }
            }
            .animation(.default, value: appState)
            .onAppear {
                Task {
                    try? await Task.sleep(for: .seconds(0.5))
                    appState = isDataSavedToDatabase ? .ready : .storingToDatabase
                }
                
            }
        }
        .modelContainer(.sharedModelContainer)
    }
    
    /**
     Populates the database with dummy movie data on first app launch.
     
     This method runs asynchronously with user-initiated priority. It loads data from
     DummyData.json, creates all necessary entities, and updates the persistent flag
     to prevent re-seeding on subsequent launches.
     
     On success, the app state transitions to `.ready` and the main UI is displayed.
     On failure, an assertion is triggered (development only).
     */
    private func saveMoviesToDatabase() {
        Task(priority: .userInitiated) {
            do {
                try await saveDummyMoviesToDatabase(genreViewModel: genreViewModel, movieViewModel: movieViewModel, actorViewModel: actorViewModel)
                try? await Task.sleep(for: .seconds(0.5))
                isDataSavedToDatabase = true
                appState = .ready
            } catch {
                assertionFailure("Failed to save / populate movie to Database")
            }
        }
    }
}

/**
 Extension providing a shared SwiftData model container for the entire app.
 
 This container is configured with all model types and set up for persistent storage.
 The container is created once and shared across all data sources.
 
 ## Configuration
 - Schema includes: Movie, MovieActor, and Genre models
 - Storage: Persistent (not in-memory)
 - Location: Logged to console on initialization
 
 ## Usage
 Data sources inject this container through the `@ModelActor` macro:
 ```swift
 @ModelActor
 final actor MovieDataSource {
     // Automatically gets modelContainer and modelContext
 }
 ```
 */
extension ModelContainer {
    /// The shared model container used throughout the app
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Movie.self, MovieActor.self, Genre.self
        ])
        
        // Log the database location for debugging
        AppLogger.main.info("Database location: \(URL.applicationSupportDirectory.path(percentEncoded: false))")
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
