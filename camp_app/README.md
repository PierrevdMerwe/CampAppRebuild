# Campp - The Camp App

A Flutter application for discovering and booking camping sites.

## Project Structure

```
lib/
├── src/                    # Source code
│   ├── auth/              # Authentication related code
│   │   ├── screens/       # Login, Register, Welcome screens
│   │   ├── services/      # Auth service, Site owner service
│   │   └── widgets/       # Auth-specific widgets
│   │
│   ├── campsite/          # Campsite feature
│   │   ├── models/        # Campsite data models
│   │   ├── screens/       # Campsite details, Search screens
│   │   ├── services/      # Campsite data services
│   │   └── widgets/       # Campsite-specific widgets
│   │
│   ├── core/              # Core application code
│   │   ├── config/        # App configuration
│   │   │   └── theme/     # Theme configuration
│   │   └── constants/     # App-wide constants
│   │
│   ├── home/              # Home feature
│   │   ├── screens/       # Home screen
│   │   └── widgets/       # Home-specific widgets
│   │
│   └── shared/            # Shared components
│       ├── constants/     # Shared constants
│       └── widgets/       # Shared widgets
│
└── main.dart              # Application entry point
```

## Key Files

### Authentication
- `auth_service.dart`: Handles Firebase authentication
- `site_owner_service.dart`: Manages campsite owner functionality
- `login_screen.dart`: User login interface
- `register_screen.dart`: User registration interface

### Campsite Feature
- `campsite_model.dart`: Data model for campsites
- `campsite_service.dart`: Service for campsite operations
- `campsite_details_screen.dart`: Detailed view of a campsite
- `campsite_search_screen.dart`: Search interface for campsites

### Home Feature
- `home_screen.dart`: Main home screen
- `home_banner.dart`: Top banner widget
- `category_grid.dart`: Categories display
- `location_list.dart`: Locations slider
- `popular_listings.dart`: Popular campsites widget

### Core
- `theme_model.dart`: Theme management
- `app_colors.dart`: Color constants

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Ensure Firebase is configured properly
4. Run the app using `flutter run`

## Dependencies

Main dependencies used in this project:
- firebase_core
- cloud_firestore
- firebase_storage
- google_maps_flutter
- provider
- google_fonts
- carousel_slider

## Notes

- All Firebase-related services are abstracted in the services folder
- Widgets are organized by feature to maintain modularity
- Shared components are placed in the shared folder
- Each feature has its own models, screens, and widgets folders