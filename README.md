# LedgeBook

LedgeBook is a modern offline-first personal finance and expense tracking application built with Flutter.

The app is designed around simplicity, privacy, and mindful money management.

## Features

### Notebooks
- Create multiple finance notebooks
- Color-coded organization
- Notebook-based transaction separation

### Transactions
- Income & expense tracking
- Notes and payment methods
- Transaction tagging
- Date filtering

### Analytics
- Monthly spending overview
- Income vs expense visualization
- Category insights

### Search & Filters
- Search transactions
- Filter by:
  - notebook
  - type
  - payment method
  - amount range
  - date range

### Tags
- Custom transaction tags
- Color-coded tags
- Usage tracking


## Tech Stack

### Frontend
- Flutter
- Material 3

### State Management
- Riverpod

### Local Storage
- SQLite
- SharedPreferences


## Architecture

LedgeBook follows a feature-first architecture.

```text
lib/
├── core/
├── data/
├── features/
├── shared/
└── main.dart
```

## Supported Platform

Currently optimized for:

- Android

## Getting Started

### Prerequisites

Install:

- Flutter SDK
- Android Studio
- Android SDK
- Java 17+

### Clone Project

```bash
git clone https://github.com/ravenn3105/LedgeBook.git
cd ledgebook
```

### Install Dependencies

```bash
flutter pub get
```

### Run App

```bash
flutter run
```

## Firebase Setup

This project uses Firebase Authentication.

Required:
- `google-services.json`
- Firebase project configuration

Place:

```text
android/app/google-services.json
```

## Development Status

Currently in active development.

Planned features:
- Budgets
- Calendar insights
- Data export/import
- Cloud sync
- Recurring transactions
- Notifications

## License

MIT License

## Author

Built by Riya Singh