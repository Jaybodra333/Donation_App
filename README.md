# DonationApp

DonationApp is a Flutter-based mobile application designed to facilitate donations and manage donor interactions. It leverages Firebase services for authentication, data storage, and analytics.

## Features

- User authentication (Firebase Authentication)
- Cloud-based data storage (Cloud Firestore)
- File uploads (Firebase Storage)
- Charting and analytics (FL Chart)
- Image picking functionality
- Cross-platform support (iOS, Android, Web, Windows, macOS, Linux)

## Dependencies

The project uses the following major dependencies:

- **Flutter SDK**
- **Firebase Core**: `^2.27.1`
- **Firebase Auth**: `^4.17.9`
- **Cloud Firestore**: `^4.15.9`
- **Firebase Storage**: `^11.6.10`
- **FL Chart**: `^0.66.0`
- **Image Picker**: `^1.0.7`
- **Path Provider**: `^2.1.2`
- **URL Launcher**: `^6.3.1`

## Getting Started

### Prerequisites

- Install [Flutter SDK](https://flutter.dev/docs/get-started/install).
- Set up your development environment for [iOS](https://flutter.dev/docs/get-started/install/macos) or [Android](https://flutter.dev/docs/get-started/install/windows).
- Configure Firebase for your project. Add the `google-services.json` file for Android and `GoogleService-Info.plist` for iOS.

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd donationapp
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Folder Structure

- `lib/`: Contains the main application code (models, screens, services, widgets).
- `android/` and `ios/`: Platform-specific configurations.
- `test/`: Unit and widget tests.

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License. See the LICENSE file for details.
