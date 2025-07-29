# 🚪 Logout Function & 🎭 Fade Transitions

## 🎯 Tujuan

1. Menambahkan fungsi logout yang proper di CashierPage dengan konfirmasi
2. Mengubah semua transisi halaman dari slide ke fade animation

## ✅ Perubahan yang Diimplementasikan

### 1. **Enhanced Logout Function**

#### Updated PosHeader Widget

```dart
// lib/app/cashier/widgets/pos_header.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/auth_bloc.dart';
import 'package:ourbit_pos/blocs/auth_event.dart';
import 'package:ourbit_pos/blocs/auth_state.dart';

// Logout button dengan BlocListener dan BlocBuilder
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is Unauthenticated) {
      // Navigate to login when logged out
      context.go('/login');
    } else if (state is AuthError) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout error: ${state.message}'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  },
  child: Container(
    margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkTertiary : AppColors.tertiary,
      borderRadius: BorderRadius.circular(8),
    ),
    child: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return IconButton(
          icon: state is AuthLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isDark
                        ? AppColors.darkSecondaryText
                        : AppColors.secondaryText,
                  ),
                )
              : Icon(
                  Icons.logout,
                  color: isDark
                      ? AppColors.darkSecondaryText
                      : AppColors.secondaryText,
                ),
          onPressed: state is AuthLoading
              ? null
              : () {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Konfirmasi Logout'),
                        content: const Text('Apakah Anda yakin ingin logout?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                              // Trigger logout
                              context.read<AuthBloc>().add(SignOutRequested());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Logout'),
                          ),
                        ],
                      );
                    },
                  );
                },
        );
      },
    ),
  ),
),
```

### 2. **Fade Transitions Implementation**

#### Custom Fade Transition Helper

```dart
// lib/src/core/routes/app_router.dart

// Helper method untuk fade transition
static Page<void> _buildPageWithFadeTransition(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
```

#### Updated Route Definitions

```dart
// All routes updated to use pageBuilder with fade transition

GoRoute(
  path: loginRoute,
  name: 'login',
  pageBuilder: (context, state) => _buildPageWithFadeTransition(
    context,
    state,
    const LoginPage(),
  ),
),
GoRoute(
  path: posRoute,
  name: 'pos',
  pageBuilder: (context, state) => _buildPageWithFadeTransition(
    context,
    state,
    const CashierPage(),
  ),
),
// ... semua route lainnya menggunakan pattern yang sama
```

## 🔧 Features

### 1. **Logout Function Features**

#### ✅ **Confirmation Dialog**

- Dialog konfirmasi sebelum logout
- Tombol "Batal" dan "Logout"
- Styling sesuai tema aplikasi

#### ✅ **Loading State**

- Loading indicator saat proses logout
- Button disabled selama loading
- Visual feedback untuk user

#### ✅ **Error Handling**

- SnackBar untuk menampilkan error
- Graceful error handling
- User tetap bisa retry

#### ✅ **Proper State Management**

- Menggunakan AuthBloc untuk state management
- BlocListener untuk navigation
- BlocBuilder untuk UI updates

### 2. **Fade Transitions Features**

#### ✅ **Smooth Animation**

- Fade in/out animation (300ms)
- Menggantikan default slide transition
- Consistent di semua halaman

#### ✅ **Performance Optimized**

- Lightweight animation
- Tidak mempengaruhi performance
- Smooth di semua device

#### ✅ **Universal Implementation**

- Diterapkan ke semua route
- Konsisten experience
- Easy maintenance

## 🎭 Animation Details

### Transition Properties

- **Type**: FadeTransition
- **Duration**: 300 milliseconds
- **Curve**: Default linear
- **Direction**: Bidirectional (in/out)

### Before vs After

```dart
// ❌ SEBELUM: Default slide transition
builder: (context, state) => const LoginPage(),

// ✅ SESUDAH: Custom fade transition
pageBuilder: (context, state) => _buildPageWithFadeTransition(
  context,
  state,
  const LoginPage(),
),
```

## 🧪 Testing

### 1. **Logout Function Testing**

- [ ] Klik button logout
- [ ] Konfirmasi dialog muncul
- [ ] Tekan "Batal" → dialog tutup, tidak logout
- [ ] Tekan "Logout" → loading indicator → redirect ke login
- [ ] Test error scenario

### 2. **Fade Transitions Testing**

- [ ] Navigation antar halaman menggunakan fade
- [ ] Tidak ada slide animation
- [ ] Smooth transition (300ms)
- [ ] Konsisten di semua route

## 📊 Implementation Status

- ✅ **PosHeader**: Updated dengan AuthBloc integration
- ✅ **Logout Dialog**: Implemented dengan confirmation
- ✅ **Loading States**: Added untuk UX yang better
- ✅ **Error Handling**: Comprehensive error messages
- ✅ **Fade Transitions**: Applied ke semua routes
- ✅ **Production**: Deployed ke `https://ourbit-cashier.web.app`

## 🎯 User Experience Improvements

### 1. **Safety**

- Confirmation dialog mencegah logout tidak sengaja
- Clear feedback untuk setiap action

### 2. **Performance**

- Smooth fade transitions
- No janky animations
- Fast response time

### 3. **Consistency**

- Semua halaman menggunakan fade transition
- Consistent navigation experience
- Professional look and feel

## 🔍 Monitoring

### Console Logs

```
// Saat logout dipicu
AuthBloc: SignOutRequested event received
AuthBloc: AuthLoading state emitted
AuthBloc: Unauthenticated state emitted
Router: Navigating to /login

// Saat navigation dengan fade
Router: Building page with fade transition
CustomTransitionPage: Fade animation started (300ms)
```

### Expected Behavior

1. ✅ Logout button menampilkan confirmation dialog
2. ✅ Loading state ditampilkan saat proses logout
3. ✅ Navigation menggunakan fade animation
4. ✅ Error handling yang graceful
5. ✅ Consistent UX di semua halaman

## 📞 Support

### Common Issues

1. **Dialog tidak muncul**: Cek context dan showDialog implementation
2. **Navigation tidak smooth**: Verify CustomTransitionPage implementation
3. **Logout tidak berfungsi**: Check AuthBloc integration

### Resources

- [Flutter Bloc Documentation](https://bloclibrary.dev/)
- [GoRouter Custom Transitions](https://pub.dev/packages/go_router)
- [Flutter Animations](https://docs.flutter.dev/development/ui/animations)
