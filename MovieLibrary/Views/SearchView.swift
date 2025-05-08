//
//  SearchView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

/**
 Global search view for finding movies and actors across the library.
 
 Provides a searchable interface with debounced search (0.5s delay) to query movies and actors.
 Displays results in grid layouts with conditional rendering for actors.
 
 ## Features
 - Searchable text field with live search
 - Debounced search (500ms) to prevent excessive queries
 - Automatic cancellation of previous search tasks
 - Movie grid (always visible)
 - Actor grid (visible only when search has results)
 - Data refresh on view appear/disappear
 
 ## Search Behavior
 - Empty search: Shows all movies and actors
 - With text: Performs partial string match across names and summaries
 - Debouncing: Waits 0.5s after last keystroke before searching
 
 ## Implementation Note
 Uses Task cancellation pattern for debouncing search input.
 */
struct SearchView: View {
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(ActorViewModel.self) var actorViewModel
    @Environment(MovieViewModel.self) var movieViewModel
    @Environment(GenreViewModel.self) var genreViewModel
    @Environment(GlobalSearchViewModel.self) var globalSearchViewModel
    @Environment(NavigationRouter.self) var router

    @State private var searchText: String = ""
    @State private var task: Task<Void, Error>? = nil
    
    var body: some View {
        VStack {
            
//            controlPanel()
            
            Text("Movies")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()

            MovieGridView()
            
            Divider()
            
            if !searchText.isEmpty && globalSearchViewModel.movieActors.count > 0{
                    Text("Actors")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .animation(.easeInOut)
                    
                    ActorGridView()
                        .frame(height: SizeClass.imageSize(for: sizeClass) + 50)
                        .animation(.easeInOut)
            }
   
        }
        .searchable(text: $searchText, prompt: "Type to search")
        .onChange(of: searchText) {
            searchMovies(searchParam: searchText)
        }
        .onAppear {
            if searchText.isEmpty {
                Task {
                    await globalSearchViewModel.fetchAll()
                }
            }
            
        }
        .onDisappear() {
            Task {
                await movieViewModel.fetchAll()
                await genreViewModel.fetchAll()
                await actorViewModel.fetchAll()
                await globalSearchViewModel.fetchAll()
            }
        }
        
        
        
    }
    
    /**
     Performs debounced search with 0.5 second delay.
     
     Cancels any existing search task and creates a new one. Waits 500ms before executing
     the actual search to prevent excessive queries while user is typing.
     
     - Parameter searchParam: The search string to query
     */
    func searchMovies(searchParam: String) {
        // Cancel previous search task if still running
        task?.cancel()
        task = nil
        let newTask = Task {
            // Debounce: wait 0.5s before searching
            try await Task.sleep(for: .seconds(0.5))
                if !searchParam.isEmpty {
                    await globalSearchViewModel.fetchByPartialString(searchParam)
                } else {
                    await globalSearchViewModel.fetchAll()
                }

            }
        task = newTask
    }
    
    
}



/**
 
 private func fetchMoviesForSelection() {
     if searchText.isEmpty {
         Task {
             await movieViewModel.fetchAll()
         }
     } else {
         Task {
             await movieViewModel.fetch(filters: [.genres(genres: selectedGenres), .movieActor(movieActors: selectedActors), .name(name: searchText)])
         }
     }
 }
 
 @ViewBuilder private func controlPanel() -> some View {
     HStack {
         Button {
             withAnimation {
                 areMovieActorsVisible.toggle()
             }
         } label: {
             Text(areMovieActorsVisible ? "Hide Actors" : "Show Actors")
                 .padding()
                 .background(Color.blue)
                 .foregroundColor(.white)
                 .clipShape(Capsule())
         }
         
         Button {
             withAnimation {
                 areGenresVisible.toggle()
             }
         } label: {
             Text(areGenresVisible ? "Hide Genres" : "Show Genres")
                 .padding()
                 .background(Color.blue)
                 .foregroundColor(.white)
                 .clipShape(Capsule())
         }
         
         Spacer()
         
         Button(action: {
             withAnimation(.easeInOut(duration: 0.2)) {
                 selectedActors = []
                 selectedGenres = []
             }
             
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                 withAnimation(.easeOut(duration: 0.2)) {
                     areGenresVisible = false
                     areMovieActorsVisible = false
                 }
             }
             
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                 Task {
                     await movieViewModel.fetchAll()
                 }
             }
             
         }, label: {
             Text("Clear all")
                 .padding()
                 .foregroundColor(.red)
         })
     }
     .padding(15)
 }
 
 */
