//
//  GenreListView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 6/4/2025.
//
import SwiftUI
import SwiftData

/**
 Horizontal scrollable list for genre selection with multi-select support.
 
 Displays genre chips with tap-to-select functionality. Used in movie creation/editing
 to select associated genres. Selection indicated by gradient color change (green→teal).
 
 ## Features
 - Horizontal scrolling list
 - "Add New Genre" button at start
 - Tap to toggle selection (gradient changes from orange→red to green→teal)
 - Context menu for Update/Delete
 - Capsule-shaped genre chips
 - Smooth selection animation
 */
struct GenreListView: View {
    
    @Environment(GenreViewModel.self) var genreViewModel
    @Environment(NavigationRouter.self) var router
    
    /// Binding to the set of selected genre IDs
    @Binding var selectedGenres: Set<String>
    
    
    var body: some View {
        
        HStack {
            ScrollView(.horizontal) {
                LazyHStack {
                    addNewGenre()
                    ForEach(genreViewModel.genres) { genre in
                        
                            card(genre)
                            .onTapGesture {
                                    toggleSelection(genre.id)
                            }
                            .contextMenu {
                                Button(role: .cancel) {
                                    router.path.append(.genreCreationView(genre))
                                } label: {
                                    Label("Update", systemImage: "arrow.clockwise")
                                }
                                .glassEffect()
                                
                                
                                Button(role: .destructive) {
                                    Task {
                                        await genreViewModel.delete(genre)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .glassEffect()
                            }
                    }
                }
            }
        }
    }
    
    /**
     Creates "Add New Genre" button.
     
     Displays blue plus button that navigates to genre creation form.
     */
    @ViewBuilder private func addNewGenre() -> some View {
        VStack {
            Text("+")
                .padding(5)
                .padding(.horizontal, 10)
                .cornerRadius(15)
                .overlay(
                    Capsule().stroke(lineWidth: 2)
                )
        }
        .padding(.horizontal, 10)
        .onTapGesture {
            router.path.append(.genreCreationView(nil))
        }
    }
    
    /**
     Creates genre chip with gradient color indication for selection.
     
     - Parameter genre: The genre to display
     
     Selected genres show green→teal gradient, unselected show orange→red gradient.
     Includes smooth animation on selection state changes.
     */
    @ViewBuilder private func card(_ genre: Genre) -> some View {
        let isSelected = selectedGenres.contains(genre.id)

        Text(genre.name)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: isSelected ? [.green, .teal] : [.orange, .red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: Capsule()
            )
            .shadow(
                color: isSelected ? .green.opacity(0.4) : .orange.opacity(0.4),
                radius: 2, x: 0, y: 2
            )
            .animation(.bouncy, value: isSelected)
            .shadow(color: .orange.opacity(0.4), radius: 4, x: 0, y: 2)
    }
    
    /**
     Toggles genre selection state.
     
     - Parameter id: The genre ID to toggle in selectedGenres set
     */
    private func toggleSelection(_ id: String) {
        if selectedGenres.contains(id) {
            selectedGenres.remove(id)
        } else {
            selectedGenres.insert(id)
        }
    }
}
