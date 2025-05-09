# Taskly 📝

[![Flutter Version](https://img.shields.io/badge/Flutter-3.22.3-blue)](https://flutter.dev/)
[![Dart Version](https://img.shields.io/badge/Dart-3.2.3+-blue)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

A comprehensive task management application built with Flutter that works both online and offline. The app offers seamless cloud synchronization, beautiful UI, analytics, categorization, and more to help users organize and track their tasks effectively.

<p align="center">
  <img src="assets/images/logo.png" alt="Task Organizer Logo" width="200"/>
</p>

## 🌟 Features

- **Cross-platform**: Works on Android and Web (iOS support coming soon)
- **Online/Offline Mode**: Use with or without an internet connection
- **Cloud Synchronization**: Sync tasks across multiple devices when online
- **Beautiful UI/UX**: Modern material design with smooth animations
- **Task Management**:
  - Create, edit, delete tasks
  - Set due dates and priorities
  - Organize tasks by categories
  - Mark tasks as completed
- **Categories**: Organize tasks into customizable categories
- **Dark/Light Theme**: Switch between themes based on preference
- **Analytics**: Visual representation of task completion, priorities, etc.
- **Rich Task Descriptions**: Support for markdown, links, and link previews

## 📱 Screenshots

*Coming Soon*

## 🚀 Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (v3.22.3 or higher)
- [Dart](https://dart.dev/get-dart) (v3.2.3 or higher)
- [Firebase Project](https://console.firebase.google.com/) (for online features)
- [Android Studio](https://developer.android.com/studio) / [VS Code](https://code.visualstudio.com/) with Flutter extensions

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/yourusername/task_organizer.git
cd task_organizer
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Firebase Setup** (Required for online features)

   - Create a new Firebase project at [https://console.firebase.google.com/](https://console.firebase.google.com/)
   - Add Android and Web apps to your Firebase project
   - Download `google-services.json` for Android and place it in the `android/app` directory
   - Set up Firebase Authentication with Email/Password and Google Sign-in
   - Set up Cloud Firestore for data storage
   - Update the Firebase configuration in `lib/firebase_options.dart` with your project's credentials

4. **Run the app**

```bash
flutter run
```

## 🏗️ Project Structure

```
lib/
├── firebase_options.dart    # Firebase configuration
├── main.dart               # App entry point
├── models/                 # Data models
│   ├── category.dart       # Category model
│   └── task.dart           # Task model
├── providers/              # State management
│   ├── task_provider.dart  # Task state management
│   ├── theme_provider.dart # Theme state management
│   └── category_provider.dart # Category state management
├── screens/                # UI screens
│   ├── analytics_screen.dart
│   ├── category_screen.dart
│   ├── home_screen.dart
│   ├── login_screen.dart
│   ├── settings_screen.dart
│   ├── splash_screen.dart
│   └── task_detail_screen.dart
├── services/               # Business logic and services
│   ├── auth_service.dart   # Authentication service
│   ├── database_service.dart # Database operations
│   └── sync_manager.dart   # Data synchronization
├── utils/                  # Utility functions and constants
│   ├── app_theme.dart      # Theme configuration
│   └── date_utils.dart     # Date handling utilities
└── widgets/                # Reusable UI components
    ├── analytics_*.dart    # Analytics-related widgets
    ├── task_*.dart         # Task-related widgets
    └── ...
```

## 📋 Development Checklist

### Setting Up Development Environment

- [ ] Install Flutter (v3.22.3 or higher)
- [ ] Install Dart (v3.2.3 or higher)
- [ ] Set up Android Studio/VS Code with Flutter extensions
- [ ] Configure an emulator/simulator or physical device for testing

### Firebase Integration

- [ ] Create a Firebase project
- [ ] Enable Authentication (Email/Password and Google Sign-in)
- [ ] Set up Cloud Firestore with proper security rules
- [ ] Configure Firebase for Android and Web platforms
- [ ] Place `google-services.json` in the appropriate directory

### Core Feature Implementation

- [ ] Task CRUD operations
- [ ] Category management
- [ ] User authentication
- [ ] Offline/Online mode switching
- [ ] Cloud synchronization
- [ ] Analytics visualization
- [ ] Theme customization

### Testing

- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Manual testing on target platforms (Android, Web)

### Documentation

- [ ] Code documentation
- [ ] API documentation
- [ ] User guide

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

### How to Contribute

1. **Fork the Project**
2. **Create your Feature Branch**
   ```bash
   git checkout -b feature/AmazingFeature
   ```
3. **Make your Changes**
4. **Run Tests**
   ```bash
   flutter test
   ```
5. **Commit your Changes**
   ```bash
   git commit -m 'Add some AmazingFeature'
   ```
6. **Push to the Branch**
   ```bash
   git push origin feature/AmazingFeature
   ```
7. **Open a Pull Request**

### Contribution Guidelines

- Follow the Flutter/Dart style guide
- Write clear, commented, and testable code
- Update documentation for any API changes
- Add tests for new features
- Ensure all tests pass before submitting a PR
- Keep PRs focused on a single feature/fix

## 📚 Code Standards

### Naming Conventions

- **Classes/Enums**: UpperCamelCase
- **Variables/Methods**: lowerCamelCase
- **Filenames**: snake_case

### Code Organization

- Group related functionality
- Follow the single-responsibility principle
- Use Provider for state management
- Keep widgets small and focused

### Testing Standards

- Unit test for business logic
- Widget tests for UI components
- Integration tests for user flows

## 📱 Supported Platforms

- Android
- Web
- (Future) iOS
- (Future) Desktop (Windows, macOS, Linux)

## 🛠️ Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| flutter | 3.22.x | Framework |
| provider | ^6.1.1 | State management |
| firebase_core | ^2.28.1 | Firebase integration |
| firebase_auth | ^4.17.9 | Authentication |
| cloud_firestore | ^4.15.9 | Cloud database |
| google_sign_in | ^6.2.1 | Google authentication |
| shared_preferences | ^2.2.2 | Local storage |
| flutter_animate | ^4.5.0 | Animations |
| intl | ^0.19.0 | Internationalization |
| flutter_slidable | ^3.0.1 | Swipe actions |
| iconsax | ^0.0.8 | Icon pack |
| flutter_markdown | ^0.6.18 | Markdown support |
| url_launcher | ^6.2.2 | URL handling |
| uuid | ^4.2.2 | Unique ID generation |

## 🔄 Version History

- **1.0.0** (Initial Release)
  - Basic task management
  - Category organization
  - Online/Offline mode
  - Theme toggle

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

## 💬 Contact

Project Link: [https://github.com/yourusername/task_organizer](https://github.com/yourusername/task_organizer)

---

<p align="center">
  <i>Made with ❤️ by the Task Organizer Team</i>
</p>
