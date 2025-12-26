# Browser

A modern, lightweight web browser for iOS built with SwiftUI and WebKit.

## Features

- **Clean Interface**: Minimalist design focused on browsing content
- **Multiple Search Engines**: Support for Google, DuckDuckGo, and Bing
- **Browsing History**: Automatic history tracking with timestamps
- **Tab Management**: Multiple tab support with visual previews (WIP)
- **Smart Address Bar**: Automatic URL detection and search fallback
- **Navigation Controls**: Back, forward, and refresh functionality
- **Page Menu**: Quick access to bookmarks, history, and settings

## Requirements

- iOS 26.0 or later
- Xcode 26.0 or later


## Architecture

The project follows a feature-based architecture with clear separation of concerns:

```
Browser/
├── Features/
│   ├── Browsing/     # Core web browsing functionality
│   ├── History/      # History tracking and viewing
│   ├── Settings/     # App configuration
│   └── Tabs/         # Tab management
└── Utils/            # Shared utilities and helpers
```


## Technologies Used

- **SwiftUI**: Modern declarative UI framework
- **WebKit**: High-performance web rendering
- **SwiftData**: Persistent history storage
- **Observation Framework**: State management with @Observable
