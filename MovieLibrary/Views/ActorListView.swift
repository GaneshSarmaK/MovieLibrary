//
//  ActorListView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 6/4/2025.
//

import SwiftUI
import SwiftData

struct ActorListView: View {
    
    @Environment(ActorViewModel.self) var actorViewModel
    @Environment(NavigationRouter.self) var router
    @Environment(\.horizontalSizeClass) var sizeClass
    
    @Binding var selectedActors: Set<String>
    
    var body: some View {
        
        ScrollView(.horizontal) {
            LazyHStack {
                ForEach(actorViewModel.movieActors) { actor in
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
                            
                            Button(role: .destructive) {
                                Task {
                                    await actorViewModel.delete(actor)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .padding(15)
                }
            }
        }
    }
    
    @ViewBuilder private func card(movieActor: MovieActor) -> some View {
        VStack {
            let isSelected = selectedActors.contains(movieActor.id)
            
            ImageManager.loadImageSmart(filename: movieActor.photoURL!)
                .resizable()
                .scaledToFill()
                .frame(width: SizeClass.actorImageSize(for: sizeClass), height: SizeClass.actorImageSize(for: sizeClass))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.green : Color.clear, lineWidth: 5)
                )
                .overlay(alignment: .topTrailing) {
                    Image(systemName: movieActor.isFavourited ? "heart.fill" : "heart")
                        .resizable()
                        .frame(width: SizeClass.favIconSize(for: sizeClass), height: SizeClass.favIconSize(for: sizeClass))
                        .foregroundColor(movieActor.isFavourited ? .pink : .yellow)
                        .padding(8)
                        .contentTransition(.symbolEffect(.replace))
                        .onTapGesture {
                            Task{
                                await actorViewModel.toggleFavourite(movieActor)
                            }
                        }
                }
            
            Text("\(movieActor.name)")
                .font(.caption2)
                .padding(5)
                .lineLimit(1)
                .frame(width: SizeClass.actorImageSize(for: sizeClass))
                .clipShape(Capsule())
            
        }
    }
    
    private func toggleSelection(_ id: String) {
        if selectedActors.contains(id) {
            selectedActors.remove(id)
        } else {
            selectedActors.insert(id)
        }
    }
}

