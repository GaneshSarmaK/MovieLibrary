//
//  MovieView.swift
//  MovieLibrary
//
//  Created by NVR4GET on 7/4/2025.
//

import SwiftUI
import SwiftData

/**
 Detailed movie view displaying comprehensive information about a single movie.
 
 Features a modern, vibrant design with gradient backgrounds, glassmorphism effects,
 and smooth animations. Displays the movie poster, title, favorite status, release year,
 rating, summary, associated genres, and actors.
 
 ## Features
 - Hero poster image with gradient overlay
 - Floating glass cards with blur effects
 - Interactive favorite heart with bounce animation
 - Tap-to-rate star system with pulse effects
 - Smooth scrolling genre and actor chips
 - Vibrant color accents and shadows
 
 ## Size Class Adaptation
 Uses `SizeClass` utilities to adapt image sizes and layout for iPad vs iPhone.
 */
struct MovieView: View {
    
    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.appLogger) var logger
    @Environment(NavigationRouter.self) var router
    @Environment(ActorViewModel.self) var actorViewModel
    @Environment(MovieViewModel.self) var movieViewModel
    @Environment(GenreViewModel.self) var genreViewModel
    @Environment(\.imageManager) var imageManager
    
    @State private var bounceStarIndex: Int? = nil  // Tracks which star to animate
    @State private var selectedActors: Set<String> = []
    
    var movie: Movie
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    var body: some View {
        ScrollView(.vertical) {
            // Hero poster section with gradient overlay
            heroPosterSection()
            
            // Content cards
            VStack(spacing: 16) {
                // Title and favorite
                titleCard()
                
                // Stats (year and rating)
                statsCard()
                
                // Summary
                summaryCard()
                
                // Genres
                genresSection()
                
                // Cast
                actorsSection()
                
            }
            .padding(.horizontal)
            .padding(.top, -20) // Overlap with hero image
        }
        .onAppear(){
            selectedActors = Set(movie.movieActors.map { $0.id })
        }
        .ignoresSafeArea(edges: .top)
        .onChange(of: movie) { oldValue, newValue in
            logger.debugLog("Movie rating changed: \(oldValue.rating) → \(newValue.rating)")
            logger.debugLog("Movie favourite changed: \(oldValue.isFavourited) → \(newValue.isFavourited)")
        }
    }
    
    // MARK: - Hero Poster
    
    @ViewBuilder private func heroPosterSection() -> some View {
        // Poster image
        imageManager.loadSmart(filename: movie.photoURL!)
            .resizable()
            .scaledToFit()
            .clipShape(.rect(cornerRadius: 10))
            .overlay(alignment: .bottomTrailing) {
                Button {
                    Task {
                        await movieViewModel.toggleFavourite(movie)
                    }
                } label: {
                    Image(systemName: movie.isFavourited ? "heart.fill" : "heart")
                        .font(.title2)
                        .foregroundStyle(movie.isFavourited ? .pink : .white)
                        .padding(12)
                        .background(.ultraThinMaterial, in: Circle())
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .symbolEffect(.bounce, value: movie.isFavourited)
                .padding()
            }
    }
    
    // MARK: - Title Card
    
    @ViewBuilder private func titleCard() -> some View {
        VStack(spacing: 4) {
            Text(movie.name)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .gradientForeground(.blue, .purple)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .blue.opacity(0.1), radius: 3, x: 0, y: 5)
    }
    
    // MARK: - Stats Card
    
    @ViewBuilder private func statsCard() -> some View {
        HStack(spacing: 20) {
            // Year
            Group {
                VStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    Text("\(movie.releaseYear)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Release Year")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                
                
                // Rating
                VStack(spacing: 8) {
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { index in
                            Image(systemName: index <= movie.rating ? "star.fill" : "star")
                                .font(.title3)
                                .foregroundStyle(
                                    index <= movie.rating ?
                                        .yellow : .gray.opacity(0.3)
                                )
                                .onTapGesture {
                                    Task {
                                        if await movieViewModel.updateRating(movie, index) {
                                            movie.rating = index
                                        }
                                        withAnimation(.bouncy) {
                                            bounceStarIndex = index
                                        }
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                        bounceStarIndex = nil
                                    }
                                }
                            // Only bounce the star that was just tapped
                                .symbolEffect(.rotate, options: .speed(3) , value: index == bounceStarIndex ? 1 : 0)
                        }
                    }
                    Text("Tap to rate")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Summary Card
    
    @ViewBuilder private func summaryCard() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Synopsis", systemImage: "text.alignleft")
                .font(.headline)
                .foregroundStyle(.purple)
            
            Text(movie.summary)
                .font(.body)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .purple.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Genres Section
    
    @ViewBuilder private func genresSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Genres", systemImage: "film")
                .font(.headline)
                .foregroundStyle(.green)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(movie.genres) { genre in
                        genreChip(genre: genre)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .green.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    @ViewBuilder private func genreChip(genre: Genre) -> some View {
        Text(genre.name)
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .gradientBackground(.green, .teal, startPoint: .topLeading, endPoint: .bottomTrailing, shape: Capsule())
            .shadow(color: .orange.opacity(0.4), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Actors Section
    
    @ViewBuilder private func actorsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Cast", systemImage: "person.2.fill")
                .font(.headline)
                .foregroundStyle(.pink)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(movie.movieActors) { actor in
                        actorCard(movieActor: actor)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .pink.opacity(0.2), radius: 8, x: 0, y: 4)
        .padding(.bottom, 20)
    }
    
    @ViewBuilder private func actorCard(movieActor: MovieActor) -> some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                imageManager.loadSmart(filename: movieActor.photoURL!)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: SizeClass.actorImageSize(for: sizeClass),
                        height: SizeClass.actorImageSize(for: sizeClass)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Button {
                    Task {
                        await actorViewModel.toggleFavourite(movieActor)
                        movieActor.isFavourited.toggle()
                    }
                } label: {
                    Image(systemName: movieActor.isFavourited ? "heart.fill" : "heart")
                        .font(.caption)
                        .foregroundStyle(movieActor.isFavourited ? .pink : .white)
                        .padding(6)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .symbolEffect(.bounce, value: movieActor.isFavourited)
                .padding(6)
            }
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
            
            Text(movieActor.name)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 100)
        }
    }
    
}
