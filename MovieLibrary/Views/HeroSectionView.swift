//
//  HeroSectionView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 7/4/2025.
//

import SwiftUI
import SwiftData

struct HeroSectionView: View {
    
    @Environment(MovieViewModel.self) var movieViewModel
    @Environment(NavigationRouter.self) var router
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        ScrollView(.horizontal) {
            return LazyHStack(spacing: 10) {
                ForEach(movieViewModel.movies.indices, id: \.self) { index in
                    let movie = movieViewModel.movies[index]
                    HeroCardView(movie: movie)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .frame(width: 300)
                        .background {
                            Color.green
                        }
                        .scrollTransition { content, phase in
                            content
                                .offset(x: phase.isIdentity ? 0 : phase.value < 0 ? 35 : -30)
                                .rotation3DEffect(
                                    .init(degrees: phase.isIdentity ? 0 : phase.value < 0 ? 10 : -10),
                                    axis: (0, 1, 0),
                                    anchor: .center,
                                    anchorZ: 150,
                                    perspective: 1
                                )
                                .blur(radius: phase.isIdentity ? 0 : 5)
                        }
                        .zIndex(-Double(index))
                        .onTapGesture {
                            router.path.append(.movieView(movie))
                        }
                }
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 50, for: .scrollContent)
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(.viewAligned(limitBehavior: .alwaysByOne))
        .frame(height: 300)
        .overlay(alignment: .bottom) {
            Text("Trending")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 8)
        }
    }
}


struct HeroCardView: View {
    
    let movie: Movie
    
    var body: some View {
        ImageManager.loadImageSmart(filename: movie.photoURL!)
            .resizable()
            .aspectRatio(contentMode: .fill)
//            .scaledToFill()
            .overlay(alignment: .bottomLeading) {
                Text("\(movie.name)")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
                    .background(.thinMaterial)
            }
    }
}
