import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:ourbit_pos/src/core/services/local_storage_service.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/src/core/utils/logger.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_area.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_switch.dart';

class OnlineStoresContent extends StatefulWidget {
  const OnlineStoresContent({super.key});

  @override
  State<OnlineStoresContent> createState() => _OnlineStoresContentState();
}

class _OnlineStoresContentState extends State<OnlineStoresContent> {
  bool _loading = false;
  bool _saving = false;

  String? _businessId;
  String? _onlineSettingsId;

  // Online settings
  bool _isOnlineActive = false;
  final TextEditingController _subdomainController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  int _stockTracking = 1; // 1: real-time, 2: manual, 3: none

  // Delivery locations
  List<Map<String, dynamic>> _stores = [];
  List<Map<String, dynamic>> _warehouses = [];
  final Set<String> _togglingStores = {};
  final Set<String> _togglingWarehouses = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
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
      Logger.error('ONLINE_INIT_ERROR: $e');
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
      if (mounted) setState(() {});
    } catch (e) {
      Logger.error('ONLINE_SETTINGS_LOAD_ERROR: $e');
    }
  }

  Future<void> _loadLocations() async {
    if (_businessId == null || _businessId!.isEmpty) return;
    try {
      final storesRes = await Supabase.instance.client
          .from('stores')
          .select('id, name, is_online_delivery_active')
          .eq('business_id', _businessId as Object);
      final warehousesRes = await Supabase.instance.client
          .from('warehouses')
          .select('id, name, is_online_delivery_active')
          .eq('business_id', _businessId as Object);

      setState(() {
        _stores = (storesRes as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        _warehouses = (warehousesRes as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      });
    } catch (e) {
      Logger.error('ONLINE_LOCATIONS_LOAD_ERROR: $e');
      setState(() {
        _stores = [];
        _warehouses = [];
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_businessId == null || _businessId!.isEmpty) return;
    setState(() => _saving = true);
    try {
      final supabase = Supabase.instance.client;
      if (_isOnlineActive) {
        final settingsData = {
          'business_id': _businessId,
          'subdomain': _subdomainController.text.trim().toLowerCase(),
          'contact_email': _contactEmailController.text.trim(),
          'description': _descriptionController.text.trim(),
          'facebook_url': _facebookController.text.trim(),
          'instagram_url': _instagramController.text.trim(),
          'twitter_url': _twitterController.text.trim(),
          'stock_tracking': _stockTracking,
        };

        if (_onlineSettingsId != null) {
          await supabase
              .from('business_online_settings')
              .update(settingsData)
              .eq('id', _onlineSettingsId as Object);
        } else {
          await supabase.from('business_online_settings').insert(settingsData);
        }
      } else {
        // Deactivate = delete settings if exists
        if (_onlineSettingsId != null) {
          await supabase
              .from('business_online_settings')
              .delete()
              .eq('id', _onlineSettingsId as Object);
        }
      }

      await _loadOnlineSettings();
      if (!mounted) return;
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: const Basic(
            title: Text('Berhasil'),
            content: Text('Pengaturan toko online berhasil disimpan'),
          ),
        ),
        location: ToastLocation.topCenter,
      );
    } catch (e) {
      Logger.error('ONLINE_SETTINGS_SAVE_ERROR: $e');
      if (!mounted) return;
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Basic(
            title: const Text('Error'),
            content: Text('Gagal menyimpan pengaturan: $e'),
            trailing: OurbitButton.primary(
              onPressed: () => overlay.close(),
              label: 'Tutup',
            ),
          ),
        ),
        location: ToastLocation.topCenter,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleStoreDelivery(String id, bool isActive) async {
    if (_togglingStores.contains(id)) return;
    setState(() => _togglingStores.add(id));
    try {
      await Supabase.instance.client
          .from('stores')
          .update({'is_online_delivery_active': isActive}).eq('id', id);
      setState(() {
        _stores = _stores
            .map((s) => s['id'] == id
                ? {...s, 'is_online_delivery_active': isActive}
                : s)
            .toList();
      });
      if (!mounted) return;
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Basic(
            title: const Text('Berhasil'),
            content: Text(
                'Pengiriman toko ${isActive ? 'diaktifkan' : 'dinonaktifkan'}'),
          ),
        ),
        location: ToastLocation.topCenter,
      );
    } catch (e) {
      Logger.error('TOGGLE_STORE_DELIVERY_ERROR: $e');
    } finally {
      setState(() => _togglingStores.remove(id));
    }
  }

  Future<void> _toggleWarehouseDelivery(String id, bool isActive) async {
    if (_togglingWarehouses.contains(id)) return;
    setState(() => _togglingWarehouses.add(id));
    try {
      await Supabase.instance.client
          .from('warehouses')
          .update({'is_online_delivery_active': isActive}).eq('id', id);
      setState(() {
        _warehouses = _warehouses
            .map((w) => w['id'] == id
                ? {...w, 'is_online_delivery_active': isActive}
                : w)
            .toList();
      });
      if (!mounted) return;
      showToast(
        context: context,
        builder: (context, overlay) => SurfaceCard(
          child: Basic(
            title: const Text('Berhasil'),
            content: Text(
                'Pengiriman gudang ${isActive ? 'diaktifkan' : 'dinonaktifkan'}'),
          ),
        ),
        location: ToastLocation.topCenter,
      );
    } catch (e) {
      Logger.error('TOGGLE_WAREHOUSE_DELIVERY_ERROR: $e');
    } finally {
      setState(() => _togglingWarehouses.remove(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        final Color borderColor = themeService.isDarkMode
            ? const Color(0xff292524)
            : const Color(0xFFE5E7EB);
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Toko Online',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Kelola pengaturan toko online Anda'),
                const SizedBox(height: 16),

                // Online settings card
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 0.5),
                    borderRadius: Theme.of(context).borderRadiusLg,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Pengaturan Toko Online',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          OurbitSwitchBuilder.withLabel(
                            value: _isOnlineActive,
                            onChanged: (v) =>
                                setState(() => _isOnlineActive = v),
                            label: 'Aktifkan',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_isOnlineActive) ...[
                        // Subdomain
                        const Text('Subdomain'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).colorScheme.border,
                                    width: 1),
                                borderRadius: Theme.of(context).borderRadiusSm,
                              ),
                              child: const Text('ourbit.web.app/@'),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OurbitTextInput(
                                controller: _subdomainController,
                                placeholder: 'namabisnis',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Contact email
                        const Text('Email Kontak'),
                        const SizedBox(height: 8),
                        OurbitTextInput(
                          controller: _contactEmailController,
                          placeholder: 'contact@example.com',
                        ),
                        const SizedBox(height: 12),

                        // Description
                        const Text('Deskripsi Toko'),
                        const SizedBox(height: 8),
                        OurbitTextArea(
                          controller: _descriptionController,
                          placeholder: 'Deskripsi toko Anda...',
                          initialHeight: 100,
                          expandableHeight: true,
                        ),
                        const SizedBox(height: 12),

                        // Socials
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Facebook URL'),
                                  const SizedBox(height: 8),
                                  OurbitTextInput(
                                    controller: _facebookController,
                                    placeholder: 'https://facebook.com/...',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Instagram URL'),
                                  const SizedBox(height: 8),
                                  OurbitTextInput(
                                    controller: _instagramController,
                                    placeholder: 'https://instagram.com/...',
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Twitter URL'),
                                  const SizedBox(height: 8),
                                  OurbitTextInput(
                                    controller: _twitterController,
                                    placeholder: 'https://twitter.com/...',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Stock Tracking
                        const Text('Tracking Stok'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            OurbitButton.outline(
                              onPressed: () =>
                                  setState(() => _stockTracking = 1),
                              label: 'Real-time',
                              // OurbitButton.outline tidak punya isActive; gunakan style default
                            ),
                            OurbitButton.outline(
                              onPressed: () =>
                                  setState(() => _stockTracking = 2),
                              label: 'Manual',
                              // style default
                            ),
                            OurbitButton.outline(
                              onPressed: () =>
                                  setState(() => _stockTracking = 3),
                              label: 'Tidak Ada',
                              // style default
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        OurbitButton.primary(
                          onPressed: _saving ? null : _saveSettings,
                          isLoading: _saving,
                          label: 'Simpan Pengaturan',
                        ),
                      ] else ...[
                        OurbitButton.primary(
                          onPressed: _saving ? null : _saveSettings,
                          isLoading: _saving,
                          label: 'Simpan',
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Delivery Locations card
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor, width: 0.5),
                    borderRadius: Theme.of(context).borderRadiusLg,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lokasi Pengiriman',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),

                      // Stores
                      const Text('Toko'),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          for (final s in _stores)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: borderColor, width: 0.5),
                                borderRadius: Theme.of(context).borderRadiusMd,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text((s['name'] ?? '-') as String,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                        s['is_online_delivery_active'] == true
                                            ? 'Aktif untuk pengiriman online'
                                            : 'Tidak aktif',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .mutedForeground,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  OurbitSwitchBuilder.withLabel(
                                    value:
                                        s['is_online_delivery_active'] == true,
                                    onChanged: (checked) {
                                      if (_togglingStores.contains(
                                          (s['id'] ?? '').toString())) {
                                        return;
                                      }
                                      _toggleStoreDelivery(
                                          (s['id'] ?? '').toString(), checked);
                                    },
                                    label: '',
                                  ),
                                ],
                              ),
                            ),
                          if (_stores.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: Text('Belum ada toko')),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Warehouses
                      const Text('Gudang'),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          for (final w in _warehouses)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: borderColor, width: 0.5),
                                borderRadius: Theme.of(context).borderRadiusMd,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text((w['name'] ?? '-') as String,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                        w['is_online_delivery_active'] == true
                                            ? 'Aktif untuk pengiriman online'
                                            : 'Tidak aktif',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .mutedForeground,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  OurbitSwitchBuilder.withLabel(
                                    value:
                                        w['is_online_delivery_active'] == true,
                                    onChanged: (checked) {
                                      if (_togglingWarehouses.contains(
                                          (w['id'] ?? '').toString())) {
                                        return;
                                      }
                                      _toggleWarehouseDelivery(
                                          (w['id'] ?? '').toString(), checked);
                                    },
                                    label: '',
                                  ),
                                ],
                              ),
                            ),
                          if (_warehouses.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: Text('Belum ada gudang')),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
