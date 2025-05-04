//
//  GenreHorizontalView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 6/4/2025.
//
import SwiftUI
import SwiftData

struct GenreListView: View {
    
    @Environment(GenreViewModel.self) var genreViewModel
    @Environment(NavigationRouter.self) var router
    
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
                                
                                Button(role: .destructive) {
                                    Task {
                                        await genreViewModel.delete(genre)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
    }
    
    @ViewBuilder private func addNewGenre() -> some View {
        VStack {
            Text("+")
                .padding(5)
                .padding(.horizontal, 10)
                .background(.red)
                .cornerRadius(15)
                .overlay(
                    Capsule().stroke(Color.gray, lineWidth: 2)
                )
        }
        .padding(.horizontal, 10)
        .onTapGesture {
            router.path.append(.genreCreationView(nil))
        }
    }
    
    @ViewBuilder private func card(_ genre: Genre) -> some View {
        let isSelected = selectedGenres.contains(genre.id)

        Text("\(genre.name)")
            .padding(5)
            .padding(.horizontal, 10)
            .background(.gray.opacity(0.5))
            .clipShape(Capsule())
            .overlay {
                Capsule().stroke(Color.gray, lineWidth: 2)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 5)
            }
            .padding(.horizontal, 5)
    }
    
    private func toggleSelection(_ id: String) {
        if selectedGenres.contains(id) {
            selectedGenres.remove(id)
        } else {
            selectedGenres.insert(id)
        }
    }
}
