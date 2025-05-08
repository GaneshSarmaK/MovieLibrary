//
//  ActorGridView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 4/5/2025.
//

import SwiftUI
import SwiftData

/**
 Horizontal scrolling grid displaying actors from search results.
 
 Shows actor cards with photos and names overlaid. Provides context menu for
 delete and update actions. Used in SearchView to display actor search results.
 
 ## Features
 - Horizontal grid layout
 - Actor photo with name overlay
 - Context menu (Delete, Update)
 - Dynamic from GlobalSearchView Model
 */
struct ActorGridView: View {
    
    @Environment(GlobalSearchViewModel.self) var globalSearchViewModel
    @Environment(ActorViewModel.self) var actorViewModel
    @Environment(NavigationRouter.self) var router
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.imageManager) var imageManager

    
    var body: some View {
        
        ScrollView(.horizontal) {
            LazyHGrid(rows: [GridItem(.flexible(), spacing: 10)], spacing: 15) {
                ForEach(globalSearchViewModel.movieActors) { movieActor in
                    card(movieActor: movieActor)
                        .contextMenu {
                            Button(role: .destructive) {
                                Task {
                                    await actorViewModel.delete(movieActor)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .glassEffect()
                            
                            Button(role: .cancel) {
                                router.path.append(.actorCreationView(movieActor))
                            } label: {
                                Label("Update", systemImage: "arrow.clockwise")
                            }
                            .glassEffect()
                        }
                }
            }
        }
        
    }
    
    /**
     Creates actor card with photo and name overlay.
     
     - Parameter movieActor: The actor to display
     
     Name is positioned at bottom with offset for visual effect.
     */
    @ViewBuilder private func card(movieActor: MovieActor) -> some View {
        VStack {
            
            imageManager.loadSmart(filename: movieActor.photoURL!)
                .resizable()
                .scaledToFill()
                .frame(width: SizeClass.imageSize(for: sizeClass), height: SizeClass.imageSize(for: sizeClass))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(alignment: .bottomLeading) {
                    Text("\(movieActor.name)")
                        .font(.headline)
                        .lineLimit(1)
                        .clipShape(Capsule())
                        .offset(y: 30)
                }
                
        }
        .padding(.bottom, 40)
    }
}

