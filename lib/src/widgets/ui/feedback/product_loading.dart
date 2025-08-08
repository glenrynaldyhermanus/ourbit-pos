import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';

class ProductLoading extends StatelessWidget {
  const ProductLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: 12, // Show 12 skeleton products
          itemBuilder: (context, index) {
            return Card(
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
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Product image skeleton
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: themeService.isDarkMode 
                            ? AppColors.darkTertiary 
                            : AppColors.muted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Product name skeleton
                    DefaultTextStyle(
                      style: TextStyle(
                        color: themeService.isDarkMode 
                            ? AppColors.darkPrimaryText 
                            : AppColors.primaryText,
                      ),
                      child: const Text('Product Name').semiBold().asSkeleton(),
                    ),
                    const SizedBox(height: 4),
                    // Price skeleton
                    DefaultTextStyle(
                      style: TextStyle(
                        color: themeService.isDarkMode 
                            ? AppColors.darkSecondaryText 
                            : AppColors.secondaryText,
                      ),
                      child: const Text('Rp 0').muted().small().asSkeleton(),
                    ),
                    const SizedBox(height: 4),
                    // Stock skeleton
                    DefaultTextStyle(
                      style: TextStyle(
                        color: themeService.isDarkMode 
                            ? AppColors.darkSecondaryText 
                            : AppColors.secondaryText,
                      ),
                      child: const Text('Stok: 0').muted().xSmall().asSkeleton(),
                    ),
                    const SizedBox(height: 8),
                    // Button skeleton
                    Container(
                      height: 32,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: themeService.isDarkMode 
                            ? AppColors.darkTertiary 
                            : AppColors.muted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
} 