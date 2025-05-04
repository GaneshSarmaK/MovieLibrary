//
//  LandingView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 7/4/2025.
//

import SwiftUI
import SwiftData

struct LandingView: View {
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(ActorViewModel.self) var actorViewModel
    @Environment(MovieViewModel.self) var movieViewModel
    @Environment(GenreViewModel.self) var genreViewModel
    
    @State private var globalSearchViewModel = GlobalSearchViewModel()
    @State private var router: NavigationRouter = .init()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                VStack {
                    HeroSectionView()
                        .padding(.top, -10)
                        
                    
                    ForEach(genreViewModel.genres) { genre in
                        Divider()
                        
                        GenreSectionView(genre: genre)
                        

                        
                    }
                }
            }
            .toolbarVisibility(.hidden, for: .navigationBar)
            .overlay(alignment: .top){
                HStack {
                    Button {
                        router.path.append(.movieCreationView(nil))
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding(15)
                    }
                    Spacer()
                    Button {
                        router.path.append(.searchView)
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .padding(15)
                    }
                }
            }
//            .overlay(alignment: .topTrailing) {
//                HStack {
//                    Button {
//                        router.path.append(.movieCreationView(nil))
//                    } label: {
//                        Image(systemName: "plus")
//                            .padding(15)
//                    }
//                    
//                    Button {
//                        router.path.append(.searchView)
//                    } label: {
//                        Image(systemName: "magnifyingglass")
//                            .padding(15)
//                    }
//                }
//            }
            .navigationDestination(for: NavigationDestinations.self) { destination in
                switch(destination) {
                    case .movieCreationView(let movie):
                        MovieCreationView(movie: movie)
                    case .genreCreationView(let genre):
                        GenreCreationView(genre: genre)
                    case .actorCreationView(let movieActor):
                        ActorCreationView(movieActor: movieActor)
                    case .movieView(let movie):
                        MovieView(movie: movie!)
                    case .searchView:
                        SearchView()
                }
            }
        }
        .environment(router)
        .onAppear {
            Task {
                await movieViewModel.fetchAll()
                await genreViewModel.fetchAll()
                await actorViewModel.fetchAll()
            }
        }
    }
    
    private func refreshData() {
        Task {
            await movieViewModel.fetchAll()
            await genreViewModel.fetchAll()
            await actorViewModel.fetchAll()
        }
    }
    
    
}

#Preview {
    LandingView()
}

