//
//  ActorListView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 6/4/2025.
//

import SwiftUI
import SwiftData

/**
 Horizontal scrollable list for actor selection with multi-select support.
 
 Displays actor cards with photos and favorite status. Used in movie creation/editing forms
 to allow selecting multiple actors. Selection indicated by green checkmark badge.
 
 ## Features
 - Horizontal scrolling list
 - "Add New Actor" button at the start
 - Tap to toggle selection (green checkmark badge in bottom-trailing corner)
 - Favorite heart icon (tap to toggle favourite)
 - Context menu for Update/Delete actions
 - Size class adaptation for images
 
 ## Selection Pattern
 Selected actors are tracked via a `Set<String>` binding containing actor IDs.
 Visual feedback provided through green checkmark badge on selected cards.
 */
struct ActorListView: View {
    
    @Environment(ActorViewModel.self) var actorViewModel
    @Environment(NavigationRouter.self) var router
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.imageManager) var imageManager
    
    /// Binding to the set of selected actor IDs
    @Binding var selectedActors: Set<String>
    
    /// Optional filtered list of actors (defaults to all actors from view model)
    var filteredActors: [MovieActor]? = nil
    
    /// Computed property that returns either filtered actors or all actors
    private var actorsToDisplay: [MovieActor] {
        filteredActors ?? actorViewModel.movieActors
    }
    
    var body: some View {
        
        ScrollView(.horizontal) {
            LazyHStack {
                addNewActor()
                    .onTapGesture {
                        router.path.append(.actorCreationView(nil))
                    }
                    .padding(.leading)
                ForEach(actorsToDisplay) { actor in
                    card(movieActor: actor)
                        .onTapGesture {
                            toggleSelection(actor.id)
                        }
                        .contextMenu {
                            Button(role: .cancel) {
                                router.path.append(.actorCreationView(actor))
                            } label: {
                                Label("Update", systemImage: "arrow.clockwise")
                            }
                            .glassEffect()
                                
                            Button(role: .destructive) {
                                Task {
                                    await actorViewModel.delete(actor)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .glassEffect()
                        }
                        .padding(5)
                }
            }
        }
    }
    
    /**
     Creates "Add New Actor" button card.
     
     Displays blue plus icon button that navigates to actor creation form.
     */
    @ViewBuilder private func addNewActor() -> some View {
        VStack {
            
            Image(systemName: "plus")
                .frame(
                    width: SizeClass.actorImageSize(for: sizeClass),
                    height: SizeClass.actorImageSize(for: sizeClass)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .background(
                    RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2)
                )
            
            Text("Add New Actor")
                .font(.caption2)
                .padding(5)
                .lineLimit(1)
                .frame(width: SizeClass.actorImageSize(for: sizeClass))
                .clipShape(Capsule())
            
        }
        
    }
    
    /**
     Creates actor card with photo, name, and favorite icon.
     
     - Parameter movieActor: The actor to display
     
     Selected actors show a green checkmark badge in the bottom-trailing corner.
     Heart icon in top-trailing corner toggles favorite status.
     */
    @ViewBuilder private func card(movieActor: MovieActor) -> some View {
        VStack {
            let isSelected = selectedActors.contains(movieActor.id)
            
            imageManager.loadSmart(filename: movieActor.photoURL!)
                .resizable()
                .scaledToFill()
                .frame(
                    width: SizeClass.actorImageSize(for: sizeClass),
                    height: SizeClass.actorImageSize(for: sizeClass)
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: isSelected ? .pink.opacity(0.4) : .clear, radius: 8, x: 0, y: 4)
                .overlay(alignment: .bottomTrailing) {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(
                            width: SizeClass.favIconSize(for: sizeClass),
                            height: SizeClass.favIconSize(for: sizeClass)
                        )
                        .foregroundStyle(.green)
                        .background(Circle().fill(.white))
                        .padding(8)
                        .symbolEffect(.bounce, value: isSelected)
                    }
                }
                .overlay(alignment: .topTrailing) {
                    Image(
                        systemName: movieActor.isFavourited ? "heart.fill" : "heart"
                    )
                    .resizable()
                    .frame(
                        width: SizeClass.favIconSize(for: sizeClass),
                        height: SizeClass.favIconSize(for: sizeClass)
                    )
                    .foregroundColor(movieActor.isFavourited ? .pink : .yellow)
                    .padding(8)
                    .symbolEffect(.bounce, value: movieActor.isFavourited)
                    .onTapGesture {
                        Task{
                            await actorViewModel.toggleFavourite(movieActor)
                        }
                    }
                }
            
            Text(movieActor.name)
                .font(.caption2)
                .padding(5)
                .lineLimit(1)
                .frame(width: SizeClass.actorImageSize(for: sizeClass))
                .clipShape(Capsule())
            
        }
    }
    
    /**
     Toggles actor selection state.
     
     Adds or removes actor ID from selectedActors set.
     
     - Parameter id: The actor ID to toggle
     */
    private func toggleSelection(_ id: String) {
        if selectedActors.contains(id) {
            selectedActors.remove(id)
        } else {
            selectedActors.insert(id)
        }
    }
}

