import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_dialog.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_circular_progress.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoresContentMobile extends StatefulWidget {
  const StoresContentMobile({super.key});

  @override
  State<StoresContentMobile> createState() => _StoresContentMobileState();
}

class _StoresContentMobileState extends State<StoresContentMobile>
    with TickerProviderStateMixin {
  String _query = '';
  String? _businessId;
  bool _loading = false;
  List<Map<String, dynamic>> _stores = [];
  Map<String, String> _businessFieldOptions = {};

  // Animation controllers
  late AnimationController _listController;
  late AnimationController _detailController;
  // ignore: unused_field
  String? _selectedStoreId;

  @override
  void initState() {
    super.initState();
    _initAnimationControllers();
    _initialize();
  }

  void _initAnimationControllers() {
    _listController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _detailController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _listController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() => _loading = true);
    try {
      final businessData = await LocalStorageService.getBusinessData();
      final idValue = businessData?['id'];
      _businessId = idValue is String ? idValue : (idValue?.toString());
      await _loadBusinessFieldOptions();
      await _loadStores();
    } catch (e) {
      Logger.error('STORES_MOBILE_INIT_ERROR: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
        _listController.forward();
      }
    }
  }

  Future<void> _loadBusinessFieldOptions() async {
    try {
      final res = await Supabase.instance.client
          .schema('common')
          .from('options')
          .select('key, value')
          .eq('type', 'business_field');
      final map = <String, String>{};
      for (final e in (res as List)) {
        final m = Map<String, dynamic>.from(e);
        final k = (m['key'] ?? '').toString();
        final v = (m['value'] ?? '').toString();
        if (k.isNotEmpty) map[k] = v;
      }
      _businessFieldOptions = map;
    } catch (e) {
      Logger.error('STORES_MOBILE_LOAD_OPTIONS_ERROR: $e');
    }
  }

  Future<void> _loadStores() async {
    if (_businessId == null || _businessId!.isEmpty) {
      Logger.error('STORES_MOBILE_LOAD: businessId null/empty');
      setState(() => _stores = []);
      return;
    }
    try {
      final res = await Supabase.instance.client
          .schema('common')
          .from('stores')
          .select()
          .eq('business_id', _businessId as Object);
      final list = (res as List)
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();
      setState(() => _stores = list);
    } catch (e) {
      Logger.error('STORES_MOBILE_LOAD_ERROR: $e');
      setState(() => _stores = []);
    }
  }

  Future<void> _deleteStore(String id, String name) async {
    final confirmed = await OurbitDialog.show(
      context: context,
      title: 'Hapus Toko',
      content: 'Apakah Anda yakin ingin menghapus "$name"?',
      confirmText: 'Hapus',
      cancelText: 'Batal',
      isDestructive: true,
    );
    if (confirmed != true) return;
    try {
      await Supabase.instance.client
          .schema('common')
          .from('stores')
          .delete()
          .eq('id', id);
      await _loadStores();
      if (!mounted) return;
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: Text('Toko "$name" berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Logger.error('DELETE_STORE_MOBILE_ERROR: $e');
      if (!mounted) return;
      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(
          content: Text('Gagal menghapus toko'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showStoreDetail(Map<String, dynamic> store) {
    _selectedStoreId = store['id']?.toString();
    _detailController.forward();

    material
        .showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: material.Theme.of(context).colorScheme.surface,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                material.CircleAvatar(
                  backgroundColor: material.Theme.of(context).brightness ==
                          material.Brightness.dark
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15)
                      : Colors.blue[50],
                  child: Icon(
                    Icons.store,
                    color:
                        Theme.of(context).brightness == material.Brightness.dark
                            ? Theme.of(context).colorScheme.primary
                            : Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (store['name'] ?? '-').toString(),
                        style: material.Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _businessFieldOptions[
                                (store['business_field'] ?? '').toString()] ??
                            (store['business_field'] ?? '-').toString(),
                        style: material.Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: material.Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.8),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnimatedDetailRow(
                'Alamat', (store['address'] ?? '-').toString(), 0),
            _buildAnimatedDetailRow(
              'Telepon',
              '${store['phone_country_code'] ?? ''} ${store['phone_number'] ?? ''}',
              1,
            ),
            _buildAnimatedDetailRow(
                'Tipe', store['is_branch'] == true ? 'Cabang' : 'Pusat', 2),
            _buildAnimatedDetailRow(
                'Mata Uang', (store['currency'] ?? '-').toString(), 3),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OurbitButton.secondary(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // TODO: Open edit form
                    },
                    label: 'Edit',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OurbitButton.destructive(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteStore(
                        (store['id'] ?? '').toString(),
                        (store['name'] ?? '-').toString(),
                      );
                    },
                    label: 'Hapus',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    )
        .then((_) {
      _selectedStoreId = null;
      _detailController.reset();
    });
  }

  Widget _buildAnimatedDetailRow(String label, String value, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - opacity)),
            child: _buildDetailRow(label, value),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return const Center(
        child: OurbitCircularProgress(),
      );
    }

    final filtered = _stores.where((s) {
      if (_query.isEmpty) return true;
      final name = (s['name'] ?? '').toString().toLowerCase();
      final address = (s['address'] ?? '').toString().toLowerCase();
      final field = (s['business_field'] ?? '').toString().toLowerCase();
      return name.contains(_query) ||
          address.contains(_query) ||
          field.contains(_query);
    }).toList();

    return Column(
      children: [
        // Search
        Padding(
          padding: const EdgeInsets.all(16),
          child: OurbitTextInput(
            placeholder: 'Cari toko berdasarkan nama/alamat/bidang usaha',
            leading: const Icon(Icons.search, size: 16),
            onChanged: (v) {
              setState(() {
                _query = (v ?? '').trim().toLowerCase();
              });
            },
          ),
        ),

        // List
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: filtered.isEmpty
                ? Center(
                    key: const ValueKey('empty'),
                    child: Text(
                      'Tidak ada toko',
                      style: TextStyle(
                        color: Theme.of(context).brightness ==
                                material.Brightness.dark
                            ? AppColors.darkSecondaryText
                            : AppColors.secondaryText,
                      ),
                    ),
                  )
                : FadeTransition(
                    opacity: _listController,
                    child: ListView.separated(
                      key: const ValueKey('list'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final s = filtered[index];
                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 150 + (index * 50)),
                          tween: Tween(begin: 0.0, end: 1.0),
                          builder: (context, opacity, child) {
                            return Opacity(
                              opacity: opacity,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - opacity)),
                                child: OurbitCard(
                                  child: material.ListTile(
                                    leading: material.CircleAvatar(
                                      backgroundColor: theme.brightness ==
                                              material.Brightness.dark
                                          ? theme.colorScheme.primary
                                              .withValues(alpha: 0.15)
                                          : Colors.blue[50],
                                      child: Icon(
                                        Icons.store,
                                        color: theme.brightness ==
                                                material.Brightness.dark
                                            ? theme.colorScheme.primary
                                            : Colors.blue,
                                      ),
                                    ),
                                    title: Text(
                                      (s['name'] ?? '-').toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).brightness ==
                                                material.Brightness.dark
                                            ? AppColors.darkPrimaryText
                                            : AppColors.primaryText,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _businessFieldOptions[
                                                  (s['business_field'] ?? '')
                                                      .toString()] ??
                                              (s['business_field'] ?? '—')
                                                  .toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                        .brightness ==
                                                    material.Brightness.dark
                                                ? AppColors.darkSecondaryText
                                                : AppColors.secondaryText,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          (s['address'] ?? '—').toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                        .brightness ==
                                                    material.Brightness.dark
                                                ? AppColors.darkSecondaryText
                                                : AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _showStoreDetail(s),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
