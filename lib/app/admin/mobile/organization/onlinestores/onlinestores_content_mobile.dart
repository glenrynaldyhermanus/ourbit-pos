import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_switch.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_area.dart';
import 'package:ourbit_pos/src/core/services/local_storage_service.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnlineStoresContentMobile extends material.StatefulWidget {
  const OnlineStoresContentMobile({super.key});

  @override
  material.State<OnlineStoresContentMobile> createState() =>
      _OnlineStoresContentMobileState();
}

class _OnlineStoresContentMobileState
    extends material.State<OnlineStoresContentMobile> {
  bool _loading = false;
  bool _saving = false;

  String? _businessId;
  String? _onlineSettingsId;

  // Online settings
  bool _isOnlineActive = false;
  final material.TextEditingController _subdomainController =
      material.TextEditingController();
  final material.TextEditingController _contactEmailController =
      material.TextEditingController();
  final material.TextEditingController _descriptionController =
      material.TextEditingController();
  final material.TextEditingController _facebookController =
      material.TextEditingController();
  final material.TextEditingController _instagramController =
      material.TextEditingController();
  final material.TextEditingController _twitterController =
      material.TextEditingController();
  int _stockTracking = 1; // 1: real-time, 2: manual, 3: none

  // Delivery locations
  List<Map<String, dynamic>> _stores = [];
  List<Map<String, dynamic>> _warehouses = [];
  final Set<String> _togglingStores = {};
  final Set<String> _togglingWarehouses = {};

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _subdomainController.dispose();
    _contactEmailController.dispose();
    _descriptionController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    setState(() => _loading = true);
    try {
      final businessData = await LocalStorageService.getBusinessData();
      _businessId = (businessData?['id'])?.toString();
      await _loadOnlineSettings();
      await _loadLocations();
    } catch (e) {
      Logger.error('ONLINE_MOBILE_INIT_ERROR: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadOnlineSettings() async {
    if (_businessId == null || _businessId!.isEmpty) return;
    try {
      final res = await Supabase.instance.client
          .from('business_online_settings')
          .select('*')
          .eq('business_id', _businessId as Object)
          .maybeSingle();

      if (res != null) {
        _onlineSettingsId = res['id']?.toString();
        _isOnlineActive = true;
        _subdomainController.text = (res['subdomain'] ?? '').toString();
        _contactEmailController.text = (res['contact_email'] ?? '').toString();
        _descriptionController.text = (res['description'] ?? '').toString();
        _facebookController.text = (res['facebook_url'] ?? '').toString();
        _instagramController.text = (res['instagram_url'] ?? '').toString();
        _twitterController.text = (res['twitter_url'] ?? '').toString();
        _stockTracking = (res['stock_tracking'] ?? 1) as int;
      } else {
        _onlineSettingsId = null;
        _isOnlineActive = false;
        _subdomainController.clear();
        _contactEmailController.clear();
        _descriptionController.clear();
        _facebookController.clear();
        _instagramController.clear();
        _twitterController.clear();
        _stockTracking = 1;
      }
    } catch (e) {
      Logger.error('LOAD_ONLINE_SETTINGS_MOBILE_ERROR: $e');
    }
  }

  Future<void> _loadLocations() async {
    if (_businessId == null || _businessId!.isEmpty) return;
    try {
      // Load stores
      final storesRes = await Supabase.instance.client
          .from('stores')
          .select('id, name, address, is_online_delivery_enabled')
          .eq('business_id', _businessId as Object);
      _stores = (storesRes as List)
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();

      // Load warehouses
      final warehousesRes = await Supabase.instance.client
          .from('warehouses')
          .select('id, name, address, is_online_delivery_enabled')
          .eq('business_id', _businessId as Object);
      _warehouses = (warehousesRes as List)
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();
    } catch (e) {
      Logger.error('LOAD_LOCATIONS_MOBILE_ERROR: $e');
    }
  }

  Future<void> _saveSettings() async {
    if (_businessId == null || _businessId!.isEmpty) return;
    setState(() => _saving = true);
    try {
      final data = {
        'business_id': _businessId!,
        'subdomain': _subdomainController.text.trim(),
        'contact_email': _contactEmailController.text.trim(),
        'description': _descriptionController.text.trim(),
        'facebook_url': _facebookController.text.trim(),
        'instagram_url': _instagramController.text.trim(),
        'twitter_url': _twitterController.text.trim(),
        'stock_tracking': _stockTracking,
      };

      if (_onlineSettingsId != null) {
        await Supabase.instance.client
            .from('business_online_settings')
            .update(data)
            .eq('id', _onlineSettingsId!);
      } else {
        final res = await Supabase.instance.client
            .from('business_online_settings')
            .insert(data)
            .select()
            .single();
        _onlineSettingsId = res['id']?.toString();
      }

      if (!mounted) return;
      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(
          content: material.Text('Pengaturan berhasil disimpan'),
          backgroundColor: material.Colors.green,
        ),
      );
    } catch (e) {
      Logger.error('SAVE_ONLINE_SETTINGS_MOBILE_ERROR: $e');
      if (!mounted) return;
      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(
          content: material.Text('Gagal menyimpan pengaturan'),
          backgroundColor: material.Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleStoreDelivery(String storeId, bool enabled) async {
    if (_togglingStores.contains(storeId)) return;
    _togglingStores.add(storeId);
    setState(() {});
    try {
      await Supabase.instance.client
          .from('stores')
          .update({'is_online_delivery_enabled': enabled}).eq('id', storeId);
      await _loadLocations();
    } catch (e) {
      Logger.error('TOGGLE_STORE_DELIVERY_MOBILE_ERROR: $e');
    } finally {
      _togglingStores.remove(storeId);
      if (mounted) setState(() {});
    }
  }

  Future<void> _toggleWarehouseDelivery(
      String warehouseId, bool enabled) async {
    if (_togglingWarehouses.contains(warehouseId)) return;
    _togglingWarehouses.add(warehouseId);
    setState(() {});
    try {
      await Supabase.instance.client.from('warehouses').update(
          {'is_online_delivery_enabled': enabled}).eq('id', warehouseId);
      await _loadLocations();
    } catch (e) {
      Logger.error('TOGGLE_WAREHOUSE_DELIVERY_MOBILE_ERROR: $e');
    } finally {
      _togglingWarehouses.remove(warehouseId);
      if (mounted) setState(() {});
    }
  }

  @override
  material.Widget build(material.BuildContext context) {
    if (_loading) {
      return const material.Center(
        child: material.CircularProgressIndicator(),
      );
    }

    return material.SingleChildScrollView(
      padding: const material.EdgeInsets.all(16),
      child: material.Column(
        crossAxisAlignment: material.CrossAxisAlignment.start,
        children: [
          // Header
          material.Text(
            'Toko Online',
            style: material.Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: material.FontWeight.bold,
                ),
          ),
          const material.SizedBox(height: 8),
          material.Text(
            'Kelola pengaturan toko online dan pengiriman',
            style: material.Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: material.Colors.grey[600],
                ),
          ),
          const material.SizedBox(height: 24),

          // Online Store Settings
          material.Card(
            child: material.Padding(
              padding: const material.EdgeInsets.all(16),
              child: material.Column(
                crossAxisAlignment: material.CrossAxisAlignment.start,
                children: [
                  material.Text(
                    'Pengaturan Toko Online',
                    style: material.Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: material.FontWeight.w600),
                  ),
                  const material.SizedBox(height: 16),
                  OurbitSwitchBuilder.withLabel(
                    label: 'Aktifkan Toko Online',
                    value: _isOnlineActive,
                    onChanged: (value) {
                      setState(() => _isOnlineActive = value);
                    },
                  ),
                  const material.SizedBox(height: 16),
                  OurbitTextInput(
                    controller: _subdomainController,
                    placeholder: 'Subdomain (contoh: toko-saya)',
                    label: 'Subdomain',
                  ),
                  const material.SizedBox(height: 12),
                  OurbitTextInput(
                    controller: _contactEmailController,
                    placeholder: 'Email kontak',
                  ),
                  const material.SizedBox(height: 12),
                  OurbitTextArea(
                    controller: _descriptionController,
                    placeholder: 'Deskripsi toko',
                  ),
                  const material.SizedBox(height: 16),
                  material.Text(
                    'Media Sosial',
                    style: material.Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: material.FontWeight.w600),
                  ),
                  const material.SizedBox(height: 12),
                  OurbitTextInput(
                    controller: _facebookController,
                    placeholder: 'URL Facebook',
                    label: 'Facebook',
                  ),
                  const material.SizedBox(height: 12),
                  OurbitTextInput(
                    controller: _instagramController,
                    placeholder: 'URL Instagram',
                    label: 'Instagram',
                  ),
                  const material.SizedBox(height: 12),
                  OurbitTextInput(
                    controller: _twitterController,
                    placeholder: 'URL Twitter',
                    label: 'Twitter',
                  ),
                  const material.SizedBox(height: 16),
                  material.Text(
                    'Pelacakan Stok',
                    style: material.Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: material.FontWeight.w600),
                  ),
                  const material.SizedBox(height: 8),
                  material.DropdownButtonFormField<int>(
                    value: _stockTracking,
                    decoration: const material.InputDecoration(
                      border: material.OutlineInputBorder(),
                      contentPadding: material.EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      material.DropdownMenuItem(
                          value: 1, child: material.Text('Real-time')),
                      material.DropdownMenuItem(
                          value: 2, child: material.Text('Manual')),
                      material.DropdownMenuItem(
                          value: 3, child: material.Text('Tidak ada')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _stockTracking = value);
                      }
                    },
                  ),
                  const material.SizedBox(height: 16),
                  material.SizedBox(
                    width: double.infinity,
                    child: OurbitButton.primary(
                      onPressed: _saving ? null : _saveSettings,
                      label: _saving ? 'Menyimpan...' : 'Simpan Pengaturan',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const material.SizedBox(height: 24),

          // Delivery Locations
          material.Card(
            child: material.Padding(
              padding: const material.EdgeInsets.all(16),
              child: material.Column(
                crossAxisAlignment: material.CrossAxisAlignment.start,
                children: [
                  material.Text(
                    'Lokasi Pengiriman',
                    style: material.Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: material.FontWeight.w600),
                  ),
                  const material.SizedBox(height: 16),

                  // Stores
                  if (_stores.isNotEmpty) ...[
                    material.Text(
                      'Toko',
                      style: material.Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: material.FontWeight.w600),
                    ),
                    const material.SizedBox(height: 8),
                    ...(_stores.map((store) => material.ListTile(
                          title: material.Text(store['name'] ?? '-'),
                          subtitle: material.Text(
                            store['address'] ?? '-',
                            maxLines: 1,
                            overflow: material.TextOverflow.ellipsis,
                          ),
                          trailing: material.Switch(
                            value: store['is_online_delivery_enabled'] == true,
                            onChanged: _togglingStores.contains(store['id'])
                                ? null
                                : (value) => _toggleStoreDelivery(
                                    store['id'].toString(), value),
                          ),
                        ))),
                    const material.SizedBox(height: 16),
                  ],

                  // Warehouses
                  if (_warehouses.isNotEmpty) ...[
                    material.Text(
                      'Gudang',
                      style: material.Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: material.FontWeight.w600),
                    ),
                    const material.SizedBox(height: 8),
                    ...(_warehouses.map((warehouse) => material.ListTile(
                          title: material.Text(warehouse['name'] ?? '-'),
                          subtitle: material.Text(
                            warehouse['address'] ?? '-',
                            maxLines: 1,
                            overflow: material.TextOverflow.ellipsis,
                          ),
                          trailing: material.Switch(
                            value:
                                warehouse['is_online_delivery_enabled'] == true,
                            onChanged:
                                _togglingWarehouses.contains(warehouse['id'])
                                    ? null
                                    : (value) => _toggleWarehouseDelivery(
                                        warehouse['id'].toString(), value),
                          ),
                        ))),
                  ],

                  if (_stores.isEmpty && _warehouses.isEmpty)
                    material.Center(
                      child: material.Padding(
                        padding: const material.EdgeInsets.all(32),
                        child: material.Text(
                          'Belum ada lokasi pengiriman',
                          style: material.TextStyle(
                            color: material.Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
