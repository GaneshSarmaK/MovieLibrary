//
//  GenreCreationView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 7/4/2025.
//

import SwiftUI
import SwiftData

/**
 Modern form view for creating new genres or editing existing ones.
 
 Features clean design with glass cards and green accent colors.
 Simpler than Movie/Actor forms as genres don't require photos.
 
 ## Form Sections
 - Genre icon preview
 - Name and summary cards with glass effect
 - Movie selection (edit mode only)
 
 ## Design Features
 - Green gradient header
 - Glass material cards with shadows
 - Film icon preview
 - Gradient submit button
 */
struct GenreCreationView: View {
    
    @Environment(MovieViewModel.self) var movieViewModel
    @Environment(GenreViewModel.self) var genreViewModel
    @Environment(NavigationRouter.self) var router
    
    /// Genre name input
    @State private var genreName: String = ""
    /// Genre summary/description input
    @State private var genreSummary: String = ""
    /// Set of selected movie IDs
    @State private var selectedMovies: Set<String> = []
    
    var genre: Genre?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero icon section
                heroIconSection()
                
                // Form cards
                VStack(spacing: 16) {
                    // Basic info section
                    basicInfoSection()
                    
                    // Movie selection (only in edit mode)
                    if genre != nil {
                        movieSelectionSection()
                    }
                    
                    // Submit button
                    submitButton()
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .navigationTitle(genre == nil ? "New Genre" : "Edit Genre")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let genre = genre {
                genreName = genre.name
                genreSummary = genre.summary
                selectedMovies = Set(genre.movies.map { $0.id })
            }
        }
    }
    
    // MARK: - Hero Icon Section
    
    @ViewBuilder private func heroIconSection() -> some View {
        VStack(spacing: 16) {
            // Large film icon
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 160, height: 160)
                    .shadow(color: .green.opacity(0.3), radius: 15, x: 0, y: 8)
                
                Image(systemName: "film.stack")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.green, .teal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text("Genre")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(.top)
    }
    
    // MARK: - Basic Info Section
    
    @ViewBuilder private func basicInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            Label("Genre Information", systemImage: "info.circle.fill")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green, .teal],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            // Name field
            VStack(alignment: .leading, spacing: 8) {
                Text("Genre Name")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                
                TextField("Enter name", text: $genreName)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            
            // Summary field
            VStack(alignment: .leading, spacing: 8) {
                Text("Description")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                
                TextField("Enter description", text: $genreSummary, axis: .vertical)
                    .textFieldStyle(.plain)
                    .lineLimit(3...6)
                    .padding(12)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .green.opacity(0.1), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Movie Selection Section
    
    @ViewBuilder private func movieSelectionSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Movies in this Genre", systemImage: "film.fill")
                .font(.headline)
                .foregroundStyle(.orange)
            
            ScrollView(.horizontal, showsIndicators: false) {
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
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .orange.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Submit Button
    
    @ViewBuilder private func submitButton() -> some View {
        Button {
            if let genre = genre {
                updateGenre(genre)
            } else {
                addGenre()
            }
            router.path.removeLast()
        } label: {
            Label(genre == nil ? "Create Genre" : "Update Genre", 
                  systemImage: genre == nil ? "plus.circle.fill" : "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: genreName.isEmpty || genreSummary.isEmpty ? [Color.gray] : [Color.green, Color.teal],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: Capsule()
                )
                .shadow(
                    color: (genreName.isEmpty || genreSummary.isEmpty ? Color.gray : Color.green).opacity(0.4),
                    radius: 10, x: 0, y: 5
                )
        }
        .disabled(genreName.isEmpty || genreSummary.isEmpty)
    }
    
    // MARK: - Helper Methods
    
    private func toggleSelection(_ id: String) {
        if selectedMovies.contains(id) {
            selectedMovies.remove(id)
        } else {
            selectedMovies.insert(id)
        }
    }
    
    private func addGenre() {
        Task {
            let movies: [Movie] = movieViewModel.movies.filter { movie in selectedMovies.contains { $0 == movie.id } }
            let newGenre = Genre(name: genreName, summary: genreSummary, movies: movies)
            await genreViewModel.add(newGenre)
        }
    }
    
    private func updateGenre(_ genre: Genre) {
        Task {
            let movies: [Movie] = movieViewModel.movies.filter { movie in selectedMovies.contains { $0 == movie.id } }
            await genreViewModel.update(name: genreName, summary: genreSummary, movies: movies, genre: genre)
        }
    }
}
