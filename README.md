<div align="center">

# ExpenseTracker — Flutter

**Mobile frontend for ExpenseTracker — Flutter · Provider · JWT · Spring Boot**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Provider](https://img.shields.io/badge/State-Provider-blueviolet)](https://pub.dev/packages/provider)
[![License](https://img.shields.io/badge/License-MIT-purple.svg)](LICENSE)

[![Download APK](https://img.shields.io/badge/Download%20APK-v1.0.0-3DDC84?logo=android&logoColor=white)](https://github.com/seshathri044/expense-tracker-frontend/releases/tag/v1.0.0)

> **Backend Repository**: [expense-tracker-backend](https://github.com/seshathri044/expense-tracker-backend)

</div>

---

## Overview

ExpenseTracker is a Flutter Android app for personal finance management. It connects to a live Spring Boot backend hosted on AWS EC2, supporting full income and expense tracking, real-time analytics, OTP-based authentication, and dark/light mode.

---

## Screenshots

<img width="1920" height="1020" alt="screen1" src="https://github.com/user-attachments/assets/b677e5c6-e484-446a-8b3a-eb3023b99f8e" />
<img width="1920" height="1020" alt="screen2" src="https://github.com/user-attachments/assets/9030e6b1-3e3f-41d6-a1b4-d05e08319ddc" />
<img width="1920" height="1020" alt="screen3" src="https://github.com/user-attachments/assets/67ecfaed-9e7d-46cc-8952-1ae33122dd01" />
<img width="1920" height="1020" alt="screen4" src="https://github.com/user-attachments/assets/8e9e0c8f-f031-44c0-861c-75d5f32a6174" />
<img width="1920" height="1020" alt="screen5" src="https://github.com/user-attachments/assets/f12779d3-b1c4-41d2-aaa9-5e29a05e32f7" />
<img width="1920" height="1020" alt="screen6" src="https://github.com/user-attachments/assets/1b16a37c-5072-4b89-917d-66360dff89e5" />
<img width="1920" height="1020" alt="screen7" src="https://github.com/user-attachments/assets/1b16a37c-5072-4b89-917d-66360dff89e5" />
<img width="1920" height="1020" alt="screen8" src="https://github.com/user-attachments/assets/3e5f4468-77d2-4af4-b47c-0452567039b7" />

---

## Features

### Authentication
- Registration with OTP email verification — account only created after OTP confirmed
- JWT-based stateless authentication
- Password reset via OTP email
- Secure token storage with SharedPreferences

### Expense & Income Management
- Full CRUD for expenses and incomes
- Category tagging, date tracking, descriptions

### Analytics
- All-time overview — total income, expenses, balance
- Monthly breakdown — current month income vs expense
- Top 3 spending categories
- Yearly report — month-by-month trends for any selected year
- Category breakdown with percentages
- Pie, bar, and line charts

### App
- Home dashboard: balance, top 3 categories, last 3 transactions
- Dark and light mode toggle
- Clean, responsive UI

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x, Dart 3.x |
| State management | Provider 6.0+ |
| HTTP | http package |
| Local storage | SharedPreferences |
| Charts | fl_chart |
| Backend | Spring Boot REST API (JWT secured) |

---

## Local Setup

### Prerequisites
- Flutter SDK 3.0+
- Android Studio or VS Code with Flutter plugin
- Backend running locally or pointing to the live EC2 server

### Steps

```bash
# 1. Clone
git clone https://github.com/seshathri044/expense-tracker-frontend.git
cd expense-tracker-frontend

# 2. Install dependencies
flutter pub get

# 3. Configure backend URL
# Edit lib/config/app_config.dart
```

```dart
class AppConfig {
  static const String baseUrl = 'http://YOUR_BACKEND_IP:8080/api';
}
```

| Environment | URL |
|---|---|
| Android emulator | `http://10.0.2.2:8080/api` |
| Physical device | `http://192.168.x.x:8080/api` |
| Live EC2 server | `http://<ec2-public-ip>:8080/api` |

```bash
# 4. Run
flutter run
```

---

## Build APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

An installable APK is available on the [Releases page](https://github.com/seshathri044/expense-tracker-frontend/releases/tag/v1.0.0).

---

## Project Structure

```
lib/
├── config/               # API base URL and constants
├── models/               # Expense, Income, User, Stats models
├── providers/            # Auth, Expense, Income, Stats providers
├── screens/
│   ├── auth/             # Login, Register, OTP, Forgot Password
│   ├── home/             # Dashboard
│   ├── expense/          # List, Add, Edit
│   ├── income/           # List, Add, Edit
│   ├── statistics/       # Analytics and yearly report
│   ├── profile/          # User profile
│   └── splash/           # Splash screen
├── services/             # API calls — Auth, Expense, Income, Stats
├── widgets/              # Reusable UI components and charts
├── utils/                # Validators, formatters, constants
└── main.dart
```

---

## Security

- JWT tokens stored in SharedPreferences; cleared on logout
- Passwords never stored locally
- All authenticated requests include Bearer token automatically
- Input validation on all forms

---

## Author

**Seshathri M**
[LinkedIn](https://www.linkedin.com/in/seshathri-m/) · [GitHub](https://github.com/seshathri044) · seshathri686@gmail.com

---

## License

[MIT](LICENSE)
