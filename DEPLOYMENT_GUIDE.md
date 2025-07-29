# 🚀 Deployment Guide

Panduan lengkap untuk deploy aplikasi Ourbit POS ke Firebase Hosting.

## 📋 Prerequisites

### 1. Install Dependencies

```bash
# Install Flutter
# Download dari https://flutter.dev/docs/get-started/install

# Install Firebase CLI
npm install -g firebase-tools

# Install Node.js (untuk Firebase CLI)
# Download dari https://nodejs.org/
```

### 2. Setup Firebase

```bash
# Login ke Firebase
firebase login

# Verifikasi login
firebase projects:list
```

## 🚀 Quick Deploy

### Menggunakan Script Deploy

```bash
# Deploy dengan script otomatis
./scripts/deploy.sh
```

### Manual Deploy

```bash
# Build aplikasi
flutter build web

# Deploy ke Firebase
firebase deploy --only hosting:ourbit-cashier
```

## 🔧 Configuration

### Firebase Configuration

File `firebase.json`:

```json
{
	"hosting": [
		{
			"target": "ourbit-cashier",
			"source": ".",
			"ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
			"frameworksBackend": {
				"region": "asia-east1"
			}
		}
	]
}
```

### Environment Variables

```bash
# Supabase Configuration
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key

# Flutter App URL
NEXT_PUBLIC_FLUTTER_APP_URL=https://ourbit-cashier.web.app
```

## 🌐 URLs

### Production URLs

- **Web App**: https://ourbit-cashier.web.app
- **Firebase Console**: https://console.firebase.google.com/project/ourbit-9ac6d/overview
- **Default Site**: https://ourbit-9ac6d.web.app

### Development URLs

- **Local Web**: http://localhost:8080
- **Local Development**: `flutter run -d chrome`

## 📊 Monitoring

### Firebase Console

1. Buka https://console.firebase.google.com/project/ourbit-9ac6d/overview
2. Pilih **Hosting** di sidebar
3. Monitor traffic dan performance

### Analytics

- **Page Views**: Track user visits
- **Performance**: Monitor load times
- **Errors**: Check for deployment issues

## 🔍 Troubleshooting

### Build Issues

```bash
# Clean build
flutter clean
flutter pub get
flutter build web

# Check Flutter version
flutter --version

# Update Flutter
flutter upgrade
```

### Firebase Issues

```bash
# Re-login to Firebase
firebase logout
firebase login

# Check project
firebase projects:list
firebase use ourbit-9ac6d

# Check hosting sites
firebase hosting:sites:list
```

### Deployment Issues

```bash
# Check deployment status
firebase hosting:releases:list

# Rollback to previous version
firebase hosting:releases:list
firebase hosting:releases:rollback VERSION_ID
```

### Token Integration Issues

1. **Test token format**:

   ```
   https://ourbit-cashier.web.app/?token=YOUR_TOKEN&expiry=2024-01-01T12:00:00.000Z
   ```

2. **Check console logs**:

   - Buka Developer Tools (F12)
   - Cek Console untuk error messages

3. **Validate token**:
   - Pastikan token tidak expired
   - Cek format token dengan Supabase

## 🔄 CI/CD Setup

### GitHub Actions (Optional)

```yaml
# .github/workflows/deploy.yml
name: Deploy to Firebase

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.16.0"

      - name: Install dependencies
        run: flutter pub get

      - name: Build web
        run: flutter build web

      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: "${{ secrets.GITHUB_TOKEN }}"
          firebaseServiceAccount: "${{ secrets.FIREBASE_SERVICE_ACCOUNT }}"
          projectId: ourbit-9ac6d
          channelId: live
```

## 📝 Best Practices

### 1. Pre-deployment Checklist

- [ ] Test aplikasi locally
- [ ] Update dependencies
- [ ] Check environment variables
- [ ] Validate token integration
- [ ] Test responsive design

### 2. Post-deployment Checklist

- [ ] Verify site accessibility
- [ ] Test token integration
- [ ] Check mobile responsiveness
- [ ] Monitor error logs
- [ ] Update documentation

### 3. Security Considerations

- [ ] Use HTTPS for all communications
- [ ] Validate token expiry
- [ ] Clear URL parameters after processing
- [ ] Implement proper error handling
- [ ] Monitor for security issues

## 🎯 Performance Optimization

### Build Optimization

```bash
# Optimized build
flutter build web --release --web-renderer canvaskit

# Tree-shaking enabled (default)
flutter build web --tree-shake-icons
```

### Caching Strategy

- **Static Assets**: Cached by Firebase CDN
- **API Calls**: Implement proper caching headers
- **Token Storage**: Local storage dengan expiry

## 📈 Analytics Setup

### Firebase Analytics

```dart
// Add to main.dart
import 'package:firebase_analytics/firebase_analytics.dart';

// Initialize analytics
FirebaseAnalytics analytics = FirebaseAnalytics.instance;
```

### Custom Events

```dart
// Track user actions
analytics.logEvent(name: 'cashier_opened');
analytics.logEvent(name: 'payment_completed');
```

## 🔐 Security

### Token Security

- **Expiry Time**: 24 hours maximum
- **HTTPS Only**: All communications encrypted
- **URL Cleanup**: Parameters cleared after processing
- **Validation**: Server-side token validation

### Environment Variables

```bash
# Never commit sensitive data
# Use environment variables
flutter run --dart-define=SUPABASE_URL=your_url
flutter run --dart-define=SUPABASE_ANON_KEY=your_key
```

## 📞 Support

### Common Issues

1. **Build fails**: Check Flutter version dan dependencies
2. **Deploy fails**: Verify Firebase login dan project access
3. **Token issues**: Validate token format dan expiry
4. **Performance issues**: Optimize build dan caching

### Resources

- [Flutter Web Documentation](https://flutter.dev/docs/deployment/web)
- [Firebase Hosting Documentation](https://firebase.google.com/docs/hosting)
- [Supabase Documentation](https://supabase.com/docs)

## 🎉 Success Metrics

### Deployment Success

- [ ] Site accessible at https://ourbit-cashier.web.app
- [ ] Token integration working
- [ ] Responsive design functional
- [ ] No console errors
- [ ] Performance acceptable (< 3s load time)

### Integration Success

- [ ] Next.js CMS can open Flutter app
- [ ] Auto login working
- [ ] URL parameters cleared
- [ ] Fallback to login page working
