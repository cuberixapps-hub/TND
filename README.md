# TND

# Truth or Dare - Flutter App

A modern, feature-rich Truth or Dare party game app built with Flutter. Supports multiple game modes, up to 20 players, and includes hundreds of preloaded challenges with the ability to add custom ones.

## 🎮 Features

- **Multiple Game Modes**: Kids, Teens, Adult, and Couples modes
- **Player Management**: Support for 2-20 players with custom names and avatars
- **Scoring System**: Track points for completed truths, dares, and skips
- **Custom Challenges**: Add your own truths and dares for each mode
- **Beautiful UI**: Modern, trendy design with smooth animations
- **Offline Support**: Fully functional without internet connection
- **Cross-Platform**: Works on iOS and Android

## 📱 Screenshots

The app features:

- Animated home screen with gradient backgrounds
- Mode selection with custom cards for each game type
- Player setup with drag-to-reorder functionality
- Spinning wheel animation for challenge selection
- Real-time scoreboard with leaderboard

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- iOS/Android development environment set up

### Installation

1. Clone the repository:

```bash
cd truth_or_dare
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

**For iOS Simulator:**

```bash
flutter run -d iPhone
```

**For Android Emulator:**

```bash
flutter run -d emulator
```

**For Physical Device:**

```bash
flutter run
```

**For Web (Chrome):**

```bash
flutter run -d chrome
```

## 🏗️ Architecture

The app follows clean architecture principles with clear separation of concerns:

```
lib/
├── core/
│   ├── constants/     # App constants and enums
│   ├── theme/         # App theme and styling
│   └── utils/         # Utility functions
├── data/
│   ├── models/        # Data models
│   ├── repositories/  # Data repositories
│   └── datasources/   # Preloaded challenges
├── presentation/
│   ├── screens/       # UI screens
│   ├── widgets/       # Reusable widgets
│   └── providers/     # Riverpod state management
└── main.dart          # App entry point
```

## 🎯 Game Modes

### Kids Mode 👶

- Age-appropriate truths and dares
- Fun and silly challenges
- Safe content for ages 7-12

### Teens Mode 🎉

- Perfect for teenage parties
- Social media challenges
- Age 13-17 appropriate content

### Adult Mode 🔥

- Spicy and challenging content
- Party atmosphere challenges
- 18+ only content

### Couples Mode 💕

- Romantic and intimate challenges
- Perfect for date nights
- Relationship-building activities

## 🎮 How to Play

1. **Select Game Mode**: Choose from Kids, Teens, Adult, or Couples
2. **Add Players**: Enter player names (2-20 players)
3. **Start Game**: Players take turns choosing Truth or Dare
4. **Complete Challenges**: Gain points for completing, lose points for skipping
5. **View Scoreboard**: Track scores and see the winner

## 📊 Scoring System

- **Truth Completed**: +10 points
- **Dare Completed**: +15 points
- **Challenge Skipped**: -5 points

## 🛠️ Technologies Used

- **Flutter**: Cross-platform UI framework
- **Riverpod**: State management
- **Hive**: Local storage (prepared for implementation)
- **Flutter Animate**: Smooth animations
- **Google Fonts**: Modern typography

## 📝 Custom Challenges

Users can add their own challenges:

1. Navigate to any game mode
2. Tap the edit icon on the mode card
3. Add custom truths or dares
4. Set difficulty level (1-5 stars)
5. Challenges are saved locally

## 🔧 Development

### Running Tests

```bash
flutter test
```

### Building for Production

**iOS:**

```bash
flutter build ios
```

**Android:**

```bash
flutter build apk
```

## 📄 License

This project is created for educational and entertainment purposes.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For issues or questions, please create an issue in the repository.

---

**Note**: This app contains content for different age groups. Please ensure appropriate supervision for younger players.
# truth_or_dare
# TND
