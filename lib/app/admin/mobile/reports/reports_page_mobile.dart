import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/widgets/navigation/sidebar_drawer.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';

class ReportsPageMobile extends material.StatefulWidget {
  const ReportsPageMobile({super.key});

  @override
  material.State<ReportsPageMobile> createState() => _ReportsPageMobileState();
}

class _ReportsPageMobileState extends material.State<ReportsPageMobile>
    with material.TickerProviderStateMixin {
  String _selectedPeriod = 'today';
  String _selectedStore = 'all';

  // Animation controllers
  late material.AnimationController _listController;
  late material.AnimationController _filterController;

  final List<Map<String, dynamic>> _reportTypes = [
    {
      'id': 'sales',
      'name': 'Laporan Penjualan',
      'description': 'Ringkasan penjualan harian, mingguan, bulanan',
      'icon': material.Icons.receipt_long,
      'color': material.Colors.green,
    },
    {
      'id': 'inventory',
      'name': 'Laporan Stok',
      'description': 'Status stok produk dan pergerakan inventory',
      'icon': material.Icons.inventory_2,
      'color': material.Colors.blue,
    },
    {
      'id': 'customers',
      'name': 'Laporan Pelanggan',
      'description': 'Data pelanggan dan riwayat transaksi',
      'icon': material.Icons.people,
      'color': material.Colors.purple,
    },
    {
      'id': 'expenses',
      'name': 'Laporan Pengeluaran',
      'description': 'Ringkasan pengeluaran dan biaya operasional',
      'icon': material.Icons.account_balance_wallet,
      'color': material.Colors.red,
    },
    {
      'id': 'profit',
      'name': 'Laporan Laba Rugi',
      'description': 'Analisis profitabilitas dan margin',
      'icon': material.Icons.trending_up,
      'color': material.Colors.orange,
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
    _listController = material.AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _filterController = material.AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Start list animation after frame
    material.WidgetsBinding.instance.addPostFrameCallback((_) {
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
      builder: (context) => material.Container(
        padding: const material.EdgeInsets.all(16),
        child: material.Column(
          mainAxisSize: material.MainAxisSize.min,
          crossAxisAlignment: material.CrossAxisAlignment.start,
          children: [
            material.Row(
              children: [
                material.CircleAvatar(
                  backgroundColor: reportType['color'][50],
                  child: material.Icon(
                    reportType['icon'],
                    color: reportType['color'],
                  ),
                ),
                const material.SizedBox(width: 12),
                material.Expanded(
                  child: material.Column(
                    crossAxisAlignment: material.CrossAxisAlignment.start,
                    children: [
                      material.Text(
                        reportType['name'],
                        style: const material.TextStyle(
                          fontSize: 18,
                          fontWeight: material.FontWeight.bold,
                        ),
                      ),
                      material.Text(
                        reportType['description'],
                        style: material.TextStyle(
                          color: material.Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const material.SizedBox(height: 16),
            material.Text(
              'Filter Laporan',
              style: material.Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: material.FontWeight.w600),
            ),
            const material.SizedBox(height: 12),
            material.AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: material.Column(
                children: [
                  material.DropdownButtonFormField<String>(
                    value: _selectedPeriod,
                    decoration: const material.InputDecoration(
                      border: material.OutlineInputBorder(),
                      contentPadding: material.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: _periods
                        .map((p) => material.DropdownMenuItem(
                              value: p['value'] as String,
                              child: material.Text(p['label'] as String),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedPeriod = value ?? 'today');
                    },
                  ),
                  const material.SizedBox(height: 12),
                  material.DropdownButtonFormField<String>(
                    value: _selectedStore,
                    decoration: const material.InputDecoration(
                      border: material.OutlineInputBorder(),
                      contentPadding: material.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: _stores
                        .map((s) => material.DropdownMenuItem(
                              value: s['value'] as String,
                              child: material.Text(s['label'] as String),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedStore = value ?? 'all');
                    },
                  ),
                ],
              ),
            ),
            const material.SizedBox(height: 16),
            material.Row(
              children: [
                material.Expanded(
                  child: OurbitButton.secondary(
                    onPressed: () {
                      material.Navigator.of(context).pop();
                      _filterController.reverse();
                    },
                    label: 'Batal',
                  ),
                ),
                const material.SizedBox(width: 8),
                material.Expanded(
                  child: OurbitButton.primary(
                    onPressed: () {
                      material.Navigator.of(context).pop();
                      _filterController.reverse();
                      _generateReport(reportType);
                    },
                    label: 'Generate',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .then((_) {
      _filterController.reverse();
    });
  }

  void _generateReport(Map<String, dynamic> reportType) {
    material.ScaffoldMessenger.of(context).showSnackBar(
      material.SnackBar(
        content: material.Text(
          'Generating ${reportType['name']} untuk periode $_selectedPeriod...',
        ),
        backgroundColor: material.Colors.blue,
      ),
    );

    // TODO: Implement actual report generation
    // This would typically call a service to generate the report
    // and then show it in a new screen or download it
  }

  material.Widget _buildReportCard(Map<String, dynamic> reportType, int index) {
    return material.TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 100)),
      tween: material.Tween(begin: 0.0, end: 1.0),
      builder: (context, progress, child) {
        return material.Opacity(
          opacity: progress,
          child: material.Transform.translate(
            offset: material.Offset(0, 30 * (1 - progress)),
            child: OurbitCard(
              child: material.ListTile(
                leading: material.CircleAvatar(
                  backgroundColor: reportType['color'][50],
                  child: material.Icon(
                    reportType['icon'],
                    color: reportType['color'],
                  ),
                ),
                title: material.Text(
                  reportType['name'],
                  style: const material.TextStyle(
                    fontWeight: material.FontWeight.w600,
                  ),
                ),
                subtitle: material.Text(
                  reportType['description'],
                  maxLines: 2,
                  overflow: material.TextOverflow.ellipsis,
                ),
                trailing: material.IconButton(
                  icon: const material.Icon(material.Icons.arrow_forward_ios),
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
  material.Widget build(material.BuildContext context) {
    return material.Scaffold(
      appBar: material.AppBar(
        title: const material.Text('Laporan'),
        leading: material.Builder(
          builder: (context) => material.IconButton(
            icon: const material.Icon(material.Icons.menu),
            onPressed: () => material.Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const SidebarDrawer(),
      body: material.Column(
        children: [
          // Search and Filter
          material.Padding(
            padding: const material.EdgeInsets.all(16),
            child: material.Column(
              children: [
                OurbitTextInput(
                  placeholder: 'Cari laporan...',
                  leading: const material.Icon(material.Icons.search, size: 16),
                ),
                const material.SizedBox(height: 12),
                material.Row(
                  children: [
                    material.Expanded(
                      child: material.DropdownButtonFormField<String>(
                        value: _selectedPeriod,
                        decoration: const material.InputDecoration(
                          border: material.OutlineInputBorder(),
                          contentPadding: material.EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        items: _periods
                            .map((p) => material.DropdownMenuItem(
                                  value: p['value'] as String,
                                  child: material.Text(p['label'] as String),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedPeriod = value ?? 'today');
                        },
                      ),
                    ),
                    const material.SizedBox(width: 8),
                    material.Expanded(
                      child: material.DropdownButtonFormField<String>(
                        value: _selectedStore,
                        decoration: const material.InputDecoration(
                          border: material.OutlineInputBorder(),
                          contentPadding: material.EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                        ),
                        items: _stores
                            .map((s) => material.DropdownMenuItem(
                                  value: s['value'] as String,
                                  child: material.Text(s['label'] as String),
                                ))
                            .toList(),
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
          material.Expanded(
            child: material.FadeTransition(
              opacity: _listController,
              child: material.ListView.separated(
                padding: const material.EdgeInsets.symmetric(horizontal: 16),
                itemCount: _reportTypes.length,
                separatorBuilder: (_, __) => const material.SizedBox(height: 8),
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
  }
}
