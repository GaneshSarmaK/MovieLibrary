# MovieLibrary iOS App

A comprehensive movie library management application built with SwiftUI and SwiftData for iOS.

## Overview

MovieLibrary is a full-featured iOS application that allows users to create, manage, and organize their personal movie collection. The app supports movies, actors, and genres with rich relationships between entities, image management, and advanced filtering capabilities.

## Architecture

### MVVM Pattern
The app follows the Model-View-ViewModel (MVVM) architecture:
- **Models**: SwiftData-backed persistent models (`Movie`, `MovieActor`, `Genre`)
- **ViewModels**: Observable classes managing business logic and state
- **Views**: SwiftUI views for the user interface
- **Data Sources**: Actor-based data access layer using `@ModelActor`

### Key Components

#### Models (`/Model`)
- `Movie.swift`: Core movie entity with ratings, posters, and relationships
- `MovieActor.swift`: Actor/performer entity  
- `Genre.swift`: Movie genre categorization

All models use SwiftData for persistence and support:
- Unique identifiers
- Many-to-many relationships
- Favorite marking
- Equatable and Hashable conformance

#### ViewModels (`/ViewModel`)
- `MovieViewModel.swift`: Manages movie CRUD operations and state
- `ActorViewModel.swift`: Handles actor management
- `GenreViewModel.swift`: Manages movie genres
- `GlobalSearchViewModel.swift`: Unified search across all entities

ViewModels are marked with `@Observable` for automatic SwiftUI updates.

#### Data Sources (`/Data Source`)
- `MovieDataSource.swift`: SwiftData operations for movies with advanced filtering
- `ActorDataSource.swift`: Actor persistence layer
- `GenreDataSource.swift`: Genre data management
- `GlobalSearchDataSource.swift`: Cross-entity search queries

Data sources are `actor`-based for thread-safe database operations.

#### Utilities (`/Utilities`)
- `Utils.swift`: Helper functions, image management, size class utilities
- `Enums.swift`: Filter enums and navigation destinations
- `Decodables.swift`: JSON parsing for dummy/seed data

#### Views (`/Views`)
The app includes 14 view files organized by feature:
- Landing/Home views
- Movie creation, detail, list, and grid views
- Actor creation, list, and grid views
- Genre creation, list, and section views
- Search interface
- Reusable card components

## Features

### Core Functionality
- ✅ Create, read, update, and delete movies, actors, and genres
- ✅ Image management with local storage
- ✅ Many-to-many relationships (movies ↔ actors ↔ genres)
- ✅ Favorite marking for all entity types
- ✅ Advanced filtering and search
- ✅ SwiftData persistence

### Data Management
- **Image Storage**: Photos saved to documents directory with UUID-based naming
- **Relationship Management**: Automatic inverse relationship handling
- **Seed Data**: JSON-based dummy data loading on first launch

### User Interface
- Native SwiftUI interface
- Grid and list view options  
- Size class adaptation for iPad
- Navigation stack-based routing
- Search functionality across all entities

## Data Model

### Relationships
```
Movie ←→ MovieActor (many-to-many)
Movie ←→ Genre (many-to-many)
```

### Filtering
The app supports sophisticated filtering:
- **Movies**: by name, rating, year, genres, actors, favorite status
- **Actors**: by name, movies, favorite status  
- **Genres**: by name, movies, favorite status

## Setup and Installation

### Requirements
- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

### First Launch
On the first app launch:
1. App displays a landing screen
2. Database initialization occurs
3. Dummy data is loaded from `DummyData.json`
4. Main interface becomes available

The seeding process is controlled by `UserDefaults` to run only once.

## Technical Highlights

### SwiftData Integration
- Uses `@Model` macro for model definitions
- `@Relationship` with inverse for bi-directional associations
- `@Attribute(.unique)` for model identifiers
- Custom `FetchDescriptor` with predicates for filtering

### Actor-Based Data Layer
Data sources use Swift's `actor` type with `@ModelActor` for:
- Thread-safe database operations
- Automatic model context injection
- Safe concurrent access

### Observable ViewModels
ViewModels use Swift's `@Observable` macro (not Combine) for:
- Automatic view updates
- Clean, modern state management
- No manual publishers needed

### Image Management
Custom `ImageManager` utility handles:
- Saving images to documents directory
- Loading from both bundle and documents
- Smart filename detection (UUID vs. asset names)
- Cleanup on deletion

## File Structure

```
MovieLibrary/
├── Model/
│   ├── Movie.swift
│   ├── MovieActor.swift
│   └── Genre.swift
├── ViewModel/
│   ├── MovieViewModel.swift
│   ├── ActorViewModel.swift
│   ├── GenreViewModel.swift
│   └── GlobalSearchViewModel.swift
├── Data Source/
│   ├── MovieDataSource.swift
│   ├── ActorDataSource.swift
│   ├── GenreDataSource.swift
│   └── GlobalSearchDataSource.swift
├── Views/
│   ├── LandingView.swift
│   ├── MovieView.swift
│   ├── MovieCreationView.swift
│   ├── MoviesListView.swift
│   ├── MovieGridView.swift
│   ├── MovieCardView.swift
│   ├── ActorListView.swift
│   ├── ActorGridView.swift
│   ├── ActorCreationView.swift
│   ├── GenreListView.swift
│   ├── GenreCreationView.swift
│   ├── GenreSectionView.swift
│   ├── HeroSectionView.swift
│   └── SearchView.swift
├── Utilities/
│   ├── Utils.swift
│   ├── Enums.swift
│   └── Decodables.swift
└── MovieLibraryApp.swift
```

## Code Examples

### Adding a Movie
```swift
@Environment(MovieViewModel.self) private var movieViewModel

// Add movie with image
await movieViewModel.add(
    name: "Inception",
    photoData: selectedImageData,
    summary: "A thief who steals corporate secrets through dream-sharing technology",
    rating: 9,
    movieActors: selectedActors,
    genres: selectedGenres,
    releaseYear: 2010
)
```

### Filtering Movies
```swift
// Filter by multiple criteria
await movieViewModel.fetch(filters: [
    .rating(9),
    .releaseYear(2010),
    .genres(Set(selectedGenreIds))
])
```

### Global Search
```swift
@Environment(GlobalSearchViewModel.self) private var searchViewModel

// Search across all entities
await searchViewModel.fetchByPartialString("inception")
// Results populate: searchViewModel.movies, searchViewModel.actors, searchViewModel.genres
```

## State Management

The app uses a three-state AppState machine:
1. **Landing**: Initial splash screen
2. **StoringToDatabase**: Data seeding in progress
3. **Ready**: App fully initialized and ready for use

State persistence via `@AppStorage` ensures seeding runs only once.

## Database Location

SwiftData storage location is logged on app launch:
```
print(URL.applicationSupportDirectory.path(percentEncoded: false))
```

Check console output to locate the `.sqlite` file for debugging.

## Known Considerations

- Some methods use force unwrapping (`!`) and may crash if entities don't exist in collections
- Image deletion checks for UUID format (contains "-") to avoid deleting bundled assets
- GlobalSearchViewModel has a typo in method name (`fetct` instead of `fetch`)
- Debug print statements remain in production code

## Future Enhancements

Potential improvements:
- Error handling instead of force unwraps
- Loading states and progress indicators
- Offline image caching
- Export/import functionality
- Cloud sync with CloudKit
- Movie recommendations
- Watch list feature

## Credits

Created by NVR4GET
