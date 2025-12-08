# MovieLibrary iOS App

A modern iOS movie library management application with stunning UI design, built with SwiftUI and SwiftData.

## Overview

MovieLibrary is a feature-rich iOS application for managing your personal movie collection. The app features a vibrant glass-morphism UI with smart image management, comprehensive movie/actor/genre relationships, and intelligent caching.

## Features

### Modern UI Design 🎨
- **Glass Cards**: Ultra-thin material backgrounds with colored shadows
- **Vibrant Gradients**: Color-coded entities (Blue=Movies, Pink=Actors, Green=Genres)
- **Smooth Animations**: Interactive star ratings, bounce effects, and transitions
- **Responsive Design**: Adapts to iPhone and iPad with size class utilities

### Core Functionality
- ✅ Full CRUD operations for movies, actors, and genres
- ✅ Smart image management with 16:10 auto-cropping and 30% JPEG compression
- ✅ In-memory image caching via NSCache
- ✅ Many-to-many relationships (movies ↔ actors ↔ genres)
- ✅ Favorites system for all entity types
- ✅ Real-time search with debouncing
- ✅ Interactive 5-star rating system
- ✅ SwiftData persistence

### Advanced Features
- **Image Processing**: Automatic 16:10 aspect ratio cropping and compression
- **Smart Caching**: In-memory image cache for performance
- **Selection UI**: Checkmark badges for actors, gradient swap for genres
- **Multi-select**: Intuitive selection interfaces for creating relationships

## Requirements

- iOS 26.1+
- Xcode 26.1+
- Swift 6.2+
- **Git LFS** (for image assets)

## Setup and Installation

### Initial Setup

⚠️ **Important**: This project uses Git LFS for image assets. Don't download as ZIP!

#### 1. Install Git LFS (First Time Only)

```bash
# Install Git LFS via Homebrew
brew install git-lfs

# Initialize Git LFS
git lfs install
```

#### 2. Clone the Repository

```bash
# Clone the repo
git clone https://github.com/GaneshSarmaK/MovieLibrary.git
cd MovieLibrary

# Pull LFS files (images)
git lfs pull
```

#### 3. Open in Xcode

```bash
open MovieLibrary.xcodeproj
```

### Troubleshooting

**If you get "Distill failed" error:**
```bash
cd MovieLibrary
git lfs pull
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

Then rebuild in Xcode.

## Architecture

### MVVM Pattern
- **Models**: SwiftData-backed persistent models (`Movie`, `MovieActor`, `Genre`)
- **ViewModels**: Observable classes managing business logic and state
- **Views**: SwiftUI views with modern glass-morphism design
- **Data Sources**: Actor-based data access layer using `@ModelActor`

### Key Components

#### Models (`/Model`)
- `Movie.swift`: Movie entity with ratings, posters, and relationships
- `MovieActor.swift`: Actor/performer entity  
- `Genre.swift`: Movie genre categorization

All models use SwiftData with:
- Unique identifiers
- Many-to-many relationships
- Favorite marking
- Equatable and Hashable conformance

#### ViewModels (`/ViewModel`)
- `MovieViewModel.swift`: Manages movie CRUD operations
- `ActorViewModel.swift`: Handles actor management
- `GenreViewModel.swift`: Manages movie genres
- `GlobalSearchViewModel.swift`: Unified search across entities

ViewModels use `@Observable` for automatic SwiftUI updates.

#### Image Management
- `ImageManager.swift`: Singleton service for image operations
  - 16:10 aspect ratio auto-cropping
  - 30% JPEG compression
  - Smart loading (bundle vs. documents)
- `ImageCacher.swift`: NSCache-based in-memory caching (100 items, 500MB limit)

#### Views (`/Views`)
Modern SwiftUI views with glass-morphism design:
- **Creation Forms**: Movie, Actor, Genre creation with vibrant gradients
- **Detail Views**: Rich detail screens with interactive elements
- **List Views**: Grid and scrollable list options
- **Search**: Real-time search with debouncing

## UI Design Highlights

### Color-Coded Entities
- 🔵 **Movies**: Blue → Purple gradients
- 💗 **Actors**: Pink → Purple gradients  
- 💚 **Genres**: Green → Teal gradients

### Selection Indicators
- **Actors**: Green checkmark badge (bottom-trailing)
- **Genres**: Gradient color swap (orange→red to green→teal)

### Modern Components
- Glass material cards with shadows
- Gradient section headers
- Interactive star ratings with rotation animation
- Hero image sections with overlays

## Data Model

### Relationships
```
Movie ←→ MovieActor (many-to-many)
Movie ←→ Genre (many-to-many)
```

### Filtering
- **Movies**: by name, rating, year, genres, actors, favorites
- **Actors**: by name, movies, favorites  
- **Genres**: by name, movies, favorites

## First Launch

On first app launch:
1. Landing screen appears
2. Database initialization
3. Seed data loaded from `DummyData.json`
4. Images automatically processed (cropped to 16:10, compressed)
5. Main interface becomes available

Seeding is controlled by `UserDefaults` to run only once.

## Code Examples

### Adding a Movie
```swift
@Environment(MovieViewModel.self) private var movieViewModel

await movieViewModel.add(
    name: "Inception",
    photoData: selectedImageData,
    summary: "A thief who steals corporate secrets",
    rating: 9,
    movieActors: selectedActors,
    genres: selectedGenres,
    releaseYear: 2010
)
```

### Image Management
```swift
// Save with auto-crop and compression
let filename = imageManager.save(imageData) // Returns UUID filename

// Load with smart caching
let image = imageManager.loadSmart(filename: filename)

// Delete from both cache and disk
imageManager.delete(filename: filename)
```

### Global Search
```swift
@Environment(GlobalSearchViewModel.self) private var searchViewModel

await searchViewModel.fetchByPartialString("inception")
// Results: searchViewModel.movies, searchViewModel.actors, searchViewModel.genres
```

## Technical Stack

- **Framework**: SwiftUI with modern design patterns
- **Data Persistence**: SwiftData with actor-based data sources
- **Image Processing**: UIKit + PhotosUI with custom cropping
- **Caching**: NSCache for in-memory optimization
- **Architecture**: MVVM with @Observable view models
- **Navigation**: NavigationStack with type-safe routing

## File Structure

```
MovieLibrary/
├── Components/
│   ├── ImageManager.swift (Singleton image service)
│   └── ImageCacher.swift (NSCache wrapper)
├── Model/ (SwiftData models)
├── ViewModel/ (@Observable view models)
├── Data Source/ (Actor-based data layer)
├── Views/ (SwiftUI with modern design)
└── Utilities/
```

## State Management

Three-state AppState machine:
1. **Landing**: Initial splash screen
2. **StoringToDatabase**: Seed data processing
3. **Ready**: App fully initialized

## Image Storage

- **Git LFS**: Full-resolution seed images in `Assets.xcassets`
- **Runtime**: User photos compressed to 30% quality, 16:10 aspect ratio
- **Location**: `Documents/` directory with UUID-based naming
- **Cache**: In-memory NSCache (100 items max, 500MB limit)

## Future Enhancements

- [ ] Error handling improvements
- [ ] Loading states and progress indicators
- [ ] Cloud sync with iCloud
- [ ] Movie recommendations
- [ ] Watch list feature
- [ ] Export/import functionality

## Credits

Created by NVR4GET
