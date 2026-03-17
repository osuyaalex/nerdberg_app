# Nerdberg Posts App

A Flutter mobile application that fetches and displays posts from the JSONPlaceholder API with favorites support and responsive UI.

## Setup Instructions

### Prerequisites

- Flutter SDK `>=3.11.1`
- Dart SDK (bundled with Flutter)
- Android Studio / Xcode (for emulators)

### Installation

```bash
# Clone the repository
git clone <repo-url>
cd nerdberg_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Running on a specific device

```bash
flutter devices           # List available devices
flutter run -d <device>   # Run on a specific device
```

## Architecture

The project follows a clean layered architecture with a clear separation of concerns:

```
lib/
├── main.dart                  # App entry point, Provider setup
├── components/
│   └── sizes.dart             # Responsive sizing extensions (pH, pW)
├── models/
│   └── post.dart              # Post data model with JSON serialization
├── data/
│   └── post_repository.dart   # Data layer — API calls with local fallback
├── providers/
│   └── post_provider.dart     # State management via ChangeNotifier
└── screens/
    ├── post_list_screen.dart   # Posts list with animated cards
    ├── post_detail_screen.dart # Single post detail view
    └── favorites_screen.dart   # Favorited posts view
```

| Layer        | Responsibility                                                              |
| ------------ | --------------------------------------------------------------------------- |
| **Models**   | Plain Dart classes with `fromJson` / `toJson` for serialization             |
| **Data**     | `PostRepository` fetches from the remote API, falls back to local JSON      |
| **Provider** | `PostProvider` (ChangeNotifier) manages posts list, loading state, favorites |
| **Screens**  | UI widgets that consume the provider and render the interface               |

### Data Flow

1. `PostProvider.loadPosts()` is called at app startup
2. `PostRepository.fetchPosts()` hits the remote API (`https://jsonplaceholder.typicode.com/posts`)
3. On network failure, it falls back to the bundled `assets/data/posts.json`
4. The provider exposes loading/loaded/error states for the UI to react to
5. Favorites are tracked in-memory via a `Set<int>` of post IDs

## Libraries Used

| Package               | Version    | Purpose                                                    |
| --------------------- | ---------- | ---------------------------------------------------------- |
| `provider`            | ^6.1.5+1   | State management via `ChangeNotifierProvider`               |
| `http`                | ^1.2.0     | HTTP client for REST API calls                              |
| `flutter_screenutil`  | ^5.9.3     | Screen adaptation for responsive layouts                    |
| `cupertino_icons`     | ^1.0.8     | iOS-style iconography                                       |

## API Reference

**Base URL:** `https://jsonplaceholder.typicode.com`

| Endpoint  | Method | Description         |
| --------- | ------ | ------------------- |
| `/posts`  | GET    | Fetch all 100 posts |
