# DonationApp

<div align="center">
  <p>A modern donation management application built with Flutter</p>

  ![Flutter Version](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)
  ![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)
  ![License](https://img.shields.io/badge/License-MIT-green.svg)
</div>

## ✨ Features

- 🔐 **Authentication** - Secure email & password authentication with Firebase
- ☁️ **Cloud Storage** - Store and manage donation-related files
- 📊 **Analytics** - Visualize donation trends with charts
- 📱 **Cross-platform Support** - Works on iOS, Android, Web, and more
- 📷 **Image Uploads** - Upload images for donation campaigns
- 🌐 **URL Launcher** - Open external links directly from the app

## 📱 Screenshots

<table>
  <tr>
    <td>Login Screen</td>
    <td>Dashboard</td>
    <td>Donation Campaign</td>
    <td>Analytics</td>
  </tr>
  <tr>
    <td><img src="screenshots/login.jpg" width="200"/></td>
    <td><img src="screenshots/dashboard.jpg" width="200"/></td>
    <td><img src="screenshots/campaign.jpg" width="200"/></td>
    <td><img src="screenshots/analytics.jpg" width="200"/></td>
  </tr>
</table>

## 🚀 Getting Started

### Prerequisites

- Flutter (3.0 or higher)
- Firebase account
- Android Studio / VS Code

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/DonationApp.git
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
   - Create a new Firebase project
   - Add Android/iOS apps in Firebase console
   - Download and add configuration files
   - Enable Authentication and Firestore

4. Run the app
```bash
flutter run
```

## 🏗️ Architecture

The project follows a clean architecture pattern with the following structure:

```
lib/
├── models/         # Data models
├── screens/        # Screen UI
├── services/       # Business logic & API calls
└── widgets/        # Reusable UI components
```

## 🛠️ Built With

- [Flutter](https://flutter.dev/) - UI framework
- [Firebase](https://firebase.google.com/) - Backend & Authentication
- [FL Chart](https://pub.dev/packages/fl_chart) - Charting library
- [Cloud Firestore](https://firebase.google.com/products/firestore) - Database

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## 👥 Authors

- **Your Name** - [YourGithub](https://github.com/yourusername)

## 🙏 Acknowledgments

- Hat tip to anyone whose code was used
- Inspiration
- etc
