# Ourbit Kasir

Aplikasi Point of Sale (POS) yang dibangun dengan Flutter untuk desktop, tablet, dan web. Terintegrasi dengan aplikasi Next.js CMS untuk autentikasi seamless.

## 🌐 Live Demo

- **Web App**: https://ourbit-cashier.web.app
- **Firebase Console**: https://console.firebase.google.com/project/ourbit-9ac6d/overview

## 🚀 Fitur Utama

- **Interface Responsif**: Optimized untuk desktop, tablet, dan web
- **Auto Login dengan Token**: Integrasi seamless dengan Next.js CMS
- **Sidebar Hide di Web**: Interface yang bersih untuk pengguna web
- **Theming Konsisten**: Menggunakan design system yang sama dengan CMS Ourbit
- **Payment Processing**: Multiple payment methods (Cash, Credit Card, Debit Card, Digital Wallet, Bank Transfer)
- **Cart Management**: Add/remove items, quantity adjustment, tax calculation
- **Receipt Printing**: Simulasi printing receipt

## Fitur

- **Interface Responsif**: Optimized untuk desktop dan tablet dengan layout landscape
- **Theming Konsisten**: Menggunakan design system yang sama dengan CMS Ourbit
- **Komponen Neumah**: Custom widgets dengan prefix 'Neumah' untuk konsistensi
- **Payment Processing**: Multiple payment methods (Cash, Credit Card, Debit Card, Digital Wallet, Bank Transfer)
- **Cart Management**: Add/remove items, quantity adjustment, tax calculation
- **Receipt Printing**: Simulasi printing receipt

## 🛠️ Tech Stack

- **Flutter**: UI Framework
- **BLoC**: State Management (implemented)
- **GoRouter**: Navigation
- **Supabase**: Backend & Authentication
- **Firebase Hosting**: Web Deployment
- **Google Fonts**: Typography (Inter font family)
- **Custom Theme**: Matching Ourbit CMS design system

## 📁 Struktur Project

```
lib/
├── app/                           # Application pages
│   ├── cashier/                   # Cashier interface
│   ├── login/                     # Login page
│   ├── management/                # Management pages
│   ├── organization/              # Organization pages
│   ├── payment/                   # Payment pages
│   ├── products/                  # Products pages
│   └── reports/                   # Reports pages
├── blocs/                         # BLoC state management
│   ├── auth_bloc.dart            # Authentication BLoC
│   ├── cashier_bloc.dart         # Cashier BLoC
│   ├── auth_event.dart           # Auth events
│   ├── auth_state.dart           # Auth states
│   ├── cashier_event.dart        # Cashier events
│   └── cashier_state.dart        # Cashier states
├── src/
│   ├── core/                      # Core functionality
│   │   ├── config/               # App configuration
│   │   ├── di/                   # Dependency injection
│   │   ├── routes/               # Navigation routes
│   │   ├── services/             # Services (Supabase, Local Storage, Token)
│   │   ├── theme/                # App theme
│   │   └── utils/                # Utilities (Responsive)
│   ├── data/                     # Data layer
│   │   ├── objects/              # Data models
│   │   ├── repositories/         # Repository implementations
│   │   └── usecases/             # Use cases
│   └── widgets/                  # Shared widgets
└── main.dart                     # App entry point
```

## Komponen Neumah

### NeumahButton

- `NeumahPrimaryButton`: Primary action button
- `NeumahSecondaryButton`: Secondary action button
- `NeumahOutlineButton`: Outline style button

### NeumahCard

- `NeumahCard`: Base card component
- `NeumahCardHeader`: Card header section
- `NeumahCardTitle`: Card title text
- `NeumahCardSubtitle`: Card subtitle text
- `NeumahCardContent`: Card content section
- `NeumahCardFooter`: Card footer section

### NeumahInput

- `NeumahTextInput`: Text input field
- `NeumahNumberInput`: Number input field
- `NeumahPasswordInput`: Password input with visibility toggle

## Color Scheme

### Light Mode

- Primary: `#FF5701` (Orange)
- Secondary: `#191919` (Dark Gray)
- Background: `#EFEDED` (Light Gray)
- Surface: `#FFFFFF` (White)

### Dark Mode

- Primary: `#FF5701` (Orange)
- Secondary: `#FFFFFF` (White)
- Background: `#0F0F0F` (Dark)
- Surface: `#1A1A1A` (Dark Gray)

## Layout

### Desktop/Tablet Layout

- **Left Panel (2/3)**: Product grid dengan search dan customer info
- **Right Panel (1/3)**: Cart dengan totals dan payment options
- **Responsive**: Grid menyesuaikan dengan screen size

### Features

- **Product Search**: Search functionality (prepared)
- **Customer Info**: Name dan phone number input (tablet only)
- **Cart Management**: Add/remove items, quantity adjustment
- **Tax Calculation**: 11% tax rate
- **Payment Methods**: Multiple payment options
- **Receipt Printing**: Simulasi printing

## 🔐 Demo Credentials

```
Email: demo@ourbit.com
Password: demo123
```

## 🔧 Setup Supabase

1. **Dapatkan Supabase URL dan Anon Key** dari project Supabase Anda
2. **Update konfigurasi** di `lib/src/core/config/app_config.dart` atau gunakan environment variables:

```bash
# Run dengan environment variables
flutter run -d macos --dart-define=SUPABASE_URL=your_supabase_url --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key
```

## 🌐 Integrasi dengan Next.js CMS

Aplikasi ini terintegrasi dengan aplikasi Next.js CMS untuk autentikasi seamless:

### URL Format untuk Integrasi

```
https://ourbit-cashier.web.app/?token=YOUR_TOKEN&expiry=2024-01-01T12:00:00.000Z
```

### Implementasi di Next.js CMS

```javascript
const openCashier = async () => {
	const {
		data: { session },
	} = await supabase.auth.getSession();
	const expiry = new Date(Date.now() + 24 * 60 * 60 * 1000);

	const flutterUrl = `https://ourbit-cashier.web.app/?token=${
		session.access_token
	}&expiry=${expiry.toISOString()}`;
	window.open(flutterUrl, "_blank");
};
```

### Fitur Integrasi

- **Auto Login**: User otomatis login tanpa input credentials
- **Token Validation**: Validasi token dengan expiry time
- **URL Security**: URL parameters di-clear setelah diproses
- **Fallback**: Fallback ke normal login jika token invalid

## 🚀 Running the App

```bash
# Install dependencies
flutter pub get

# Run on macOS
flutter run -d macos

# Run on iOS Simulator
flutter run -d ios

# Run on Android Emulator
flutter run -d android

# Run on Web
flutter run -d chrome
```

## 🚀 Deployment

### Prerequisites

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login
```

### Deploy to Firebase Hosting

```bash
# Build web app
flutter build web

# Deploy to Firebase
firebase deploy --only hosting:ourbit-cashier
```

### Deploy Script

Kami menyediakan script deploy untuk memudahkan proses:

```bash
# Deploy dengan script
./scripts/deploy.sh
```

### Manual Deploy Steps

1. **Build aplikasi**: `flutter build web`
2. **Deploy ke Firebase**: `firebase deploy --only hosting:ourbit-cashier`
3. **Verifikasi**: Buka https://ourbit-cashier.web.app

## 🔧 Troubleshooting

### Build Issues

```bash
# Clean build
flutter clean
flutter pub get
flutter build web
```

### Firebase Issues

```bash
# Re-login to Firebase
firebase logout
firebase login

# Check Firebase project
firebase projects:list
firebase use ourbit-9ac6d
```

### Token Integration Issues

1. **Token tidak terdeteksi**: Cek format URL parameters
2. **Auto login tidak berfungsi**: Validasi token format dan expiry
3. **URL parameters tidak ter-clear**: Pastikan aplikasi berjalan di web

### Common Issues

- **Sidebar tidak tersembunyi di web**: Pastikan menggunakan `Responsive.isWeb()`
- **Token expired**: Set expiry time yang reasonable (24 jam)
- **Network issues**: Cek koneksi internet dan Supabase URL

## 📚 Documentation

- [Token Authentication Guide](TOKEN_AUTHENTICATION.md)
- [Next.js CMS Integration](NEXTJS_CMS_INTEGRATION.md)
- [Next.js CMS Fixes](NEXTJS_CMS_FIXES.md)
- [Web Sidebar Hide Guide](WEB_SIDEBAR_HIDE.md)
- [Web Routing Update](WEB_ROUTING_UPDATE.md)
- [Logout Function & Fade Transitions](LOGOUT_FADE_TRANSITIONS.md)
- [Deployment Guide](DEPLOYMENT_GUIDE.md)
- [Token Troubleshooting](TOKEN_TROUBLESHOOTING.md)

## 🚀 Future Enhancements

- [x] BLoC implementation untuk state management
- [x] Real API integration dengan Supabase
- [x] Token authentication system
- [x] Web deployment dengan Firebase
- [ ] Receipt printing implementation
- [ ] Inventory management
- [ ] Sales reports
- [ ] Customer management
- [ ] Settings page
- [ ] Offline mode support
- [ ] Push notifications
- [ ] Multi-language support

## Design System

Aplikasi ini menggunakan design system yang konsisten dengan Ourbit CMS:

- **Typography**: Inter font family
- **Colors**: Orange primary (#FF5701) dengan grayscale palette
- **Spacing**: Consistent 8px grid system
- **Border Radius**: 12px untuk cards dan buttons
- **Shadows**: Subtle shadows untuk depth
- **Animations**: Smooth transitions (200ms duration)

## 🏗️ Architecture

Menggunakan Clean Architecture dengan BLoC pattern:

### Layer Structure

- **Presentation Layer**: UI components, pages, dan widgets
- **Business Logic Layer**: BLoC (events, states, blocs)
- **Data Layer**: Models, repositories, dan use cases
- **Core Layer**: Services, utilities, dan configuration

### Key Components

- **BLoC Pattern**: State management dengan events dan states
- **Repository Pattern**: Abstraction untuk data access
- **Dependency Injection**: Manual DI untuk loose coupling
- **Service Layer**: Supabase, Local Storage, Token services

### Authentication Flow

```
Next.js CMS → Generate Token → URL Parameters → Flutter Web → Validate Token → Auto Login
```

### Responsive Design

- **Desktop**: Full sidebar dan layout
- **Web**: Hidden sidebar untuk ruang lebih luas
- **Mobile**: Optimized touch interface
