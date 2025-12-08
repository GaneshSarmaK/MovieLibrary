//
//  ActorCreationView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 7/4/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

/**
 Modern form view for creating new actors or editing existing ones.
 
 Features vibrant design with glass cards, colorful accents, and clean layout.
 Supports both creation and editing modes with movie selection.
 
 ## Form Sections
 - Hero photo picker with large circular preview
 - Name and biography cards with glass effect
 - Movie selection with scrollable cards
 
 ## Design Features
 - Pink gradient header
 - Glass material cards with shadows
 - Large circular photo preview
 - Gradient submit button
 */
struct ActorCreationView: View {
    
    @Environment(\.appLogger) var logger
    @Environment(MovieViewModel.self) var movieViewModel
    @Environment(ActorViewModel.self) var actorViewModel
    @Environment(NavigationRouter.self) var router
    @Environment(\.imageManager) var imageManager
    
    /// Actor name input
    @State private var actorName: String = ""
    /// Actor biography/summary input
    @State private var actorSummary: String = ""
    /// Set of selected movie IDs
    @State private var selectedMovies: Set<String> = []
    /// Photo picker item for selecting actor photo
    @State private var photoPickerItem: PhotosPickerItem? = nil
    /// Raw image data from selected photo
    @State private var photoData: Data? = nil
    
    var movieActor: MovieActor?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero photo section
                heroPhotoSection()
                
                // Form cards
                VStack(spacing: 16) {
                    // Basic info section
                    basicInfoSection()
                    
                    // Movie selection (only in edit mode or if movies selected)
                    if movieActor != nil || !selectedMovies.isEmpty {
                        movieSelectionSection()
                    }
                    
                    // Submit button
                    submitButton()
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle(movieActor == nil ? "New Actor" : "Edit Actor")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let movieActor = movieActor {
                actorName = movieActor.name
                actorSummary = movieActor.summary
                selectedMovies = Set(movieActor.movies.map { $0.id })
                photoData = imageManager.loadDataSmart(filename: movieActor.photoURL!)
            }
        }
        .onChange(of: photoPickerItem) {
            Task {
                if let imageData = try await photoPickerItem?.loadTransferable(type: Data.self) {
                    photoData = imageData
                } else {
                    logger.warning("Failed to load photo from picker")
                }
            }
        }
    }
    
    // MARK: - Hero Photo Section
    
    @ViewBuilder private func heroPhotoSection() -> some View {
        VStack(spacing: 16) {
            // Photo preview
            ZStack {
                if let photoData = photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        .shadow(color: .pink.opacity(0.4), radius: 15, x: 0, y: 8)
                } else {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 200, height: 200)
                        .overlay {
                            VStack(spacing: 12) {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.pink.gradient)
                                Text("No Photo Selected")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
            }
            
            // Photo picker button
            PhotosPicker(selection: $photoPickerItem, matching: .images) {
                Label("Select Photo", systemImage: "photo.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .gradientBackground(.pink, .purple, shape: Capsule())
                    .shadow(color: .pink.opacity(0.4), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.top)
    }
    
    // MARK: - Basic Info Section
    
    @ViewBuilder private func basicInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Label("Actor Information", systemImage: "person.fill")
                .font(.headline)
                .gradientForeground(.pink, .orange)
            
            // Name field
            VStack(alignment: .leading, spacing: 8) {
                Text("Actor Name")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                
                TextField("Enter name", text: $actorName)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            
            // Biography field
            VStack(alignment: .leading, spacing: 8) {
                Text("Biography")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                
                TextField("Enter biography", text: $actorSummary, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(3...6)
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .pink.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Movie Selection Section
    
    @ViewBuilder private func movieSelectionSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(movieActor != nil ? "Movies" : "Select Movies", systemImage: "film.fill")
                .font(.headline)
                .foregroundStyle(.blue)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) {
                    ForEach(movieActor != nil ? movieActor!.movies : movieViewModel.movies) { movie in
                        let isSelected = selectedMovies.contains(movie.id)
                        
                        MovieCardView(movie: movie)
                            .onTapGesture {
                                toggleSelection(movie.id)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 5)
                            )
                    }
                }
                .padding(.vertical, 4)
            }
            .contentMargins(.horizontal, 5, for: .scrollContent)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .blue.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Submit Button
    
    @ViewBuilder private func submitButton() -> some View {
        Button {
            if let movieActor = movieActor {
                updateMovieActor(movieActor)
            } else {
                addMovieActor()
            }
            router.path.removeLast()
        } label: {
            let isDisabled = actorName.isEmpty || actorSummary.isEmpty || photoData == nil
            Label(movieActor == nil ? "Create Actor" : "Update Actor", 
                  systemImage: movieActor == nil ? "plus.circle.fill" : "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .gradientBackground(
                    isDisabled ? .gray : .pink,
                    isDisabled ? .gray : .purple,
                    shape: Capsule()
                )
                .shadow(
                    color: (isDisabled ? Color.gray : Color.pink).opacity(0.4),
                    radius: 10, x: 0, y: 5
                )
        }
        .disabled(actorName.isEmpty || actorSummary.isEmpty || photoData == nil)
    }
    
    // MARK: - Helper Methods
    
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
                photoURL = imageManager.save(photoData) ?? ""
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
