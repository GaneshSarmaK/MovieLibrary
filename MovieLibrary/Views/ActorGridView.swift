//
//  ActorGridView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 4/5/2025.
//

import SwiftUI
import SwiftData

struct ActorGridView: View {
    
    @Environment(GlobalSearchViewModel.self) var globalSearchViewModel
    @Environment(ActorViewModel.self) var actorViewModel
    @Environment(NavigationRouter.self) var router
    @Environment(\.horizontalSizeClass) var sizeClass

    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: SizeClass.columns(for: sizeClass), spacing: 15) {
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
                            
                            Button(role: .cancel) {
                                router.path.append(.actorCreationView(movieActor))
                            } label: {
                                Label("Update", systemImage: "arrow.clockwise")
                            }
                        }
                }
            }
        }
        
    }
    
    @ViewBuilder private func card(movieActor: MovieActor) -> some View {
        VStack {
            
            ImageManager.loadImageSmart(filename: movieActor.photoURL!)
                .resizable()
                .scaledToFill()
                .frame(width: SizeClass.imageSize(for: sizeClass), height: SizeClass.imageSize(for: sizeClass))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(alignment: .bottomLeading) {
                    Text("\(movieActor.name)")
                        .font(.headline)
                        .clipShape(Capsule())
                        .offset(y: 30)
                }
                
        }
        .padding(.bottom, 40)
    }
}

