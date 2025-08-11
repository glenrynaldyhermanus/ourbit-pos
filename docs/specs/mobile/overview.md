# Mobile View Implementation Overview

## Pendahuluan

Dokumen ini menjelaskan implementasi mobile view untuk aplikasi Ourbit POS. Mobile view dirancang untuk memberikan pengalaman yang optimal pada perangkat mobile dengan screen width < 768px, menggunakan adaptive routing dan responsive design.

## Arsitektur Mobile

### Adaptive Routing
- **Router**: `lib/src/core/routes/app_router.dart`
- **Responsive Detection**: `lib/src/core/utils/responsive.dart`
- **Breakpoint**: Mobile < 768px, Tablet 768-1024px, Desktop ≥ 1024px

### Struktur Folder
```
lib/app/admin/mobile/
├── cashier/
│   ├── cashier_page_mobile.dart
│   └── payment/
│       ├── payment_page_mobile.dart
│       └── success_page_mobile.dart
├── management/
│   ├── management_page_mobile.dart
│   ├── products/
│   ├── categories/
│   ├── customers/
│   ├── suppliers/
│   ├── expenses/
│   ├── discounts/
│   ├── loyalty/
│   ├── inventory/
│   └── taxes/
├── organization/
│   ├── organization_page_mobile.dart
│   ├── stores/
│   ├── staffs/
│   └── onlinestores/
├── settings/
│   ├── settings_page_mobile.dart
│   ├── profile/
│   └── printer/
└── reports/
    └── reports_page_mobile.dart
```

## Komponen Mobile-Specific

### Navigation
- **SidebarDrawer**: `lib/src/widgets/navigation/sidebar_drawer.dart`
- **TabBar**: Untuk sub-navigation di Management, Organization, Settings
- **Bottom Sheets**: Untuk detail dan actions

### UI Patterns
- **List-Card Layout**: Menggantikan desktop table
- **Search & Filter**: Di setiap section
- **Bottom Action Bar**: Untuk primary actions
- **SnackBar**: Untuk feedback (sesuai rules mobile)

## Responsive Detection

```dart
// lib/src/core/utils/responsive.dart
static bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < 768;
```

## Routing Pattern

```dart
// Contoh routing adaptif
GoRoute(
  path: posRoute,
  pageBuilder: (context, state) => _buildPageWithFadeTransition(
    context,
    state,
    Responsive.isMobile(context)
        ? const CashierPageMobile()  // Mobile version
        : const CashierPage(),       // Desktop version
  ),
),
```

## Design System

### Component Priority
1. **Ourbit Custom Widgets** (prioritas utama)
2. **Shadcn Flutter** (jika Ourbit tidak tersedia)
3. **Material Widgets** (terakhir)

### Mobile-Specific Rules
- **SnackBar**: Diperbolehkan di mobile UI (`lib/app/admin/mobile/**`)
- **OurbitToast**: Default untuk feedback
- **Bahasa Indonesia**: Semua text dan labels

## State Management

### BLoC Integration
- **Cashier**: `CashierBloc`, `PaymentBloc`
- **Management**: `ManagementBloc` untuk data CRUD
- **Auth**: `AuthBloc` untuk authentication

### Data Flow
- **Supabase**: Primary data source
- **Local Storage**: Untuk user preferences
- **Real-time**: Untuk inventory updates

## Performance Considerations

### Lazy Loading
- Content loaded on demand
- Efficient Supabase queries
- Proper dispose patterns

### Memory Management
- Cleanup resources on dispose
- Optimized list rendering
- Efficient state management

## Testing Strategy

### Functional Testing
- Navigation flow (Drawer → TabBar → Content)
- Data loading dan CRUD operations
- Search dan filter functionality
- Payment flow (Cart → Payment → Success)

### UI Testing
- Responsive design pada berbagai screen sizes
- Touch interactions
- Bottom sheet dan modal behavior
- Form validation

## Deployment

### Platform Support
- **Android**: Full support
- **iOS**: Full support
- **Web**: Responsive web support
- **Desktop**: Fallback ke desktop view

### Build Configuration
- Adaptive routing enabled
- Mobile-specific assets
- Performance optimizations
