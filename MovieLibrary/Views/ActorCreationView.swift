//
//  ActorCreationView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 7/4/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ActorCreationView: View {
    
    @Environment(MovieViewModel.self) var movieViewModel
    @Environment(ActorViewModel.self) var actorViewModel
    @Environment(NavigationRouter.self) var router
    
    @State private var actorName: String = ""
    @State private var actorSummary: String = ""
    @State private var selectedMovies: Set<String> = []
    @State private var photoPickerItem: PhotosPickerItem? = nil
    @State private var photoData: Data? = nil
    
    var movieActor: MovieActor?
    
    var body: some View {
        
        VStack(spacing: 15) {
            
            photoInput()
            titleInput()
            summaryInput()
            if movieActor != nil {
                movieSelection()
            }
            
            Spacer()
            
            Button(action: {
                if let movieActor = movieActor {
                    updateMovieActor(movieActor)
                } else {
                    addMovieActor()
                }
                router.path.removeLast()
            }, label: {
                Text(movieActor == nil ? "Add new Actor" : "Update Actor")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            })
            .disabled(actorName.isEmpty || actorSummary.isEmpty || photoData == nil)
            
        }
        .onChange(of: photoPickerItem) {
            Task {
                if let imageData = try await photoPickerItem?.loadTransferable(type: Data.self) {
                    photoData = imageData
                } else {
                    print("Phtot failed")
                }
            }
        }
        .onAppear {
            if let movieActor = movieActor {
                actorName = movieActor.name
                actorSummary = movieActor.summary
                selectedMovies = Set(movieActor.movies.map { $0.id })
                photoData = ImageManager.loadImageDataSmart(filename: movieActor.photoURL!)
                
                
            }
        }
        
    }
    
    @ViewBuilder private func photoInput() -> some View {
        (photoData?.toImage ?? Image(systemName: "person.circle"))
            .resizable()
            .scaledToFit()
            .frame(width: 150)
            .clipShape(.circle)
        
        PhotosPicker("Select Image", selection: $photoPickerItem, matching: .images)
        
    }
    
    @ViewBuilder private func titleInput() -> some View {
        Text("Actor Name: ")
            .padding(.bottom, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        TextField("Enter Actor name", text: $actorName)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder private func summaryInput() -> some View {
        Text("Actor Bio: ")
            .padding(.bottom, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        TextField("Enter actor bio", text: $actorSummary)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder private func movieSelection() -> some View {
        Text("Select Movies")
            .padding(.bottom, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        ScrollView(.horizontal) {
            LazyHStack(spacing: 15) {
                ForEach(movieViewModel.movies) { movie in
                    let isSelected = selectedMovies.contains(movie.id)
                    
                    MovieCardView(movie: movie)
                        .onTapGesture {
                            toggleSelection(movie.id)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(isSelected ? Color.green : Color.clear, lineWidth: 5)
                        )
                }
                
            }
        }
    }
    
    private func toggleSelection(_ id: String) {
        if selectedMovies.contains(id) {
            selectedMovies.remove(id)
        } else {
            selectedMovies.insert(id)
        }
    }
    
    private func addMovieActor() {
        Task {
            var photoURL: String? = nil
            
            if let photoData = photoData {
                photoURL = ImageManager.saveImageToDocuments(data: photoData) ?? ""
            }
            
            let newActor = MovieActor(name: actorName, photoURL: photoURL ?? "", summary: actorSummary)
            await actorViewModel.add(newActor)
        }
    }
    
    private func updateMovieActor(_ movieActor: MovieActor) {
        Task {
            let movies: [Movie] = movieViewModel.movies.filter { movie in selectedMovies.contains { $0 == movie.id } }
            await actorViewModel.update(name: actorName, summary: actorSummary, movies: movies, movieActor: movieActor)
        }
    }
}


