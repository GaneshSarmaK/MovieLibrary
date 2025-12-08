//
//  MovieCreationView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 7/4/2025.
//

import SwiftUI
import SwiftData
import PhotosUI

/**
 Modern form view for creating new movies or editing existing ones.
 
 Features a vibrant design with glass cards, colorful section headers, and smooth animations.
 Supports both creation and update modes with clean visual hierarchy.
 
 ## Form Sections
 - Hero photo picker with large preview
 - Title and summary cards with glass effect
 - Year and rating in side-by-side cards
 - Searchable actor selection
 - Multi-select genre chips
 
 ## Design Features
 - Gradient section headers
 - Glass material cards with shadows
 - Icon-based labels
 - Colorful accent colors
 - Smooth animations
 */
struct MovieCreationView: View {
    
    @Environment(\.appLogger) var logger
    @Environment(ActorViewModel.self) var actorViewModel
    @Environment(MovieViewModel.self) var movieViewModel
    @Environment(GenreViewModel.self) var genreViewModel
    @Environment(GlobalSearchViewModel.self) var globalSearchViewModel
    @Environment(NavigationRouter.self) var router
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.imageManager) var imageManager
    
    /// Photo picker item for selecting movie poster
    @State private var photoPickerItem: PhotosPickerItem? = nil
    /// Raw image data from selected photo
    @State private var photoData: Data? = nil
    /// Set of selected genre IDs
    @State private var selectedGenres: Set<String> = []
    /// Set of selected actor IDs
    @State private var selectedActors: Set<String> = []
    /// Movie title input
    @State private var movieTitle: String = ""
    /// Movie summary/description input
    @State private var movieSummary: String = ""
    /// Release year (defaults to current year)
    @State private var releaseYear: Int = Calendar.current.component(.year, from: .now)
    /// Movie rating (1-5 stars)
    @State private var rating: Int = 0
    /// Tracks which star to animate on tap
    @State private var bounceStarIndex: Int? = nil
    /// Search filter text for actors
    @State private var actorSearchText: String = ""
    /// Debounce task for actor search
    @State private var task: Task<Void, Error>? = nil
    /// Filtered list of actors based on search text
    @State private var filteredActors: [MovieActor] = []
    
    var movie: Movie?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero photo section
                heroPhotoSection()
                
                // Form cards
                VStack(spacing: 16) {
                    // Basic info section
                    basicInfoSection()
                    
                    // Stats section (year + rating)
                    statsSection()
                    
                    // Actor selection section
                    actorSelectionSection()
                    
                    // Genre selection section
                    genreSelectionSection()
                    
                    // Submit button
                    submitButton()
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle(movie == nil ? "New Movie" : "Edit Movie")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let movie = movie {
                movieTitle = movie.name
                movieSummary = movie.summary
                releaseYear = movie.releaseYear
                rating = movie.rating
                selectedActors = Set(movie.movieActors.map { $0.id })
                selectedGenres = Set(movie.genres.map { $0.id })
                photoData = imageManager.loadDataSmart(filename: movie.photoURL!)
                logger.debugLog("Loaded movie for editing: \(movie.id)")
            }
            
            filterActors(searchText: "")
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
//                    Image(uiImage: uiImage)
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 300, height: 300)
//                        .clipShape(RoundedRectangle(cornerRadius: 20))
//                        .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)
//                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(.rect(cornerRadius: 10))
                        .shadow(color: .blue.opacity(0.3), radius: 15, x: 0, y: 8)

                } else {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .frame(width: 300, height: 300)
                        .overlay {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 50))
                                    .foregroundStyle(.blue.gradient)
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
                    .gradientBackground(.blue, .purple, shape: Capsule())
                    .shadow(color: .blue.opacity(0.4), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.top)
    }
    
    // MARK: - Basic Info Section
    
    @ViewBuilder private func basicInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Label("Basic Information", systemImage: "info.circle.fill")
                .font(.headline)
                .gradientForeground(.blue, .cyan)
            
            // Title field
            VStack(alignment: .leading, spacing: 8) {
                Text("Movie Title")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                
                TextField("Enter title", text: $movieTitle)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            
            // Summary field
            VStack(alignment: .leading, spacing: 8) {
                Text("Summary")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                
                TextField("Enter summary", text: $movieSummary, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(3...6)
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .blue.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Stats Section
    
    @ViewBuilder private func statsSection() -> some View {
        HStack(spacing: 16) {
            // Year picker card
            VStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundStyle(.orange)
                
                Picker("Year", selection: $releaseYear) {
                    ForEach(Array(1900...Calendar.current.component(.year, from: Date())), id: \.self) { year in
                        Text(String(year)).tag(year)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                
                Text("Release Year")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: .orange.opacity(0.2), radius: 8, x: 0, y: 4)
            
            // Rating card
            VStack(spacing: 12) {
                Text("Rating")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .font(.title3)
                            .foregroundStyle(index <= rating ? .yellow : .gray.opacity(0.3))
                            .onTapGesture {
                                withAnimation(.bouncy) {
                                    rating = index
                                    bounceStarIndex = index
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                    bounceStarIndex = nil
                                }
                            }
                            .symbolEffect(.rotate, options: .speed(3), value: index == bounceStarIndex ? 1 : 0)
                    }
                }
                
                Text("Tap to rate")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: .yellow.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .frame(height: 140)
    }
    
    // MARK: - Actor Selection Section
    
    @ViewBuilder private func actorSelectionSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Cast", systemImage: "person.2.fill")
                .font(.headline)
                .foregroundStyle(.pink)
            
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search actors...", text: $actorSearchText)
                    .textFieldStyle(.plain)
                    .onChange(of: actorSearchText) { _, _ in
                        filterActors(searchText: actorSearchText)
                    }
                
                if !actorSearchText.isEmpty {
                    Button {
                        actorSearchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10))
            
            // Actor list
            ActorListView(
                selectedActors: $selectedActors,
                filteredActors: filteredActors
            )
            .frame(height: SizeClass.actorImageSize(for: sizeClass) + 60)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .pink.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    /**
     Filters actors based on search text with debouncing.
     
     Cancels any pending search task and waits 0.5 seconds before executing
     the search to avoid excessive filtering while user is typing.
     
     - Parameter searchText: The search query to filter actors by name
     */
    private func filterActors(searchText: String) {
        task?.cancel()
        task = nil
        let newTask = Task {
            // Debounce: wait 0.5s before searching
            try await Task.sleep(for: .seconds(0.5))
                if searchText.isEmpty {
                    await actorViewModel.fetchAll()
                } else {
                    await actorViewModel.fetch(filters: [.name(name: searchText)])
                }
            self.filteredActors = actorViewModel.movieActors

            }
        task = newTask
    }
    
    // MARK: - Genre Selection Section
    
    @ViewBuilder private func genreSelectionSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Genres", systemImage: "film")
                .font(.headline)
                .foregroundStyle(.green)
            
            GenreListView(selectedGenres: $selectedGenres)
                .frame(height: 50)
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .green.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Submit Button
    
    @ViewBuilder private func submitButton() -> some View {
        Button {
            if let movie = movie {
                updateMovie(movie: movie)
            } else {
                addMovie()
            }
            router.path.removeLast()
        } label: {
            let isDisabled = movieTitle.isEmpty || movieSummary.isEmpty || photoData == nil
            Label(movie == nil ? "Create Movie" : "Update Movie", systemImage: movie == nil ? "plus.circle.fill" : "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .gradientBackground(
                    isDisabled ? .gray : .green,
                    isDisabled ? .gray : .blue,
                    shape: Capsule()
                )
                .shadow(
                    color: (isDisabled ? Color.gray : Color.green).opacity(0.4),
                    radius: 10, x: 0, y: 5
                )
        }
        .disabled(movieTitle.isEmpty || movieSummary.isEmpty || photoData == nil)
    }
}

// MARK: - Business Logic

extension MovieCreationView {
    
    func updateMovie(movie: Movie) {
        Task {
            var photoURL: String? = nil
            
            if let photoData = photoData {
                photoURL = imageManager.save(photoData) ?? ""
            }
            
            let genres: [Genre] = genreViewModel.genres.filter { genre in selectedGenres.contains { $0 == genre.id } }
            let movieActors: [MovieActor] = actorViewModel.movieActors.filter { movieActor in selectedActors.contains { $0 == movieActor.id } }
            
            await movieViewModel.update(name: movieTitle, summary: movieSummary, photoURL: photoURL ?? "", rating: rating, movieActors: movieActors, genres: genres, releaseYear: releaseYear, movie: movie)
        }
    }
    
    func addMovie() {
        Task {
            var photoURL: String? = nil
            
            if let photoData = photoData {
                photoURL = imageManager.save(photoData) ?? ""
            }
            
            let genres: [Genre] = genreViewModel.genres.filter { genre in selectedGenres.contains { $0 == genre.id } }
            let movieActors: [MovieActor] = actorViewModel.movieActors.filter { movieActor in selectedActors.contains { $0 == movieActor.id } }

            let newMovie = Movie(name: movieTitle, photoURL: photoURL ?? "" , summary: movieSummary, rating: rating, movieActors: movieActors, genres: genres, releaseYear: releaseYear)
            
            await movieViewModel.add(newMovie)
            await globalSearchViewModel.fetchAll()
        }
    }
}
