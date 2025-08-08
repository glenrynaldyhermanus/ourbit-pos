import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';

/// Custom toast widget untuk Ourbit
/// Memudahkan penggunaan toast dengan hanya perlu memasukkan title dan content
class OurbitToast {
  /// Menampilkan toast dengan title dan content
  ///
  /// [context] - BuildContext
  /// [title] - Judul toast
  /// [content] - Isi pesan toast
  /// [type] - Tipe toast (success, error, warning, info)
  /// [location] - Lokasi toast (default: bottomRight)
  static void show({
    required BuildContext context,
    required String title,
    required String content,
    ToastType type = ToastType.info,
    ToastLocation location = ToastLocation.bottomRight,
  }) {
    showToast(
      context: context,
      builder: (context, overlay) {
        return Consumer<ThemeService>(
          builder: (context, themeService, child) {
            return SurfaceCard(
              child: Container(
                decoration: BoxDecoration(
                  color: themeService.isDarkMode 
                      ? AppColors.darkSecondaryBackground 
                      : AppColors.secondaryBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: themeService.isDarkMode 
                        ? AppColors.darkBorder 
                        : AppColors.border,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Basic(
                  title: DefaultTextStyle(
                    style: TextStyle(
                      color: themeService.isDarkMode 
                          ? AppColors.darkPrimaryText 
                          : AppColors.primaryText,
                    ),
                    child: Text(title),
                  ),
                  content: DefaultTextStyle(
                    style: TextStyle(
                      color: themeService.isDarkMode 
                          ? AppColors.darkSecondaryText 
                          : AppColors.secondaryText,
                    ),
                    child: Text(content),
                  ),
                  leading: _getIcon(type),
                  trailing: IconButton.ghost(
                    onPressed: () => overlay.close(),
                    icon: Icon(
                      Icons.close,
                      color: themeService.isDarkMode 
                          ? AppColors.darkSecondaryText 
                          : AppColors.secondaryText,
                    ),
                    size: ButtonSize.small,
                  ),
                  trailingAlignment: Alignment.center,
                ),
              ),
            );
          },
        );
      },
      location: location,
    );
  }

  /// Menampilkan toast sukses
  static void success({
    required BuildContext context,
    required String title,
    required String content,
    ToastLocation location = ToastLocation.bottomRight,
  }) {
    show(
      context: context,
      title: title,
      content: content,
      type: ToastType.success,
      location: location,
    );
  }

  /// Menampilkan toast error
  static void error({
    required BuildContext context,
    required String title,
    required String content,
    ToastLocation location = ToastLocation.bottomRight,
  }) {
    show(
      context: context,
      title: title,
      content: content,
      type: ToastType.error,
      location: location,
    );
  }

  /// Menampilkan toast warning
  static void warning({
    required BuildContext context,
    required String title,
    required String content,
    ToastLocation location = ToastLocation.bottomRight,
  }) {
    show(
      context: context,
      title: title,
      content: content,
      type: ToastType.warning,
      location: location,
    );
  }

  /// Menampilkan toast info
  static void info({
    required BuildContext context,
    required String title,
    required String content,
    ToastLocation location = ToastLocation.bottomRight,
  }) {
    show(
      context: context,
      title: title,
      content: content,
      type: ToastType.info,
      location: location,
    );
  }

  /// Mendapatkan icon berdasarkan tipe toast
  static Widget _getIcon(ToastType type) {
    switch (type) {
      case ToastType.success:
        return const Icon(
          LucideIcons.check,
          color: Color(0xFF4CAF50), // Hijau pastel
        );
      case ToastType.error:
        return const Icon(
          LucideIcons.x,
          color: Color(0xFFE57373), // Merah pastel
        );
      case ToastType.warning:
        return const Icon(
          LucideIcons.messageCircleWarning,
          color: Color(0xFFFFB74D), // Orange pastel
        );
      case ToastType.info:
        return const Icon(
          LucideIcons.info,
          color: Color(0xFF81C784), // Biru pastel
        );
    }
  }
}

/// Enum untuk tipe toast
enum ToastType {
  success,
  error,
  warning,
  info,
}
