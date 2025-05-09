# Contributing to Task Organizer

Thank you for considering contributing to Task Organizer! This document provides guidelines and instructions for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)

## Code of Conduct

By participating in this project, you agree to uphold our Code of Conduct. Please report any unacceptable behavior to the project maintainers.

## Getting Started

1. **Fork the repository**
2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/task_organizer.git
   ```
3. **Add the original repository as upstream**
   ```bash
   git remote add upstream https://github.com/original-owner/task_organizer.git
   ```
4. **Install dependencies**
   ```bash
   flutter pub get
   ```
5. **Set up Firebase** (Follow instructions in README.md)

## Development Workflow

1. **Create a branch for your feature or bugfix**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write code that adheres to the coding standards
   - Add tests for new functionality
   - Update documentation as needed

3. **Commit your changes**
   ```bash
   git commit -m "Description of changes"
   ```
   
4. **Keep your branch updated with upstream**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

5. **Push your changes to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

## Pull Request Process

1. **Submit a Pull Request (PR) to the main repository**
2. **Ensure your PR includes:**
   - A clear description of changes
   - Any relevant issue numbers (e.g., "Fixes #123")
   - Screenshots for UI changes
   - All tests pass
3. **Address review comments**
4. **Once approved, your PR will be merged**

## Coding Standards

### Flutter/Dart Style

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo).

### Naming Conventions

- **Classes/Enums**: UpperCamelCase
  ```dart
  class TaskDetail {}
  enum Priority { low, medium, high }
  ```

- **Variables/Functions**: lowerCamelCase
  ```dart
  final taskList = [];
  void updateTaskStatus() {}
  ```

- **Constants**: lowerCamelCase or SCREAMING_CAPS for top-level constants
  ```dart
  const double borderRadius = 8.0;
  const MAXIMUM_TASKS = 100;
  ```

- **File Names**: snake_case
  ```
  task_detail_screen.dart
  auth_service.dart
  ```

### Architecture

- Use Provider for state management
- Follow the folder structure outlined in the README
- Practice the single responsibility principle
- Keep widget hierarchies shallow

### Code Quality

- Avoid `TODO` comments in PRs
- Write clear code comments
- Keep methods short and focused
- Use meaningful variable names
- Remove unused imports and variables

## Testing Guidelines

### Types of Tests

1. **Unit Tests**: Test individual functions and methods
2. **Widget Tests**: Test UI components
3. **Integration Tests**: Test full features or user flows

### Test Coverage

- Aim for 80%+ test coverage
- All new features should include tests
- Bug fixes should include regression tests

### Running Tests

```bash
# Run all tests
flutter test

# Run a specific test file
flutter test test/path/to/test_file.dart

# Run with coverage
flutter test --coverage
```

## Documentation

### Code Documentation

- Add dartdoc comments to public APIs
- Document complex logic with inline comments
- Update API documentation for changes

### Feature Documentation

If adding a major feature, update:
1. README.md with feature description
2. Any relevant user documentation

## Questions?

If you have questions about contributing, feel free to:
1. Open an issue
2. Contact the maintainers

Thank you for contributing to Task Organizer!
