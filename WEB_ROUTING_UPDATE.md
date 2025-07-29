# 🌐 Web Routing Update - No Hash URLs

## 🎯 Tujuan

Menghilangkan hash routing (`#`) di Flutter web app untuk mendapatkan URL yang lebih clean dan SEO-friendly.

## ✅ Perubahan yang Diimplementasikan

### 1. **Firebase Hosting Configuration**

```json
// firebase.json
{
	"hosting": [
		{
			"target": "ourbit-cashier",
			"source": ".",
			"ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
			"frameworksBackend": {
				"region": "asia-east1"
			},
			"rewrites": [
				{
					"source": "**",
					"destination": "/index.html"
				}
			]
		}
	]
}
```

### 2. **Enhanced TokenService**

```dart
// lib/src/core/services/token_service.dart

/// Convert hash URL to path URL (for backward compatibility)
static void _convertHashToPath() {
  if (kIsWeb) {
    final currentUrl = html.window.location.href;
    if (currentUrl.contains('#/')) {
      // Convert #/payment to /payment
      final path = currentUrl.split('#/')[1];
      final newUrl = '${currentUrl.split('#')[0]}/$path';
      html.window.history.replaceState({}, '', newUrl);
      print('Converted hash URL to path URL: $newUrl');
    }
  }
}
```

### 3. **URL Strategy Configuration**

```dart
// lib/main.dart
import 'package:url_strategy/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set URL strategy untuk web (no hash routing)
  if (kIsWeb) {
    // Use path URL strategy instead of hash
    // This will make URLs like /payment instead of /#/payment
    setPathUrlStrategy();
  }

  // ... rest of initialization
}
```

### 4. **Dependencies Added**

```yaml
# pubspec.yaml
dependencies:
  url_strategy: ^0.2.0
```

## 🔄 URL Format Changes

### ❌ **Old Format (with hash):**

```
https://ourbit-cashier.web.app/#/payment
https://ourbit-cashier.web.app/#/pos
https://ourbit-cashier.web.app/#/login
```

### ✅ **New Format (without hash):**

```
https://ourbit-cashier.web.app/payment
https://ourbit-cashier.web.app/pos
https://ourbit-cashier.web.app/login
```

## 🧪 Testing

### 1. **Direct URL Access**

Test akses langsung ke URL tanpa hash:

- ✅ `https://ourbit-cashier.web.app/payment`
- ✅ `https://ourbit-cashier.web.app/pos`
- ✅ `https://ourbit-cashier.web.app/login`

### 2. **Backward Compatibility**

URL dengan hash akan otomatis dikonversi:

- `https://ourbit-cashier.web.app/#/payment` → `https://ourbit-cashier.web.app/payment`
- `https://ourbit-cashier.web.app/#/pos` → `https://ourbit-cashier.web.app/pos`

### 3. **Token Authentication**

URL dengan token tetap berfungsi:

```
https://ourbit-cashier.web.app/?token=xxx&expiry=xxx
```

## 🔧 Benefits

### 1. **SEO Friendly**

- URL lebih clean dan mudah dibaca
- Search engine bisa crawl dengan lebih baik
- Bookmark lebih mudah

### 2. **User Experience**

- URL lebih pendek dan professional
- Tidak ada hash yang mengganggu
- Consistent dengan modern web apps

### 3. **Analytics**

- Tracking lebih akurat
- Page views terpisah dengan jelas
- Better conversion tracking

## 📊 Implementation Details

### 1. **Server-side Routing**

Firebase Hosting `rewrites` configuration memastikan semua route mengarah ke `index.html`, sehingga Flutter bisa handle routing client-side.

### 2. **Client-side Conversion**

TokenService otomatis mengkonversi URL dengan hash ke format path untuk backward compatibility.

### 3. **GoRouter Configuration**

GoRouter menggunakan path-based routing untuk web, hash routing untuk mobile.

## 🚀 Deployment Status

- ✅ **Firebase Configuration**: Updated dengan rewrites
- ✅ **Flutter App**: Enhanced dengan hash-to-path conversion
- ✅ **Production**: Deployed ke `https://ourbit-cashier.web.app`

## 📝 Usage Examples

### Next.js CMS Integration

```javascript
// ✅ BENAR - tanpa hash
const flutterUrl = `https://ourbit-cashier.web.app/?token=${token}&expiry=${expiry}`;

// Navigasi internal
const paymentUrl = `https://ourbit-cashier.web.app/payment`;
const posUrl = `https://ourbit-cashier.web.app/pos`;
```

### Direct Navigation

```javascript
// Navigasi langsung ke halaman tertentu
window.open("https://ourbit-cashier.web.app/payment", "_blank");
window.open("https://ourbit-cashier.web.app/pos", "_blank");
```

## 🔍 Monitoring

### Console Logs

```
Converted hash URL to path URL: https://ourbit-cashier.web.app/payment
Hash fragment removed, clean URL: https://ourbit-cashier.web.app/?token=xxx&expiry=xxx
```

### Expected Behavior

1. URL dengan hash otomatis dikonversi ke path
2. Token authentication tetap berfungsi
3. Direct navigation ke semua halaman berfungsi
4. Backward compatibility terjaga

## 📞 Support

### Common Issues

1. **404 Error**: Pastikan Firebase rewrites sudah dikonfigurasi
2. **Routing Loop**: Cek GoRouter configuration
3. **Token Issues**: Pastikan URL format benar (tanpa hash)

### Resources

- [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Flutter Web Routing](https://docs.flutter.dev/development/ui/navigation/url-strategies)
