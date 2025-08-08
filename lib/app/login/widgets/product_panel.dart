import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/app/login/widgets/feature_item.dart';

class ProductPanel extends StatefulWidget {
  const ProductPanel({super.key});

  @override
  State<ProductPanel> createState() => _ProductPanelState();
}

class _ProductPanelState extends State<ProductPanel>
    with TickerProviderStateMixin {
  late AnimationController _leftPanelController;
  late AnimationController _fadeController;
  late Animation<double> _leftPanelSlideAnimation;
  late Animation<double> _fadeAnimation;
  final String _versionText = 'Versi 1.0.0';

  @override
  void initState() {
    super.initState();

    _leftPanelController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _leftPanelSlideAnimation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _leftPanelController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _leftPanelController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
  }

  @override
  void dispose() {
    _leftPanelController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(builder: (context, themeService, _) {
      return AnimatedBuilder(
        animation: _leftPanelController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_leftPanelSlideAnimation.value * 100, 0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: themeService.isDarkMode
                      ? [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ]
                      : [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo Section
                      const Gap(48),
                      // Welcome Text
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Datang',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const Gap(8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Ourbit POS',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -1,
                                  ),
                                ),
                                const Gap(12),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(4)),
                                    ),
                                    child: Text(
                                      _versionText,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(4),
                            Text(
                              'Sistem Point of Sale Terpadu untuk Bisnis Modern',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withValues(alpha: 0.9),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Features Section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fitur Utama',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Gap(24),
                            FeatureItem(
                              icon: LucideIcons.shoppingCart,
                              title: 'Point of Sale',
                              description:
                                  'Sistem kasir modern dengan interface yang intuitif dan cepat',
                            ),
                            Gap(16),
                            FeatureItem(
                              icon: LucideIcons.package,
                              title: 'Manajemen Inventori',
                              description:
                                  'Kelola stok produk, tracking real-time, dan alert low stock',
                            ),
                            Gap(16),
                            FeatureItem(
                              icon: LucideIcons.globe,
                              title: 'Online Store',
                              description:
                                  'Integrasi dengan toko online untuk penjualan multi-channel',
                            ),
                            Gap(16),
                            FeatureItem(
                              icon: LucideIcons.users,
                              title: 'Manajemen Pelanggan',
                              description:
                                  'Database pelanggan lengkap dengan riwayat transaksi',
                            ),
                            Gap(16),
                            FeatureItem(
                              icon: LucideIcons.trendingUp,
                              title: 'Analytics & Laporan',
                              description:
                                  'Laporan penjualan, analisis tren, dan dashboard real-time',
                            ),
                          ],
                        ),
                      ),
                      const Gap(32),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
