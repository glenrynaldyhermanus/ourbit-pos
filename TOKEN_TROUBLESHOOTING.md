# 🔧 Token Authentication Troubleshooting

## 🚨 Masalah: Token Tidak Berfungsi

### Gejala

- Token terkirim dengan benar di URL
- Aplikasi tetap redirect ke login page
- Auto login tidak berfungsi

### Penyebab

Router tidak mengecek token dari URL sebelum redirect ke login page.

## ✅ Solusi yang Telah Diimplementasikan

### 1. **Router Redirect Logic**

```dart
// lib/src/core/routes/app_router.dart
redirect: (context, state) async {
  // Skip redirect logic for login page
  if (state.matchedLocation == loginRoute) {
    return null;
  }

  // Check if user is authenticated
  try {
    // First, try to handle token from URL if on web
    if (kIsWeb) {
      final hasToken = await TokenService.handleTokenFromUrl();
      if (hasToken) {
        print('Token processed successfully, redirecting to POS');
        return posRoute;
      }
    }

    // Check if user is authenticated via Supabase
    final isAuthenticated = await SupabaseService.isUserAuthenticated();
    if (isAuthenticated) {
      print('User is authenticated, allowing access');
      return null; // Allow access to requested route
    }
  } catch (e) {
    print('Error checking authentication: $e');
  }

  // If not authenticated, redirect to login
  print('User not authenticated, redirecting to login');
  return loginRoute;
},
```

### 2. **SupabaseService Method**

```dart
// lib/src/core/services/supabase_service.dart
static Future<bool> isUserAuthenticated() async {
  try {
    final user = client.auth.currentUser;
    return user != null;
  } catch (e) {
    print('Error checking user authentication: $e');
    return false;
  }
}
```

## 🔍 Debugging Steps

### 1. **Cek Console Logs**

Buka Developer Tools (F12) dan cek console untuk pesan:

- `Token processed successfully, redirecting to POS`
- `User is authenticated, allowing access`
- `User not authenticated, redirecting to login`

### 2. **Validasi Token Format**

```javascript
// Token harus dalam format yang benar
const token =
	"eyJhbGciOiJIUzI1NiIsImtpZCI6IkVCN2lrdnlGb3pBZ3BtL0kiLCJ0eXAiOiJKV1QifQ...";
const expiry = "2025-07-27T07:02:21.512Z";

const url = `https://ourbit-cashier.web.app/?token=${token}&expiry=${expiry}`;
```

### 3. **Test Token Expiry**

````javascript
// Pastikan expiry time masih valid
const expiry = new Date("2025-07-27T07:02:21.512Z");
const now = new Date();

if (expiry > now) {
	console.log("Token masih valid");
} else {
	console.log("Token sudah expired");
}

### 4. **URL Format yang Benar**

```javascript
// ✅ BENAR - tanpa hash fragment
const correctUrl = `https://ourbit-cashier.web.app/?token=${token}&expiry=${expiry}`;

// ❌ SALAH - dengan hash fragment
const wrongUrl = `https://ourbit-cashier.web.app/?token=${token}&expiry=${expiry}#/login`;
````

## 🧪 Testing

### 1. **Test dengan Token Valid**

```
https://ourbit-cashier.web.app/?token=YOUR_TOKEN&expiry=2025-07-27T07:02:21.512Z
```

### 2. **Expected Behavior**

1. Aplikasi membuka URL dengan token
2. Token diproses oleh `TokenService.handleTokenFromUrl()`
3. Session diset di Supabase
4. User data dimuat
5. URL parameters di-clear
6. Redirect ke POS page (bukan login)

### 3. **Console Logs yang Diharapkan**

```
Token processed successfully, redirecting to POS
Session token set successfully
User data saved to local storage
```

## 🔧 Common Issues & Solutions

### Issue 1: URL Not Found dengan Token Parameters

**Gejala**: URL dengan token `https://ourbit-cashier.web.app/?token=xxx&expiry=xxx` menghasilkan "URL not found"

**Penyebab**: Router tidak mengenali root path dengan query parameters

**Solusi**: Tambahkan root route handler di GoRouter

```dart
// lib/src/core/routes/app_router.dart
GoRoute(
  path: '/',
  name: 'root',
  redirect: (context, state) {
    final token = state.uri.queryParameters['token'];
    final expiry = state.uri.queryParameters['expiry'];

    if (token != null && expiry != null) {
      // Token will be handled by global redirect
      return null;
    }

    return loginRoute;
  },
),
```

### Issue 2: Hash Fragment Problem

**Gejala**: URL dengan `#/login` menyebabkan redirect ke login page

**Solusi**:

```javascript
// ❌ SALAH - jangan tambah #/login
const wrongUrl = `https://ourbit-cashier.web.app/?token=${token}&expiry=${expiry}#/login`;

// ✅ BENAR - tanpa hash fragment
const correctUrl = `https://ourbit-cashier.web.app/?token=${token}&expiry=${expiry}`;
```

### Issue 2: Token Tidak Terdeteksi

**Gejala**: Console log "Token processed successfully" tidak muncul

**Solusi**:

```dart
// Pastikan URL parameters benar
final uri = Uri.parse(html.window.location.href);
final token = uri.queryParameters['token'];
final expiry = uri.queryParameters['expiry'];

print('Token: $token');
print('Expiry: $expiry');
```

### Issue 2: Token Expired

**Gejala**: Token ada tapi tidak diproses

**Solusi**:

```javascript
// Generate expiry yang valid (24 jam dari sekarang)
const expiry = new Date(Date.now() + 24 * 60 * 60 * 1000);
```

### Issue 3: JWT Token Format Error

**Gejala**: Error `"eyJhbGciOi"... is not valid JSON` atau `SyntaxError: Unexpected token`

**Penyebab**: Supabase `recoverSession` method mengharapkan format session lengkap, bukan hanya access token JWT

**Solusi**: Gunakan `getUser` method dengan token

```dart
// lib/src/core/services/supabase_service.dart
static Future<void> setSessionToken(String token) async {
  try {
    // Decode the JWT token to extract user information
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid JWT token format');
    }

    // For Supabase Flutter, we need to manually refresh the session
    // Try to get the user info using the token
    final response = await client.auth.getUser(token);

    if (response.user != null) {
      // The session should be automatically set if the token is valid
      print('Session token set successfully via getUser');
    } else {
      throw Exception('Invalid token - no user found');
    }
  } catch (e) {
    print('Error setting session token: $e');
    throw Exception('Failed to set session token: ${e.toString()}');
  }
}
```

### Issue 4: Router Redirect Loop

**Gejala**: Aplikasi stuck di redirect loop

**Solusi**:

```dart
// Tambahkan kondisi untuk mencegah loop
if (state.matchedLocation == loginRoute) {
  return null; // Skip redirect untuk login page
}
```

## 📊 Monitoring

### 1. **Console Logs**

Monitor console logs untuk:

- Token processing status
- Authentication status
- Error messages

### 2. **Network Tab**

Cek network requests untuk:

- Supabase API calls
- Authentication requests
- Error responses

### 3. **Application State**

Monitor state changes:

- User authentication state
- Token storage
- URL parameters

## 🚀 Best Practices

### 1. **Token Security**

- Set expiry time yang reasonable (24 jam)
- Validasi token format
- Clear URL parameters setelah diproses

### 2. **Error Handling**

- Graceful fallback ke login page
- Detailed error logging
- User-friendly error messages

### 3. **Testing**

- Test dengan token valid dan invalid
- Test dengan expiry time yang berbeda
- Test di berbagai browser

## 📝 Checklist

### Pre-deployment

- [ ] Token format valid
- [ ] Expiry time valid
- [ ] Supabase configuration correct
- [ ] Router redirect logic implemented

### Post-deployment

- [ ] Test dengan token valid
- [ ] Test dengan token expired
- [ ] Test dengan token invalid
- [ ] Monitor console logs
- [ ] Verify auto login working

## 🔄 Update Process

### Jika Masih Ada Masalah

1. **Check Console Logs**: Lihat error messages
2. **Validate Token**: Pastikan format dan expiry benar
3. **Test Locally**: Test di development environment
4. **Deploy Fix**: Deploy perbaikan ke production

### Command untuk Deploy Fix

```bash
# Build dan deploy
flutter build web
firebase deploy --only hosting:ourbit-cashier

# Atau gunakan script
./scripts/deploy.sh
```

## 📞 Support

### Debugging Commands

```bash
# Check deployment status
firebase hosting:releases:list

# Check site accessibility
curl -I https://ourbit-cashier.web.app

# Test token URL
curl "https://ourbit-cashier.web.app/?token=TEST&expiry=2025-01-01T00:00:00.000Z"
```

### Resources

- [Firebase Console](https://console.firebase.google.com/project/ourbit-9ac6d/overview)
- [Supabase Dashboard](https://supabase.com/dashboard)
- [Flutter Web Documentation](https://flutter.dev/docs/deployment/web)
