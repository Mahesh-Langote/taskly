# Setup Guide

This guide provides detailed instructions for setting up the Task Organizer development environment.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (v3.22.3 or higher)
   - [Install Flutter](https://flutter.dev/docs/get-started/install)
   - Verify installation: `flutter doctor`

2. **Dart SDK** (v3.2.3 or higher, included with Flutter)
   - Verify version: `dart --version`

3. **Git**
   - [Install Git](https://git-scm.com/downloads)

4. **IDE**
   - [Android Studio](https://developer.android.com/studio) with Flutter plugin
   - OR [Visual Studio Code](https://code.visualstudio.com/) with Flutter extension

5. **Firebase CLI** (for Firebase setup)
   - [Install Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli)
   - Install FlutterFire CLI: `dart pub global activate flutterfire_cli`

## Setup Steps

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/task_organizer.git
cd task_organizer
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

#### Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter a project name (e.g., "Task Organizer")
4. Configure Google Analytics (optional)
5. Click "Create project"

#### Add Firebase to Your Flutter App

1. **Android**
   - In the Firebase console, click "Add app" and select Android
   - Use package name: `com.yourusername.task_organizer`
   - Register the app
   - Download the `google-services.json` file
   - Place it in the `android/app` directory

2. **Web**
   - In the Firebase console, click "Add app" and select Web
   - Register the app
   - Copy the Firebase configuration

#### Configure Firebase Services

1. **Authentication**
   - In the Firebase console, go to "Authentication"
   - Click "Get started"
   - Enable Email/Password provider
   - Enable Google provider
   
2. **Cloud Firestore**
   - In the Firebase console, go to "Firestore Database"
   - Click "Create database"
   - Start in production mode
   - Choose a location
   
3. **Storage**
   - In the Firebase console, go to "Storage"
   - Click "Get started"
   - Choose a location

#### Update Firebase Configuration

1. Use FlutterFire CLI to generate configuration:
   ```bash
   flutterfire configure --project=your-firebase-project-id
   ```
   
2. OR manually update `lib/firebase_options.dart` with your Firebase project settings

### 4. Configure Firebase Security Rules

In the Firebase console, update the Firestore security rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /tasks/{taskId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
      
      match /categories/{categoryId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### 5. Run the App

Connect a device or start an emulator, then:

```bash
flutter run
```

## Development Configuration

### Launch Configuration for VS Code

Create a `.vscode/launch.json` file:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (debug mode)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug"
    },
    {
      "name": "Flutter (profile mode)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "profile"
    },
    {
      "name": "Flutter (release mode)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "release"
    }
  ]
}
```

### Launch Configuration for Android Studio

Create a run configuration:
1. Click on "Edit Configurations"
2. Click the "+" button and select "Flutter"
3. Name your configuration
4. Set the entry point to `lib/main.dart`
5. Click "OK"

## Troubleshooting

### Common Issues

1. **Flutter SDK not found**
   - Ensure Flutter is in your PATH
   - Run `flutter doctor` to verify installation

2. **Firebase configuration issues**
   - Verify `google-services.json` is in the correct location
   - Check that package name in Firebase matches your app

3. **Dependency conflicts**
   - Try `flutter pub upgrade`
   - Clean and rebuild: `flutter clean && flutter pub get`

4. **Build errors**
   - Check the Flutter version: `flutter --version`
   - Update Flutter: `flutter upgrade`

### Getting Help

If you encounter issues not covered here:
1. Check the [Flutter troubleshooting guide](https://flutter.dev/docs/development/tools/troubleshooting)
2. Search for solutions in the [issues section](https://github.com/yourusername/task_organizer/issues) of the repository
3. Ask for help in the project's communication channels
