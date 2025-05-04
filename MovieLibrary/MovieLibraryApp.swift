//
//  MovieLibraryApp.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import SwiftData

enum UserDefaultsKeys {
    static let isDataSavedToDatabase: String = "IS_DATA_SAVED_TO_DATABASE"
}

enum AppState {
    case landing
    case storingToDatabase
    case ready
}

@main
struct MovieLibraryApp: App {
    
    @AppStorage(UserDefaultsKeys.isDataSavedToDatabase) var isDataSavedToDatabase: Bool = false
    
    @State private var appState: AppState = .landing
    
    @State private var movieViewModel: MovieViewModel = MovieViewModel()
    @State private var genreViewModel: GenreViewModel = GenreViewModel()
    @State private var actorViewModel: ActorViewModel = ActorViewModel()
    @State private var globalSearchViewModel: GlobalSearchViewModel = GlobalSearchViewModel()

    
    var body: some Scene {
        WindowGroup {
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

extension ModelContainer {
    static var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Movie.self, MovieActor.self, Genre.self
        ])
        
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
}
