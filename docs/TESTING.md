# Testing Guide

This guide outlines the testing approach for the Task Organizer application, including unit tests, widget tests, integration tests, and manual testing procedures.

## Testing Strategy

Task Organizer follows a comprehensive testing strategy:

1. **Unit Tests**: Test individual functions and classes in isolation
2. **Widget Tests**: Test UI components and their interactions
3. **Integration Tests**: Test complete features and workflows
4. **Manual Testing**: Verify app behavior in real-world scenarios

## Running Tests

### Unit and Widget Tests

To run all unit and widget tests:

```bash
flutter test
```

To run a specific test file:

```bash
flutter test test/path/to/test_file.dart
```

To run tests with coverage:

```bash
flutter test --coverage
```

Generate coverage report (requires lcov):

```bash
genhtml coverage/lcov.info -o coverage/html
```

View coverage report:

```bash
open coverage/html/index.html
```

### Integration Tests

To run integration tests:

```bash
flutter drive --target=test_driver/app.dart
```

## Test Structure

### Unit Tests

Unit tests are located in the `test` directory with a structure that mirrors the lib directory:

```
test/
  ├── models/
  │   ├── task_test.dart
  │   └── category_test.dart
  ├── providers/
  │   ├── task_provider_test.dart
  │   └── category_provider_test.dart
  └── services/
      ├── auth_service_test.dart
      └── database_service_test.dart
```

#### Example Unit Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:task_organizaer/models/task.dart';

void main() {
  group('Task Model', () {
    test('should create a task with the given values', () {
      final task = Task(
        title: 'Test Task',
        dueDate: DateTime(2025, 5, 10),
        categoryColor: const Color(0xFF1976D2),
        category: 'Work',
      );
      
      expect(task.title, 'Test Task');
      expect(task.dueDate, DateTime(2025, 5, 10));
      expect(task.isCompleted, false);
      expect(task.category, 'Work');
    });
    
    test('toJson should return correct map', () {
      // Test implementation
    });
    
    test('fromJson should return correct task', () {
      // Test implementation
    });
  });
}
```

### Widget Tests

Widget tests focus on UI components:

```
test/
  └── widgets/
      ├── task_item_test.dart
      └── category_distribution_test.dart
```

#### Example Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:task_organizaer/models/task.dart';
import 'package:task_organizaer/providers/task_provider.dart';
import 'package:task_organizaer/widgets/task_item.dart';

void main() {
  testWidgets('TaskItemWidget displays task information', (WidgetTester tester) async {
    // Create a task to display
    final task = Task(
      title: 'Test Task',
      dueDate: DateTime(2025, 5, 10),
      categoryColor: const Color(0xFF1976D2),
      category: 'Work',
    );
    
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<TaskProvider>(
          create: (_) => MockTaskProvider(),
          child: Scaffold(
            body: TaskItemWidget(task: task),
          ),
        ),
      ),
    );
    
    // Verify task title is displayed
    expect(find.text('Test Task'), findsOneWidget);
    
    // Verify other elements are displayed
    expect(find.text('Work'), findsOneWidget);
  });
}
```

### Integration Tests

Integration tests test complete features:

```
integration_test/
  ├── app_test.dart
  └── task_flow_test.dart
```

#### Example Integration Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:task_organizaer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Task Creation Flow', () {
    testWidgets('User can create a task', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Navigate to home screen (assuming logged in)
      // Tap on FAB to add a task
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      // Fill the form
      await tester.enterText(find.byType(TextField).first, 'Integration Test Task');
      // ...more form filling
      
      // Submit the form
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      
      // Verify task was created
      expect(find.text('Integration Test Task'), findsOneWidget);
    });
  });
}
```

## Mocking

For tests that require external dependencies like Firebase, we use mocks:

```dart
class MockAuthService extends Mock implements AuthService {
  @override
  bool get isLoggedIn => true;
  
  @override
  Future<User?> signInWithEmail(String email, String password) async {
    return MockUser();
  }
}
```

## Manual Testing Checklist

Before submitting a PR, go through the following manual tests:

### Authentication
- [ ] User can sign up with email and password
- [ ] User can log in with existing credentials
- [ ] User can sign in with Google
- [ ] User can sign out
- [ ] User can use the app in offline mode

### Task Management
- [ ] User can create a new task
- [ ] User can view task details
- [ ] User can edit a task
- [ ] User can delete a task
- [ ] User can mark a task as complete/incomplete
- [ ] Tasks are filtered correctly (Today, Upcoming, etc.)

### Categories
- [ ] User can create a new category
- [ ] User can assign a color to a category
- [ ] User can delete a category
- [ ] User can assign a task to a category

### Settings
- [ ] User can toggle between light and dark theme
- [ ] User can toggle notifications
- [ ] User can toggle cloud sync

### Synchronization
- [ ] Tasks sync when moving from offline to online mode
- [ ] Changes made on one device appear on another device

## Accessibility Testing

Test the following accessibility features:
- [ ] Screen reader compatibility
- [ ] Sufficient color contrast
- [ ] Appropriate text scaling
- [ ] Keyboard navigation

## Performance Testing

- [ ] App launches within reasonable time (< 3 seconds)
- [ ] Task list scrolls smoothly with 100+ tasks
- [ ] App doesn't crash under normal usage

## Platform Specific Testing

### Android
- [ ] Test on small screen devices (< 5 inches)
- [ ] Test on tablets
- [ ] Test with different Android versions (API level 23+)

### Web
- [ ] Test on Chrome, Firefox, Safari, Edge
- [ ] Test on desktop and mobile browsers
- [ ] Test responsiveness across different screen sizes

## Reporting Bugs

When reporting bugs found during testing:

1. Use the bug report template
2. Include steps to reproduce
3. Include screenshots or recordings if applicable
4. Include device information and app version
5. Specify the expected vs. actual behavior
