# 🎯 FuliTrack

**Privacy-First Fuliza M-PESA Tracking App for Kenya**

FuliTrack is a powerful, privacy-first mobile application designed to help Kenyan users monitor, manage, and reduce their Fuliza M-PESA loan usage. Built with Flutter, it provides deep insights into your spending patterns, interest charges, and helps you take control of your mobile money finances.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.10.1+-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)](https://github.com)

---

## 📱 Screenshots

> **Note**: Screenshots will be added here showing the app in action

| Dashboard | Activity Log | Achievements |
|-----------|--------------|--------------|
| ![Dashboard](screenshots/dashboard.png) | ![Activity](screenshots/activity.png) | ![Rewards](screenshots/rewards.png) |

| Settings | Period Filter | Usage Tank |
|----------|---------------|------------|
| ![Settings](screenshots/settings.png) | ![Filter](screenshots/filter.png) | ![Tank](screenshots/tank.png) |

---

## ✨ Features

### 📊 **Financial Tracking**
- **Automatic SMS Parsing**: Automatically reads and parses M-PESA Fuliza SMS messages
- **Real-time Limit Display**: Shows your current available Fuliza limit
- **Transaction History**: Complete log of loans, interest charges, and repayments
- **Outstanding Balance**: Track what you owe at any time
- **Interest Analysis**: See exactly how much you're paying in interest

### 📈 **Data Visualization**
- **Usage Tank**: Beautiful visual gauge showing Fuliza limit usage
- **Trend Graphs**: Line charts showing loan and interest patterns over time
- **Period Filtering**: View data by week, month, or year
- **Statistics Banner**: Key metrics at a glance
- **Interest vs Principal Charts**: Understand your cost breakdown

### 🎖️ **Gamification & Motivation**
- **15 Achievement Badges**: Earn rewards for reducing usage
- **5 Reward Types**:
  - 🥉 **Bronze**: 10% reduction in usage
  - 🥈 **Silver**: 25% reduction in usage
  - 🥇 **Gold**: 50%+ reduction in usage
  - 🎯 **Zero Fuliza**: Achieved zero Fuliza usage
  - 🔥 **Consistency**: Consecutive periods of improvement
- **Period Comparison**: Track week-over-week and month-over-month progress
- **Custom Comparison Types**: Compare by interest, principal, or combined

### 🔔 **Smart Notifications** ✨ *NEW*
- **Due Date Reminders**: Get notified before your Fuliza payment is due
- **High Interest Alerts**: Instant alerts when interest charges exceed 5%
- **Achievement Notifications**: Celebrate when you earn new badges
- **Weekly Summaries**: Optional weekly usage summary notifications
- **Fully Customizable**: Toggle each notification type on/off

### 🎨 **Premium Design**
- **Modern UI**: Clean, professional interface with premium animations
- **Dark Mode Ready**: Automatic theme switching based on system settings
- **Smooth Animations**: Delightful micro-interactions throughout
- **Gradient Accents**: Beautiful teal and amber color scheme
- **Custom Widgets**: Tappable cards, premium buttons, and more

### 🔒 **Privacy First**
- **100% Local Storage**: All data stored on your device using SQLite
- **No Cloud Sync**: Your financial data never leaves your phone
- **No Account Required**: Start tracking immediately
- **No Tracking**: No analytics, no third-party SDKs
- **Open Source**: Full transparency with MIT license

### 🛠️ **Data Management**
- **SMS Sync**: Re-sync your SMS database anytime
- **Database Indexing**: Fast queries even with thousands of transactions
- **Data Export**: *(Coming Soon)* Export your data to CSV/PDF
- **Backup/Restore**: *(Coming Soon)* Backup and restore your data

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: Version 3.10.1 or higher
- **Dart SDK**: Version 3.10.1 or higher
- **Android Studio** / **Xcode** (for iOS development)
- **Android Device**: Android 6.0 (API 23) or higher
- **iOS Device**: iOS 12.0 or higher

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/FuliTrack.git
   cd FuliTrack
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For Android
   flutter run

   # For iOS
   flutter run -d ios

   # For specific device
   flutter run -d <device_id>
   ```

### First Time Setup

1. **Grant SMS Permission**: On first launch, grant SMS read permission when prompted
2. **Wait for Sync**: The app will automatically scan your M-PESA messages
3. **Start Tracking**: View your dashboard and start monitoring your Fuliza usage

---

## 🏗️ Architecture

FuliTrack follows a clean, modular architecture:

```
lib/
├── models/              # Data models (FulizaEvent, FulizaLimit, etc.)
├── services/            # Business logic layer
│   ├── database_service.dart     # SQLite operations
│   ├── sms_parser.dart           # SMS parsing logic
│   ├── sms_service.dart          # SMS access & permissions
│   ├── notification_service.dart # Local notifications
│   └── aggregation_service.dart  # Data aggregation
├── providers/           # State management (Riverpod)
│   ├── fuliza_provider.dart
│   ├── reward_provider.dart
│   ├── notification_provider.dart
│   └── settings_provider.dart
├── ui/
│   ├── screens/        # App screens
│   ├── widgets/        # Reusable UI components
│   └── theme/          # App theme & colors
└── utils/              # Helper utilities
```

### Tech Stack

- **Framework**: Flutter 3.10.1+
- **Language**: Dart 3.10.1+
- **State Management**: Riverpod 2.5.1
- **Database**: SQLite (sqflite 2.3.3)
- **Notifications**: flutter_local_notifications 17.2.3
- **Charts**: fl_chart 0.68.0
- **SMS Access**: flutter_sms_inbox 1.0.4
- **Permissions**: permission_handler 11.3.1

---

## 📦 Database Schema

### Tables

#### `fuliza_events`
Stores all Fuliza transactions (loans, interest, repayments)

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| type | TEXT | Event type (loan/interest/repayment) |
| reference | TEXT | M-PESA reference (unique) |
| amount | REAL | Transaction amount |
| date | INTEGER | Timestamp |
| period_key | TEXT | Period identifier (e.g., "2024-05") |
| due_date | INTEGER | Payment due date |
| outstanding_balance | REAL | Balance after transaction |
| raw_sms | TEXT | Original SMS message |

#### `fuliza_limits`
Tracks Fuliza limit changes

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| type | TEXT | Change type (increase/full_payment/partial_payment/opt_in) |
| limit_amount | REAL | New limit amount |
| date | INTEGER | Timestamp |
| transaction_id | TEXT | Associated transaction ID |
| previous_limit | REAL | Previous limit amount |
| raw_sms | TEXT | Original SMS message |

#### `fuliza_rewards`
Stores earned achievement badges

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key |
| type | TEXT | Reward type (bronze/silver/gold/zero/consistency) |
| period | TEXT | Period type (weekly/monthly) |
| period_start | INTEGER | Period start timestamp |
| awarded_at | INTEGER | Award timestamp |
| previous_value | REAL | Previous period value |
| current_value | REAL | Current period value |
| comparison_type | TEXT | Comparison basis (interest/principal/combined) |

---

## 📊 SMS Parser Patterns

FuliTrack recognizes these M-PESA Fuliza SMS formats:

### Loan with Interest/Access Fee
```
SD38YVVQ1A Confirmed. Fuliza M-PESA amount is Ksh 1443.39.
Interest charged Ksh 14.44.
Total Fuliza M-PESA outstanding amount is Ksh 1457.83 due on 03/05/24.
```

### Full Repayment
```
SD36YYPUQM Confirmed. Ksh 1689.12 from your M-PESA has been used
to fully pay your outstanding Fuliza M-PESA.
Available Fuliza M-PESA limit is Ksh 3000.00.
```

### Partial Repayment
```
SD38YVVQ1A Confirmed. Ksh 500.00 from your M-PESA has been used
to partially pay your Fuliza M-PESA.
Outstanding Fuliza M-PESA is Ksh 957.83 due on 03/05/24.
```

### Limit Increase
```
Your Fuliza M-PESA limit has increased from Ksh 2000 to Ksh 3000.
```

---

## 🎯 How Notifications Work

### Due Date Reminders
- Triggered 1 day before Fuliza payment due date (at 10 AM)
- Shows outstanding balance and due date
- Can be toggled in Settings

### High Interest Alerts
- Triggers immediately when interest rate ≥ 5%
- Shows interest amount, loan amount, and percentage
- Helps you avoid expensive loans

### Achievement Rewards
- Notifies you when you earn a new badge
- Shows reduction percentage achieved
- Motivates continued progress

### Weekly Summaries
- Optional weekly notification with usage stats
- Shows total loaned, interest, and outstanding balance
- Disabled by default

---

## 🧪 Testing

Run unit tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter test integration_test/
```

Current test coverage includes:
- ✅ SMS Parser (272 lines of tests)
- ✅ Reward Evaluation Logic (226 lines of tests)
- ⏳ Integration tests (Coming soon)

---

## 🛣️ Roadmap

### Version 1.1 (Next Release)
- [ ] Data export (CSV, PDF)
- [ ] Database backup/restore
- [ ] Biometric app lock
- [ ] Custom theme colors
- [ ] Dark mode toggle in settings

### Version 1.2
- [ ] Spending goals & targets
- [ ] Predictive analytics
- [ ] Monthly/yearly reports
- [ ] Category tagging for loans
- [ ] Multi-language support (Swahili)

### Version 2.0
- [ ] Tablet/iPad optimization
- [ ] Widget for home screen
- [ ] Wear OS support
- [ ] Advanced data visualization
- [ ] Comparison with other users (anonymized)

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow the existing code structure
- Write tests for new features
- Update documentation as needed
- Use meaningful commit messages
- Ensure code passes `flutter analyze`

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Built with [Flutter](https://flutter.dev)
- Charts powered by [fl_chart](https://github.com/imaNNeo/fl_chart)
- State management by [Riverpod](https://riverpod.dev)
- Icons from [Material Design](https://material.io/icons)

---

## ⚠️ Disclaimer

FuliTrack is an independent application and is **not affiliated with Safaricom or M-PESA**. This app is designed to help you track and manage your Fuliza usage responsibly. All data is stored locally on your device, and we do not collect or transmit any personal information.

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/FuliTrack/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/FuliTrack/discussions)
- **Email**: support@fulitrack.app *(Coming Soon)*

---

## 🌟 Star History

If you find FuliTrack useful, please consider giving it a ⭐ on GitHub!

---

**Made with ❤️ in Kenya**
