import 'package:flutter/material.dart' as material;
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_skeleton.dart';

class CartSkeleton extends StatelessWidget {
  const CartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == material.Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceBackground
            : AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Cart Header Skeleton
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title skeleton
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSecondaryBackground
                        : AppColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Delete button skeleton
                Container(
                  width: 80,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSecondaryBackground
                        : AppColors.secondaryBackground,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          // Cart Items Skeleton
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4, // Show 4 skeleton items
              itemBuilder: (context, index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: OurbitSkeleton(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSecondaryBackground
                            : AppColors.secondaryBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Product image skeleton
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurfaceBackground
                                  : AppColors.surfaceBackground,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.image,
                                color: AppColors.mutedForeground,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Product details skeleton
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product name skeleton
                                Container(
                                  width: double.infinity,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkSurfaceBackground
                                        : AppColors.surfaceBackground,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Price skeleton
                                Container(
                                  width: 80,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkSurfaceBackground
                                        : AppColors.surfaceBackground,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Quantity controls skeleton
                          Column(
                            children: [
                              // Quantity display skeleton
                              Container(
                                width: 40,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.darkSurfaceBackground
                                      : AppColors.surfaceBackground,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // +/- buttons skeleton
                              Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkSurfaceBackground
                                          : AppColors.surfaceBackground,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppColors.darkSurfaceBackground
                                          : AppColors.surfaceBackground,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Cart Total Skeleton
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSecondaryBackground
                  : AppColors.secondaryBackground,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                // Total row skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 60,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceBackground
                            : AppColors.surfaceBackground,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceBackground
                            : AppColors.surfaceBackground,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Pay button skeleton
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceBackground
                        : AppColors.surfaceBackground,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
