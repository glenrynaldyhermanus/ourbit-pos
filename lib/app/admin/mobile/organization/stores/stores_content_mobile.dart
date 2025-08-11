import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_dialog.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StoresContentMobile extends material.StatefulWidget {
  const StoresContentMobile({super.key});

  @override
  material.State<StoresContentMobile> createState() =>
      _StoresContentMobileState();
}

class _StoresContentMobileState extends material.State<StoresContentMobile> {
  String _query = '';
  String? _businessId;
  bool _loading = false;
  List<Map<String, dynamic>> _stores = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _loading = true);
    try {
      final businessData = await LocalStorageService.getBusinessData();
      final idValue = businessData?['id'];
      _businessId = idValue is String ? idValue : (idValue?.toString());
      await _loadStores();
    } catch (e) {
      Logger.error('STORES_MOBILE_INIT_ERROR: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
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
      await Supabase.instance.client.from('stores').delete().eq('id', id);
      await _loadStores();
      if (!mounted) return;
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: material.Text('Toko "$name" berhasil dihapus'),
          backgroundColor: material.Colors.green,
        ),
      );
    } catch (e) {
      Logger.error('DELETE_STORE_MOBILE_ERROR: $e');
      if (!mounted) return;
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: material.Text('Gagal menghapus toko'),
          backgroundColor: material.Colors.red,
        ),
      );
    }
  }

  void _showStoreDetail(Map<String, dynamic> store) {
    material.showModalBottomSheet(
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
                  backgroundColor: material.Colors.blue[50],
                  child: material.Icon(
                    material.Icons.store,
                    color: material.Colors.blue,
                  ),
                ),
                const material.SizedBox(width: 12),
                material.Expanded(
                  child: material.Column(
                    crossAxisAlignment: material.CrossAxisAlignment.start,
                    children: [
                      material.Text(
                        (store['name'] ?? '-').toString(),
                        style: const material.TextStyle(
                          fontSize: 18,
                          fontWeight: material.FontWeight.bold,
                        ),
                      ),
                      material.Text(
                        (store['business_field'] ?? '-').toString(),
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
            _buildDetailRow('Alamat', (store['address'] ?? '-').toString()),
            _buildDetailRow(
              'Telepon',
              '${store['phone_country_code'] ?? ''} ${store['phone_number'] ?? ''}',
            ),
            _buildDetailRow(
                'Tipe', store['is_branch'] == true ? 'Cabang' : 'Pusat'),
            _buildDetailRow('Mata Uang', (store['currency'] ?? '-').toString()),
            const material.SizedBox(height: 16),
            material.Row(
              children: [
                material.Expanded(
                  child: OurbitButton.secondary(
                    onPressed: () {
                      material.Navigator.of(context).pop();
                      // TODO: Open edit form
                    },
                    label: 'Edit',
                  ),
                ),
                const material.SizedBox(width: 8),
                material.Expanded(
                  child: OurbitButton.destructive(
                    onPressed: () {
                      material.Navigator.of(context).pop();
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
    );
  }

  material.Widget _buildDetailRow(String label, String value) {
    return material.Padding(
      padding: const material.EdgeInsets.symmetric(vertical: 4),
      child: material.Row(
        crossAxisAlignment: material.CrossAxisAlignment.start,
        children: [
          material.SizedBox(
            width: 80,
            child: material.Text(
              label,
              style: const material.TextStyle(
                fontWeight: material.FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          material.Expanded(
            child: material.Text(
              value,
              style: const material.TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  material.Widget build(material.BuildContext context) {
    if (_loading) {
      return const material.Center(
        child: material.CircularProgressIndicator(),
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

    return material.Column(
      children: [
        // Search
        material.Padding(
          padding: const material.EdgeInsets.all(16),
          child: OurbitTextInput(
            placeholder: 'Cari toko berdasarkan nama/alamat/bidang usaha',
            leading: const material.Icon(material.Icons.search, size: 16),
            onChanged: (v) {
              setState(() {
                _query = (v ?? '').trim().toLowerCase();
              });
            },
          ),
        ),

        // List
        material.Expanded(
          child: filtered.isEmpty
              ? const material.Center(
                  child: material.Text('Tidak ada toko'),
                )
              : material.ListView.separated(
                  padding: const material.EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const material.SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final s = filtered[index];
                    return material.Card(
                      child: material.ListTile(
                        leading: material.CircleAvatar(
                          backgroundColor: material.Colors.blue[50],
                          child: material.Icon(
                            material.Icons.store,
                            color: material.Colors.blue,
                          ),
                        ),
                        title: material.Text(
                          (s['name'] ?? '-').toString(),
                          style: const material.TextStyle(
                            fontWeight: material.FontWeight.w600,
                          ),
                        ),
                        subtitle: material.Column(
                          crossAxisAlignment: material.CrossAxisAlignment.start,
                          children: [
                            material.Text(
                              (s['business_field'] ?? '—').toString(),
                              maxLines: 1,
                              overflow: material.TextOverflow.ellipsis,
                            ),
                            const material.SizedBox(height: 4),
                            material.Text(
                              (s['address'] ?? '—').toString(),
                              maxLines: 1,
                              overflow: material.TextOverflow.ellipsis,
                              style: material.TextStyle(
                                fontSize: 12,
                                color: material.Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: material.Column(
                          mainAxisAlignment: material.MainAxisAlignment.center,
                          crossAxisAlignment: material.CrossAxisAlignment.end,
                          children: [
                            material.Container(
                              padding: const material.EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: material.BoxDecoration(
                                color: s['is_branch'] == true
                                    ? material.Colors.orange[50]
                                    : material.Colors.green[50],
                                borderRadius:
                                    material.BorderRadius.circular(12),
                              ),
                              child: material.Text(
                                s['is_branch'] == true ? 'Cabang' : 'Pusat',
                                style: material.TextStyle(
                                  fontSize: 12,
                                  color: s['is_branch'] == true
                                      ? material.Colors.orange[700]
                                      : material.Colors.green[700],
                                  fontWeight: material.FontWeight.w500,
                                ),
                              ),
                            ),
                            const material.SizedBox(height: 4),
                            material.Text(
                              (s['currency'] ?? '—').toString(),
                              style: material.TextStyle(
                                fontSize: 12,
                                color: material.Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _showStoreDetail(s),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
