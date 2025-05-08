//
//  HeroSectionView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 7/4/2025.
//

import SwiftUI
import SwiftData

/**
 Hero section displaying trending movies with 3D scroll animations.
 
 Creates an eye-catching horizontal carousel at the top of the landing page with
 advanced scroll effects including rotation, offset, and blur transitions.
 
 ## Features
 - Horizontal scrolling carousel
 - 3D rotation effect based on scroll position
 - Blur effect during scroll
 - Snap-to-item scrolling (one at a time)
 - Tap to navigate to movie details
 - "Trending" label overlay
 
 ## Scroll Effects
 - **Identity** (centered): No effects applied
 - **Scrolling**: Applies rotation, offset, and blur based on scroll direction
 - Uses `scrollTransition` modifier for smooth animations
 */
struct HeroSectionView: View {
    
    @Environment(MovieViewModel.self) var movieViewModel
    @Environment(NavigationRouter.self) var router
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.imageManager) var imageManager

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
                                // Horizontal offset based on scroll direction
                                .offset(x: phase.isIdentity ? 0 : phase.value < 0 ? 15 : -15)
                                // 3D rotation on Y-axis creates carousel effect
                                .rotation3DEffect(
                                    .init(degrees: phase.isIdentity ? 0 : phase.value < 0 ? 10 : -10),
                                    axis: (0, 1, 0),
                                    anchor: .center,
                                    anchorZ: 150,
                                    perspective: 1
                                )
                                // Blur non-centered cards for depth effect
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
