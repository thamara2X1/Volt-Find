# ⚡ VoltFind - EV Charging Station Finder

A seamless and reliable mobile application built with Flutter that helps electric vehicle owners locate nearby charging stations, check real-time availability, and book charging slots with ease.

[![Flutter](https://img.shields.io/badge/Flutter-3.24.5-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📱 Screenshots

<img width="150" alt="Screenshot 2025-12-15 at 20 42 03" src="https://github.com/user-attachments/assets/29bae611-b61a-4ee1-912b-69882f6c58d7" />
<img width="150" alt="Screenshot 2025-12-15 at 20 44 24" src="https://github.com/user-attachments/assets/1cf909b7-d698-4f02-8365-5fc5703614ef" />
<img width="150" alt="Screenshot 2025-12-15 at 20 45 17" src="https://github.com/user-attachments/assets/582a3a59-910d-4f7b-988a-283dbe70bfa4" />
<img width="150" alt="Screenshot 2025-12-15 at 20 46 43" src="https://github.com/user-attachments/assets/9d9a75d5-0b21-478b-9193-f8388ea727ac" />




## ✨ Features

### For EV Owners (Customers)
- 🔍 **Smart Search** - Find nearby charging stations with real-time availability
- 🗺️ **Interactive Map** - View all stations on an interactive map with custom markers
- 📊 **Real-Time Data** - Check live availability, pricing, and connector types
- 📅 **Easy Booking** - Reserve charging slots in advance
- ⭐ **Reviews & Ratings** - Read and write reviews for charging stations
- 🔔 **Push Notifications** - Get notified about booking confirmations and updates
- 📍 **Navigation** - Get turn-by-turn directions to selected stations
- 📜 **Booking History** - Track all your past and upcoming bookings
- 👤 **User Profile** - Manage your profile, preferences, and vehicle information
- 🌍 **Multi-language Support** - Available in multiple languages

### For Station Owners
- 📊 **Dashboard** - Comprehensive analytics and station performance metrics
- 🏢 **Station Management** - Add, edit, and manage multiple charging stations
- 💰 **Revenue Tracking** - Monitor earnings and transaction history
- 📈 **Usage Analytics** - View station utilization and peak hours
- 🔧 **Maintenance Alerts** - Get notified about station issues
- 📋 **Booking Management** - View and manage customer bookings

## 🏗️ Architecture

This project follows **Clean Architecture** principles with the following structure:

```
lib/
├── core/                  # Core utilities and constants
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   └── errors/
├── data/                  # Data layer (Repository pattern)
│   ├── models/
│   ├── repositories/
│   └── datasources/
├── domain/                # Business logic layer
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/          # UI layer
│   ├── providers/
│   ├── screens/
│   └── widgets/
└── services/             # External services
```

**State Management:** Provider Pattern

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.24.5 or higher)
- Dart SDK (3.5.4 or higher)
- Android Studio / VS Code
- Xcode (for iOS development)
- Firebase Account
- Google Cloud Account (for Maps API)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/voltfind.git
   cd voltfind
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase
   flutterfire configure
   ```

4. **Configure Google Maps API**
   
   **For Android:**
   - Get API key from [Google Cloud Console](https://console.cloud.google.com/)
   - Add to `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY_HERE"/>
   ```

   **For iOS:**
   - Add API key to `ios/Runner/AppDelegate.swift`:
   ```swift
   GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory (not tracked in git):

```env
GOOGLE_MAPS_API_KEY_ANDROID=your_android_key_here
GOOGLE_MAPS_API_KEY_IOS=your_ios_key_here
FIREBASE_PROJECT_ID=your_project_id
```

### Firebase Configuration

1. Enable Authentication (Email/Password)
2. Create Firestore Database
3. Set up Firestore Security Rules (see `firestore.rules`)
4. Enable Cloud Storage (for profile pictures)

### Firestore Database Structure

```
users/
  └── {userId}/
      ├── name: string
      ├── email: string
      ├── phone: string
      ├── userType: string (customer/stationOwner)
      └── createdAt: timestamp

stations/
  └── {stationId}/
      ├── name: string
      ├── location: geopoint
      ├── availableSlots: number
      ├── totalSlots: number
      ├── pricePerKwh: number
      ├── connectorTypes: array
      └── isOperational: boolean

bookings/
  └── {bookingId}/
      ├── userId: string
      ├── stationId: string
      ├── startTime: timestamp
      ├── endTime: timestamp
      ├── status: string
      └── totalCost: number
```

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  
  # State Management
  provider: ^6.1.1
  
  # Maps & Location
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  
  # UI & Navigation
  go_router: ^13.0.0
  
  # Utilities
  intl: ^0.18.1
  shared_preferences: ^2.2.2
```

## 🧪 Testing

Run tests with:

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test

# Widget tests
flutter test test/widget_test.dart
```

## 🏗️ Build

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 📱 Supported Platforms

- ✅ Android (API 23+)
- ✅ iOS (12.0+)
- 🚧 Web (Coming soon)

## 🛠️ Development

### Code Style

This project follows the [Effective Dart](https://dart.dev/guides/language/effective-dart) style guide.

Run linter:
```bash
flutter analyze
```

Format code:
```bash
flutter format .
```

### Git Workflow

1. Create a feature branch
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Commit your changes
   ```bash
   git commit -m "feat: add new feature"
   ```

3. Push to the branch
   ```bash
   git push origin feature/your-feature-name
   ```

4. Create a Pull Request

### Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting)
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

## 🐛 Known Issues

- [ ] Google Maps requires billing enabled (use OpenStreetMap alternative)
- [ ] iOS simulator location may not work (test on real device)

## 🗺️ Roadmap

- [x] User Authentication (Email/Password)
- [x] Station Search & Map View
- [x] Booking System
- [ ] Payment Integration
- [ ] Push Notifications
- [ ] Route Navigation
- [ ] Offline Mode
- [ ] Multi-language Support
- [ ] Dark Mode
- [ ] Social Login (Google, Apple)
- [ ] Station Owner Dashboard
- [ ] Analytics & Reports
- [ ] Web Version


## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Author

Vinindu Thamara

- GitHub: [@vininduthamara](https://github.com/thamara2X1)
- Email: vininduvtph@gmail.com
- Location: Galle, Sri Lanka 🇱🇰

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Google Maps for mapping services
- OpenStreetMap for free map tiles
- All contributors and testers

## 📊 Project Status

🚧 **Status:** Active Development

Current Version: 1.0.0-alpha

## 🔐 Security

Found a security vulnerability? Please email vininduvtph@gmail.com instead of using the issue tracker.

---

⚡ **Happy Charging!** ⚡
