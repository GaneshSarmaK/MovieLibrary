//
//  LandingView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 7/4/2025.
//

import SwiftUI
import SwiftData
import UIKit

/**
 Main landing page of the MovieLibrary app.
 
 Serves as the root view containing the navigation stack and coordinating all child views.
 Displays the hero section, genre sections, and provides access to search and movie creation.
 
 ## Features
 - Navigation stack with custom router
 - Hero section with featured content
 - Genre-based movie organization
 - Quick access toolbar (Add movie, Search)
 - Automatic data refresh on navigation return
 
 ## Navigation Destinations
 Handles routing to:
 - Movie creation/edit forms
 - Actor creation/edit forms
 - Genre creation/edit forms
 - Movie detail views
 - Global search
 
 ## Data Management
 Refreshes all view models when:
 - View first appears
 - User returns to landing (navigation path becomes empty)
 */
struct LandingView: View {
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.scenePhase) var scenePhase
    @Environment(ActorViewModel.self) var actorViewModel
    @Environment(MovieViewModel.self) var movieViewModel
    @Environment(GenreViewModel.self) var genreViewModel
    @Environment(GlobalSearchViewModel.self) var globalSearchViewModel
    
    @State private var router: NavigationRouter = .init()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                VStack {
                    HeroSectionView()
                        .padding(.top, -10)
                        
                    
                    GenreSectionView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        router.path.append(.movieCreationView(nil))
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .glassEffect()
                }
                
                ToolbarItem(placement: .topBarTrailing){
                    Button {
                        router.path.append(.searchView)
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                    .glassEffect()
                }
            }
//            .toolbarVisibility(.hidden, for: .navigationBar)
            
//            .overlay(alignment: .topTrailing) {
//                HStack {
//                    Button {
//                        router.path.append(.movieCreationView(nil))
//                    } label: {
//                        Image(systemName: "plus")
//                            .padding(15)
//                    }
//                    
//                    Button {
//                        router.path.append(.searchView)
//                    } label: {
//                        Image(systemName: "magnifyingglass")
//                            .padding(15)
//                    }
//                }
//            }
            // Route to appropriate view based on destination type
            .navigationDestination(for: NavigationDestinations.self) { destination in
                switch(destination) {
                    case .movieCreationView(let movie):
                        MovieCreationView(movie: movie)
                    case .genreCreationView(let genre):
                        GenreCreationView(genre: genre)
                    case .actorCreationView(let movieActor):
                        ActorCreationView(movieActor: movieActor)
                    case .movieView(let movie):
                        MovieView(movie: movie!)
                    case .searchView:
                        SearchView()
                }
            }
        }
        .environment(router)
        .onAppear {
            refreshData()
        }
        .onChange(of: router.path.count) { oldValue, newValue in
            // Refresh data when user navigates back to landing
            if router.path.isEmpty {
                refreshData()
            }
        }
    }
    
    /// Refreshes all data from view models
    private func refreshData() {
        Task {
            await movieViewModel.fetchAll()
            await genreViewModel.fetchAll()
            await actorViewModel.fetchAll()
            await globalSearchViewModel.fetchAll()
        }
    }
    
    
}

#Preview {
    LandingView()
        .environment(ActorViewModel())
        .environment(GenreViewModel())
        .environment(MovieViewModel())
        .environment(GlobalSearchViewModel())
}

