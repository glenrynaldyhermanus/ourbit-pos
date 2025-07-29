# Sistem Autentikasi Token untuk Integrasi Next.js CMS

## Overview

Sistem ini memungkinkan aplikasi Next.js CMS mengirimkan token autentikasi ke aplikasi Flutter web, sehingga pengguna tidak perlu login lagi saat berpindah dari CMS ke POS.

## Arsitektur

### 1. Flow Autentikasi

```
Next.js CMS → Generate Token → URL dengan Token → Flutter Web → Validate Token → Auto Login
```

### 2. Komponen Utama

#### TokenService (`lib/src/core/services/token_service.dart`)

- Menangani token dari URL parameters
- Validasi expiry token
- Menyimpan token ke local storage
- Clear URL parameters setelah diproses

#### AppInitializationService (`lib/src/core/services/app_initialization_service.dart`)

- Inisialisasi aplikasi saat startup
- Handle token dari URL
- Cek token yang tersimpan

#### AuthRepository & AuthBloc

- Menambahkan method `validateToken()` dan `authenticateWithToken()`
- Event `AuthenticateWithToken` untuk BLoC
- Use case `AuthenticateWithTokenUseCase`

## Implementasi

### 1. Di Aplikasi Next.js CMS

```javascript
// Generate token dan redirect ke Flutter web
const generateFlutterUrl = (userToken, expiry) => {
	const flutterBaseUrl = "https://your-flutter-app.web.app";
	const url = new URL(flutterBaseUrl);
	url.searchParams.set("token", userToken);
	url.searchParams.set("expiry", expiry.toISOString());
	return url.toString();
};

// Contoh penggunaan
const handleOpenCashier = async () => {
	const token = await getCurrentUserToken(); // dari Supabase
	const expiry = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 jam

	const flutterUrl = generateFlutterUrl(token, expiry);
	window.open(flutterUrl, "_blank");
};
```

### 2. Di Aplikasi Flutter Web

#### URL Format

```
https://your-flutter-app.web.app/?token=YOUR_TOKEN&expiry=2024-01-01T12:00:00.000Z
```

#### Auto Login Flow

1. Aplikasi dimulai
2. `AppInitializationService.initializeApp()` dipanggil
3. `TokenService.handleTokenFromUrl()` mengecek URL parameters
4. Jika ada token valid, set session dan load user data
5. Clear URL parameters
6. User otomatis login tanpa perlu input credentials

## Keamanan

### 1. Token Expiry

- Token memiliki expiry time
- Token expired otomatis dihapus dari storage
- Validasi expiry sebelum menggunakan token

### 2. URL Security

- URL parameters di-clear setelah diproses
- Token tidak tersimpan di browser history

### 3. Error Handling

- Token invalid akan redirect ke login page
- Error handling untuk network issues
- Fallback ke normal login flow

## Penggunaan

### 1. Setup di Next.js CMS

```javascript
// pages/dashboard.js
import { useAuth } from "../hooks/useAuth";

export default function Dashboard() {
	const { user } = useAuth();

	const openCashier = async () => {
		const token = await supabase.auth.getSession();
		const expiry = new Date(Date.now() + 24 * 60 * 60 * 1000);

		const flutterUrl = `https://your-flutter-app.web.app/?token=${
			token.data.session?.access_token
		}&expiry=${expiry.toISOString()}`;
		window.open(flutterUrl, "_blank");
	};

	return (
		<div>
			<button onClick={openCashier}>Buka Kasir</button>
		</div>
	);
}
```

### 2. Testing

```bash
# Test dengan token valid
flutter run -d chrome --web-port=8080

# Buka URL dengan token
http://localhost:8080/?token=YOUR_TOKEN&expiry=2024-01-01T12:00:00.000Z
```

## Konfigurasi

### 1. Environment Variables

```dart
// lib/src/core/config/app_config.dart
class AppConfig {
  static const String flutterAppUrl = 'https://your-flutter-app.web.app';
  static const String nextJsCmsUrl = 'https://your-cms-app.com';
}
```

### 2. Token Expiry Settings

```dart
// lib/src/core/services/token_service.dart
static const Duration defaultTokenExpiry = Duration(hours: 24);
```

## Troubleshooting

### 1. Token tidak terdeteksi

- Cek format URL parameters
- Pastikan token tidak expired
- Cek console untuk error messages

### 2. Auto login tidak berfungsi

- Cek Supabase session
- Validasi token format
- Cek network connectivity

### 3. URL parameters tidak ter-clear

- Pastikan aplikasi berjalan di web
- Cek browser console untuk errors

## Best Practices

1. **Token Security**: Gunakan HTTPS untuk semua komunikasi
2. **Expiry Management**: Set expiry yang reasonable (24 jam)
3. **Error Handling**: Selalu ada fallback ke normal login
4. **User Experience**: Berikan feedback saat processing token
5. **Testing**: Test di berbagai browser dan device

## Monitoring

### 1. Logging

```dart
// Tambahkan logging untuk debugging
print('Token processing: ${token != null ? 'success' : 'failed'}');
```

### 2. Analytics

- Track successful token authentication
- Monitor failed authentication attempts
- Log user session duration

## Future Enhancements

1. **Refresh Token**: Implementasi refresh token mechanism
2. **Multi-Device**: Sync session across devices
3. **Offline Support**: Cache user data for offline use
4. **Biometric Auth**: Integrasi dengan biometric authentication
