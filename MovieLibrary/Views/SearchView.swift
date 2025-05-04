//
//  SearchView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 5/4/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct SearchView: View {
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(GlobalSearchViewModel.self) var globalSearchViewModel
    @Environment(NavigationRouter.self) var router

    @State private var searchText: String = ""

    
    var body: some View {
        VStack {
            
//            controlPanel()
            
            MovieGridView()
            
            Divider()
            
            ActorGridView()
            
//            HStack {
//                Button {
//                    router.path.append(.movieCreationView(nil))
//                } label: {
//                    Text("Add new Movie")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .clipShape(Capsule())
//                }
//                
//                Button {
//                    router.path.append(.actorCreationView(nil))
//                } label: {
//                    Text("Add new Actor")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .clipShape(Capsule())
//                }
//            }
            
            
        }
        .searchable(text: $searchText, prompt: "Type to search for movies")
        .onChange(of: searchText) {
            searchMovies(searchParam: searchText)
        }
        .onAppear {
            Task {
                await globalSearchViewModel.fetchAll()
            }
            
        }
        
        
        
    }
    
    func searchMovies(searchParam: String) {

            Task {
                
                if !searchParam.isEmpty {
                    await globalSearchViewModel.fetchByPartialString(searchParam)
                } else {
                    await globalSearchViewModel.fetchAll()
                }
                
                print(globalSearchViewModel.movies.count)
                print(globalSearchViewModel.movieActors.count)

            }
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
