# DonationApp - Connecting Donors with NGOs

<div align="center">
  <p>A comprehensive Flutter application designed to bridge the gap between donors and non-governmental organizations (NGOs), streamlining the donation process and enhancing transparency.</p>

  ![Flutter Version](https://img.shields.io/badge/Flutter-3.6+-02569B?logo=flutter)
  ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)
  ![License](https://img.shields.io/badge/License-MIT-green.svg)
</div>

## 📖 About DonationApp

DonationApp is a application that revolutionizes how donations are managed and tracked. Built using Flutter and powered by Firebase, this application provides a seamless experience for both donors looking to contribute to meaningful causes and NGOs seeking to manage their donation campaigns effectively.

The app features dual interfaces - one tailored for donors to discover and contribute to various causes, and another for NGOs to create campaigns, track donations, and manage their operations. With real-time updates, comprehensive analytics, and secure authentication, DonationApp offers a complete solution for modern donation management.

## ✨ Key Features

- **Multi-Platform Support**: Fully functional on Android, iOS, Web, Windows, macOS, and Linux
- **Dual User Interface**:
  - **Donor Portal**: Browse NGOs, make donations, and track contribution history
  - **NGO Dashboard**: Manage campaigns, track incoming donations, and analyze performance
- **Real-time Firebase Backend**:
  - Secure authentication using Firebase Auth
  - Cloud Firestore for scalable, real-time database
  - Firebase Storage for handling images and documents
- **Advanced Analytics**: Interactive charts using FL Chart to visualize donation trends
- **Image Management**: Upload and manage images for profiles 
- **Comprehensive Donation Tracking**: Complete history and status updates for all donations
- **Responsive Design**: Optimized UI for various screen sizes and orientations

## 📱 Screenshots

<table>
  <tr>
    <td>Login Page</td>
    <td>Donor Dashboard</td>
    <td>NGO List</td>
    <td>Donation Creation</td>
  </tr>
  <tr>
    <td><img src="screenshots/Login Page.jpg" width="200"/></td>
    <td><img src="screenshots/Donor Dashboard.jpg" width="200"/></td>
    <td><img src="screenshots/NGO List.jpg" width="200"/></td>
    <td><img src="screenshots/Donation Creation.jpg" width="200"/></td>
  </tr>
  <tr>
    <td>Donation Management</td>
    <td>Donation History</td>
    <td>NGO Dashboard</td>
    <td>Analytics Dashboard</td>
  </tr>
  <tr>
    <td><img src="screenshots/Donation Mangement.jpg" width="200"/></td>
    <td><img src="screenshots/Donation History.jpg" width="200"/></td>
    <td><img src="screenshots/NGO dashboard.jpg" width="200"/></td>
    <td><img src="screenshots/Analytics dashboard.jpg" width="200"/></td>
  </tr>
</table>

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (version 3.6.0 or higher)
- Firebase account
- IDE: Android Studio, VS Code, or IntelliJ IDEA

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Jaybodra333/DonationApp.git
   cd DonationApp
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Add Android, iOS, and Web apps to your Firebase project
   - Download and place `google-services.json` in the `android/app` directory
   - Download and place `GoogleService-Info.plist` in the `ios/Runner` directory
   - Configure web initialization in `web/index.html`
   - Enable Authentication, Firestore Database, and Storage in the Firebase Console

4. Run the app:
   ```bash
   flutter run
   ```

## 🏗️ Project Structure

The application follows a modular architecture for better maintainability and scalability:

```
lib/
├── main.dart           # Application entry point
├── models/             # Data models for the application
├── screens/            # UI screens for different app sections
├── services/           # Business logic and Firebase interactions
└── widgets/            # Reusable UI components
```

## 🛠️ Technologies Used

- **[Flutter](https://flutter.dev/)**: Google's UI toolkit for building natively compiled applications
- **[Firebase](https://firebase.google.com/)**: Backend-as-a-Service platform:
  - **Firebase Authentication**: For user authentication
  - **Cloud Firestore**: For database storage
  - **Firebase Storage**: For file and image storage
- **[FL Chart](https://pub.dev/packages/fl_chart)**: Beautiful and interactive charts for donation analytics
- **[Image Picker](https://pub.dev/packages/image_picker)**: For selecting images from gallery or camera
- **[Path Provider](https://pub.dev/packages/path_provider)**: For file system locations
- **[URL Launcher](https://pub.dev/packages/url_launcher)**: For opening external links

## 🤝 Contributing

Contributions are welcome and appreciated! Here's how you can contribute:

1. Fork the repository
2. Create your feature branch:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Commit your changes:
   ```bash
   git commit -m 'Add some amazing feature'
   ```
4. Push to the branch:
   ```bash
   git push origin feature/amazing-feature
   ```
5. Open a Pull Request


## 👥 Authors

- **Jay Bodra** - [GitHub Profile](https://github.com/Jaybodra333)

## 🙏 Acknowledgments

- Flutter team for providing an excellent framework for cross-platform development
- Firebase team for their comprehensive backend services
- All contributors and testers who helped improve this application

---

<div align="center">
  <p>Made with ❤️ for a better way to donate</p>
</div>
