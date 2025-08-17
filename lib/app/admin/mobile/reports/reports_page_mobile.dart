import 'package:flutter/material.dart' as material;

import 'package:ourbit_pos/src/widgets/navigation/sidebar_drawer.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ReportsPageMobile extends StatefulWidget {
  const ReportsPageMobile({super.key});

  @override
  State<ReportsPageMobile> createState() => _ReportsPageMobileState();
}

class _ReportsPageMobileState extends State<ReportsPageMobile>
    with TickerProviderStateMixin {
  String _selectedPeriod = 'today';
  String _selectedStore = 'all';

  // Animation controllers
  late AnimationController _listController;
  late AnimationController _filterController;

  final List<Map<String, dynamic>> _reportTypes = [
    {
      'id': 'sales',
      'name': 'Laporan Penjualan',
      'description': 'Ringkasan penjualan harian, mingguan, bulanan',
      'icon': Icons.receipt_long,
      'color': Colors.green,
    },
    {
      'id': 'inventory',
      'name': 'Laporan Stok',
      'description': 'Status stok produk dan pergerakan inventory',
      'icon': Icons.inventory_2,
      'color': Colors.blue,
    },
    {
      'id': 'customers',
      'name': 'Laporan Pelanggan',
      'description': 'Data pelanggan dan riwayat transaksi',
      'icon': Icons.people,
      'color': Colors.purple,
    },
    {
      'id': 'expenses',
      'name': 'Laporan Pengeluaran',
      'description': 'Ringkasan pengeluaran dan biaya operasional',
      'icon': Icons.account_balance_wallet,
      'color': Colors.red,
    },
    {
      'id': 'profit',
      'name': 'Laporan Laba Rugi',
      'description': 'Analisis profitabilitas dan margin',
      'icon': Icons.trending_up,
      'color': Colors.orange,
    },
  ];

  final List<Map<String, dynamic>> _periods = [
    {'value': 'today', 'label': 'Hari Ini'},
    {'value': 'yesterday', 'label': 'Kemarin'},
    {'value': 'week', 'label': 'Minggu Ini'},
    {'value': 'month', 'label': 'Bulan Ini'},
    {'value': 'quarter', 'label': 'Kuartal Ini'},
    {'value': 'year', 'label': 'Tahun Ini'},
    {'value': 'custom', 'label': 'Kustom'},
  ];

  final List<Map<String, dynamic>> _stores = [
    {'value': 'all', 'label': 'Semua Toko'},
    {'value': 'store1', 'label': 'Toko Pusat'},
    {'value': 'store2', 'label': 'Cabang 1'},
    {'value': 'store3', 'label': 'Cabang 2'},
  ];

  @override
  void initState() {
    super.initState();
    _initAnimationControllers();
  }

  void _initAnimationControllers() {
    _listController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _filterController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Start list animation after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listController.forward();
    });
  }

  @override
  void dispose() {
    _listController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  void _showReportDetail(Map<String, dynamic> reportType) {
    _filterController.forward();

    material
        .showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == material.Brightness.dark;
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            child: OurbitCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      reportType['icon'] as IconData,
                      size: 64,
                      color: (reportType['color'] as Color?)
                              ?.withValues(alpha: 0.9) ??
                          (isDark ? Colors.gray[300] : Colors.gray[700]),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      reportType['name'] as String,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reportType['description'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.gray[400] : Colors.gray[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Coming Soon',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[600],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    )
        .then((_) {
      _filterController.reverse();
    });
  }

  // Placeholder agar kompatibel jika nantinya diperlukan

  Widget _buildReportCard(Map<String, dynamic> reportType, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, progress, child) {
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - progress)),
            child: OurbitCard(
              child: material.ListTile(
                leading: material.CircleAvatar(
                  backgroundColor: reportType['color'][50],
                  child: Icon(
                    reportType['icon'],
                    color: reportType['color'],
                  ),
                ),
                title: Text(
                  reportType['name'],
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color:
                        Theme.of(context).brightness == material.Brightness.dark
                            ? AppColors.darkPrimaryText
                            : AppColors.primaryText,
                  ),
                ),
                subtitle: Text(
                  reportType['description'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color:
                        Theme.of(context).brightness == material.Brightness.dark
                            ? AppColors.darkSecondaryText
                            : AppColors.secondaryText,
                  ),
                ),
                trailing: material.IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () => _showReportDetail(reportType),
                ),
                onTap: () => _showReportDetail(reportType),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        final bool isDark = themeService.isDarkMode;
        return material.Scaffold(
          backgroundColor: isDark
              ? AppColors.darkSurfaceBackground
              : AppColors.surfaceBackground,
          appBar: material.AppBar(
            backgroundColor: isDark
                ? AppColors.darkSurfaceBackground
                : AppColors.surfaceBackground,
            foregroundColor:
                isDark ? AppColors.darkPrimaryText : AppColors.primaryText,
            title: const Text('Laporan'),
            leading: material.Builder(
              builder: (context) => material.IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => material.Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          drawer: const SidebarDrawer(),
          body: Column(
            children: [
              // Search and Filter
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const OurbitTextInput(
                      placeholder: 'Cari laporan...',
                      leading: Icon(Icons.search, size: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OurbitSelect<String>(
                            value: _selectedPeriod,
                            items: _periods
                                .map((p) => p['value'] as String)
                                .toList(),
                            itemBuilder: (context, item) => Text(
                              _periods.firstWhere(
                                  (p) => p['value'] == item)['label'] as String,
                            ),
                            placeholder: const Text('Periode'),
                            onChanged: (value) {
                              setState(
                                  () => _selectedPeriod = value ?? 'today');
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OurbitSelect<String>(
                            value: _selectedStore,
                            items: _stores
                                .map((s) => s['value'] as String)
                                .toList(),
                            itemBuilder: (context, item) => Text(
                              _stores.firstWhere(
                                  (s) => s['value'] == item)['label'] as String,
                            ),
                            placeholder: const Text('Toko'),
                            onChanged: (value) {
                              setState(() => _selectedStore = value ?? 'all');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Report Types List
              Expanded(
                child: FadeTransition(
                  opacity: _listController,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _reportTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final reportType = _reportTypes[index];
                      return _buildReportCard(reportType, index);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
