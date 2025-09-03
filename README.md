# Bookly
[![Ask DeepWiki](https://devin.ai/assets/askdeepwiki.png)](https://deepwiki.com/toalhussein/bookly)

Bookly is a sleek and modern book discovery application built with Flutter. It leverages the Google Books API to provide users with a rich catalog of books. Users can browse featured and newly released programming books, search for specific titles, and view detailed information for each entry.

## Features

*   **Splash Screen**: An animated entry point to the application.
*   **Dynamic Home Screen**: Discover new reads with horizontally-scrolling "Featured Books" and a vertical list of the "Newest Books".
*   **Detailed Book View**: Get more information on a book, including its cover, title, author, rating, and a list of similar books.
*   **Book Search**: A dedicated screen to search for books.
*   **Responsive UI**: The interface is designed to be clean and intuitive on various screen sizes.
*   **Efficient Image Loading**: Caches book cover images for a smooth and fast user experience.

## Architecture & Technical Stack

This project is built following Clean Architecture principles with a feature-first directory structure, promoting separation of concerns and maintainability.

-   **Framework**: Flutter
-   **State Management**: `flutter_bloc` (Cubit) for predictable and scalable state handling.
-   **Navigation**: `go_router` for a declarative, URL-based routing system.
-   **Dependency Injection**: `get_it` service locator for managing dependencies and decoupling components.
-   **Networking**: `dio` for performing HTTP requests to the Google Books API.
-   **Error Handling**: Uses `dartz` to implement functional error handling with `Either` type for robust failure management.
-   **Image Caching**: `cached_network_image` for efficient loading and caching of network images.

## Project Structure

The codebase is organized into features to ensure scalability and modularity.

```
lib
├── core/                  # Core components shared across features
│   ├── errors/            # Failure classes for error handling
│   ├── utils/             # App-wide utilities (API service, router, assets, service locator)
│   └── widgets/           # Common custom widgets
│
├── features/              # Feature-based modules
│   ├── home/              # Home screen feature
│   │   ├── data/          # Data layer (models, repositories)
│   │   └── presentation/  # Presentation layer (views, cubits)
│   ├── search/            # Search feature
│   └── splash/            # Splash screen feature
│
└── main.dart              # Application entry point
```

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

-   Flutter SDK installed. You can find instructions [here](https://flutter.dev/docs/get-started/install).

### Installation

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/toalhussein/bookly.git
    ```
2.  **Navigate to the project directory:**
    ```sh
    cd bookly
    ```
3.  **Install dependencies:**
    ```sh
    flutter pub get
    ```
4.  **Run the application:**
    ```sh
    flutter run
