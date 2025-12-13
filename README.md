# 💰 ExpenseTracker Flutter Frontend

A beautiful and intuitive Flutter mobile application for personal finance management. Track expenses, manage income, view real-time analytics, and take control of your finances with a modern, user-friendly interface.

## ✨ Features

### Authentication & Authorization
* 🔐 JWT-based authentication
* 👤 User registration and login
* 🔄 Automatic token refresh
* 🔒 Secure credential storage
* 📱 Biometric authentication support

### Expense Management
* ➕ Create, edit, and delete expenses
* 🏷️ Categorize expenses with custom categories
* 📊 Visual spending patterns
* 🔍 Advanced search and filtering
* 📅 Calendar-based expense tracking
* 📸 Receipt photo attachments
* 💳 Multiple payment method tracking

### Income Management
* 💵 Record and track income transactions
* 📈 Multiple income source management
* 📊 Income analytics and visualization
* 🔄 Recurring income support

### Statistics & Analytics
* 📊 Interactive charts and graphs
* 📉 Spending trends visualization
* 💹 Income vs Expense comparison
* 📅 Monthly and yearly reports
* 🎯 Budget tracking and alerts
* 📈 Category-wise breakdown

### User Profile
* 👤 Profile management
* ⚙️ Customizable settings
* 🌓 Dark/Light theme support
* 🔔 Notification preferences
* 💱 Multi-currency support

## 🛠️ Tech Stack

### Framework & Language
* **Flutter 3.x** - Cross-platform framework
* **Dart 3.x** - Programming language

### State Management
* **Provider** / **Riverpod** - State management solution
* **BLoC Pattern** - Business logic component architecture

### UI/UX
* **Material Design 3** - Modern UI components
* **Custom animations** - Smooth transitions
* **Responsive design** - Adaptive layouts

### Data & Storage
* **HTTP/Dio** - API communication
* **SharedPreferences** - Local data persistence
* **Secure Storage** - Encrypted credential storage
* **Hive** / **SQLite** - Local database

### Additional Libraries
* **fl_chart** - Beautiful charts and graphs
* **intl** - Internationalization and date formatting
* **image_picker** - Receipt photo capture
* **camera** - Direct camera access
* **permission_handler** - Runtime permissions

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

* Flutter SDK (3.0.0 or higher)
* Dart SDK (3.0.0 or higher)
* Android Studio / Xcode (for mobile development)
* Git

## 🚀 Getting Started

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/seshathri044/expense-tracker-frontend.git
cd expense-tracker-frontend
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure API endpoint**

Create a `.env` file in the root directory:
```env
API_BASE_URL=http://your-backend-url:8080/api
```

Or update the configuration in `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'http://your-backend-url:8080/api';
}
```

4. **Run the app**
```bash
# For Android
flutter run

# For iOS
flutter run

# For a specific device
flutter run -d <device-id>
```

### Build for Production

**Android APK**
```bash
flutter build apk --release
```

**Android App Bundle**
```bash
flutter build appbundle --release
```

**iOS**
```bash
flutter build ios --release
```

## 📱 Screenshots

### Authentication
* Login Screen
* Registration Screen
* Splash Screen

### Dashboard
* Home Screen with overview
* Interactive charts
* Quick actions

### Expense Management
* Expense list view
* Add/Edit expense form
* Expense details

### Analytics
* Statistics dashboard
* Monthly reports
* Category breakdown

## 🏗️ Project Structure

```
lib/
├── config/              # Configuration files
│   ├── api_config.dart
│   ├── theme_config.dart
│   └── routes.dart
├── models/              # Data models
│   ├── expense.dart
│   ├── income.dart
│   ├── user.dart
│   └── statistics.dart
├── providers/           # State management
│   ├── auth_provider.dart
│   ├── expense_provider.dart
│   ├── income_provider.dart
│   └── statistics_provider.dart
├── screens/             # UI screens
│   ├── auth/
│   ├── expense/
│   ├── income/
│   ├── home/
│   ├── profile/
│   ├── statistics/
│   ├── transactions/
│   ├── onboarding/
│   └── splash/
├── services/            # API services
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── expense_service.dart
│   ├── income_service.dart
│   └── storage_service.dart
├── widgets/             # Reusable widgets
│   ├── common/
│   ├── charts/
│   └── forms/
├── utils/               # Utility functions
│   ├── constants.dart
│   ├── validators.dart
│   └── helpers.dart
└── main.dart            # Entry point
```

## 🔧 Configuration

### API Integration

The app connects to the [ExpenseTracker Backend API](https://github.com/seshathri044/expense-tracker-backend). Ensure the backend is running before using the app.

### Theme Customization

Edit `lib/config/theme_config.dart` to customize colors, fonts, and styling:

```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primaryColor: Colors.blue,
    // ... other theme properties
  );
}
```

## 🧪 Testing

Run tests using:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 📦 Dependencies

Key dependencies used in this project:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  dio: ^5.0.0
  shared_preferences: ^2.0.0
  flutter_secure_storage: ^8.0.0
  fl_chart: ^0.63.0
  intl: ^0.18.0
  image_picker: ^1.0.0
  permission_handler: ^11.0.0
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Seshathri**
* GitHub: [@seshathri044](https://github.com/seshathri044)

## 🔗 Related Projects

* [ExpenseTracker Backend API](https://github.com/seshathri044/expense-tracker-backend) - Spring Boot REST API backend

## 📞 Support

If you have any questions or need help, please:

* Open an issue on GitHub
* Contact via email

## 🙏 Acknowledgments

* Flutter team for the amazing framework
* All contributors and supporters of this project

---

Made with ❤️ using Flutter
