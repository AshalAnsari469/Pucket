# 👝 Pucket

A **privacy-focused, offline-first personal finance application** built with Flutter.

Pucket is designed to help you take control of your financial life without compromising your data privacy. By leveraging local storage, all your transactions, budgets, and sensitive financial data stay locally on your device and are never sent to external servers. With interactive dashboards and innovative hands-free input, tracking your expenses has never been easier.

---

## ✨ Features

- **🛡️ Offline-First & Privacy Focused**: Your financial data stays completely on your device. Powered by `Hive` for lightning-fast, secure local storage.
- **📊 Interactive Dashboard**: Visualize your spending habits with beautiful, interactive weekly and monthly expense reporting charts.
- **🎙️ Hands-Free Logging**: Seamlessly log expenses using state-of-the-art **Speech-to-Text** functionality. Just speak your expense and let Pucket handle the recording!
- **📱 Modern UI & Animations**: A sleek, fully responsive user interface utilizing modern typography and smooth micro-animations.
- **🎨 Theming Support**: Fully integrated dark and light modes tailored to your device settings.

---

## 🛠️ Technology Stack

Pucket is built with modern, scalable architectural patterns and robust Flutter packages:

### Architecture
- **State Management**: [Riverpod](https://pub.dev/packages/flutter_riverpod) for reactive, compile-safe, and scalable state management.
- **Database / Local Storage**: [Hive](https://pub.dev/packages/hive_flutter) for NoSQL data persistence, ensuring fast read/write operations without needing an active internet connection.

### Key Dependencies
- `fl_chart` - Powerful and customizable charts to visualize expense data.
- `speech_to_text` - Device-native voice recognition for quick, hands-free expense entry.
- `flutter_animate` - Fluid and beautiful motion graphics for enhanced UI/UX.
- `google_fonts` - Dynamic and beautiful typography integration.
- `shared_preferences` - Lightweight user preferences management.
- `image_picker` - Attach photos and receipts to specific transactions.
- `intl` & `uuid` - Extensive local date/currency handling and unique item generation.

---

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine.

### Prerequisites

You need to have Flutter and Dart installed on your machine.
- [Install Flutter Desktop](https://docs.flutter.dev/get-started/install)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/AshalAnsari469/Pucket.git
   cd Pucket
   ```

2. **Fetch dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate code for Hive Adapters**
   Since the app uses Hive for saving Dart models, you need to run the build runner to generate `.g.dart` files:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the Application**
   ```bash
   flutter run
   ```

---

## 🏗️ Project Structure

```text
lib/
├── models/         # Data models and Hive TypeAdapters (Expense, Category)
├── providers/      # Riverpod providers for reactive state
├── screens/        # UI Screen views (Dashboard, Add Expense, Settings)
├── widgets/        # Reusable UI components (Charts, Forms, Cards)
├── theme/          # App-wide visual themes and color palettes
├── utils/          # Helper functions, formatting, and constants
└── main.dart       # Application entry point
```

---

## 🤝 Contributing
Contributions are absolutely welcome! Whether it's adding new features, fixing bugs, or improving documentation, feel free to open a new issue or submit a Pull Request.

## 📄 License
This project is open-sourced under the MIT License.
