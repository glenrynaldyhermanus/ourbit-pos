import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/widgets/navigation/sidebar_drawer.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_area.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_circular_progress.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HelpPageMobile extends StatefulWidget {
  const HelpPageMobile({super.key});

  @override
  State<HelpPageMobile> createState() => _HelpPageMobileState();
}

class _HelpPageMobileState extends material.State<HelpPageMobile> {
  final _subjectController = material.TextEditingController();
  final _descController = material.TextEditingController();
  String? _category;
  String? _status;
  String? _app;
  bool _submitting = false;
  bool _loading = true;
  List<String> _appKeys = const [];
  Map<String, String> _appLabels = const {};
  List<String> _categoryKeys = const [];
  Map<String, String> _categoryLabels = const {};
  List<String> _statusKeysAll = const [];
  Map<String, String> _statusLabels = const {};
  List<Map<String, dynamic>> _faqCategories = const [];
  Map<String, List<Map<String, dynamic>>> _faqsByCategory = const {};

  @override
  void initState() {
    super.initState();
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;
      // Apps
      final appRows = await client
          .schema('common')
          .from('options')
          .select('key,name')
          .eq('type', 'support_app')
          .order('name');
      final appKeys = <String>[];
      final appLabels = <String, String>{};
      for (final row in appRows) {
        final key = (row['key'] ?? '').toString();
        final name = (row['name'] ?? key).toString();
        if (key.isNotEmpty) {
          appKeys.add(key);
          appLabels[key] = name;
        }
      }
      // Categories
      final catRows = await client
          .schema('common')
          .from('options')
          .select('key,name')
          .eq('type', 'support_ticket_category')
          .order('name');
      final categoryKeys = <String>[];
      final categoryLabels = <String, String>{};
      for (final row in catRows) {
        final key = (row['key'] ?? '').toString();
        final name = (row['name'] ?? key).toString();
        if (key.isNotEmpty) {
          categoryKeys.add(key);
          categoryLabels[key] = name;
        }
      }
      // Statuses
      final statusRows = await client
          .schema('common')
          .from('options')
          .select('key,name')
          .eq('type', 'support_ticket_status')
          .order('name');
      final statusKeysAll = <String>[];
      final statusLabels = <String, String>{};
      for (final row in statusRows) {
        final key = (row['key'] ?? '').toString();
        final name = (row['name'] ?? key).toString();
        if (key.isNotEmpty) {
          statusKeysAll.add(key);
          statusLabels[key] = name;
        }
      }
      _appKeys = appKeys;
      _appLabels = appLabels;
      _categoryKeys = categoryKeys;
      _categoryLabels = categoryLabels;
      _statusKeysAll = statusKeysAll;
      _statusLabels = statusLabels;
      _app ??= appKeys.isNotEmpty ? appKeys.first : null;
      _category ??= categoryKeys.isNotEmpty ? categoryKeys.first : null;
      _status ??= statusKeysAll.contains('open')
          ? 'open'
          : (statusKeysAll.isNotEmpty ? statusKeysAll.first : null);

      // FAQs
      final cats = await client
          .schema('common')
          .from('support_faq_categories')
          .select('id,name,display_order')
          .order('display_order');
      _faqCategories = List<Map<String, dynamic>>.from(cats);
      final faqsByCat = <String, List<Map<String, dynamic>>>{};
      for (final c in _faqCategories) {
        final fid = c['id'] as String;
        final items = await client
            .schema('common')
            .from('support_faqs')
            .select('id,title,content,display_order')
            .eq('category_id', fid)
            .eq('is_active', true)
            .order('display_order');
        faqsByCat[fid] = List<Map<String, dynamic>>.from(items);
      }
      _faqsByCategory = faqsByCat;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitTicket() async {
    setState(() => _submitting = true);
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) return;
      await client.schema('common').from('support_tickets').insert({
        'requester_user_id': user.id,
        'app': _app,
        'status': _status,
        'subject': _subjectController.text.trim(),
        'category': _category,
        'description': _descController.text.trim(),
      });
      if (!mounted) return;
      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(
          content: material.Text('Tiket berhasil dibuat'),
          backgroundColor: material.Colors.green,
        ),
      );
      _subjectController.clear();
      _descController.clear();
    } catch (_) {
      if (!mounted) return;
      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(
          content: material.Text('Gagal membuat tiket'),
          backgroundColor: material.Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  material.Widget build(material.BuildContext context) {
    if (_loading) {
      return const material.Center(child: OurbitCircularProgress());
    }
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
            title: const material.Text('Bantuan'),
            leading: material.Builder(
              builder: (context) => material.IconButton(
                icon: const material.Icon(material.Icons.menu),
                onPressed: () => material.Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          drawer: const SidebarDrawer(),
          body: material.SingleChildScrollView(
            padding: const material.EdgeInsets.all(16),
            child: material.Column(
              crossAxisAlignment: material.CrossAxisAlignment.start,
              children: [
                material.Text(
                  'FAQ',
                  style: material.TextStyle(
                    fontSize: 18,
                    fontWeight: material.FontWeight.w600,
                    color: material.Theme.of(context).brightness ==
                            material.Brightness.dark
                        ? AppColors.darkPrimaryText
                        : AppColors.primaryText,
                  ),
                ),
                const material.SizedBox(height: 12),
                if (_faqCategories.isEmpty)
                  material.Text(
                    'Belum ada FAQ',
                    style: material.TextStyle(
                      color: material.Theme.of(context).brightness ==
                              material.Brightness.dark
                          ? AppColors.darkSecondaryText
                          : AppColors.secondaryText,
                    ),
                  )
                else
                  ..._faqCategories.map((cat) {
                    final items =
                        _faqsByCategory[cat['id'] as String] ?? const [];
                    return material.Padding(
                      padding: const material.EdgeInsets.only(bottom: 16),
                      child: material.Column(
                        crossAxisAlignment: material.CrossAxisAlignment.start,
                        children: [
                          material.Text(
                            cat['name'] ?? '',
                            style: material.TextStyle(
                              fontWeight: material.FontWeight.w600,
                              color: material.Theme.of(context).brightness ==
                                      material.Brightness.dark
                                  ? AppColors.darkPrimaryText
                                  : AppColors.primaryText,
                            ),
                          ),
                          const material.SizedBox(height: 8),
                          ...items.map((f) => OurbitCard(
                                child: material.Padding(
                                  padding: const material.EdgeInsets.all(12),
                                  child: material.Column(
                                    crossAxisAlignment:
                                        material.CrossAxisAlignment.start,
                                    children: [
                                      material.Text(
                                        f['title'] ?? '',
                                        style: material.TextStyle(
                                          fontWeight: material.FontWeight.w600,
                                          color: material.Theme.of(context)
                                                      .brightness ==
                                                  material.Brightness.dark
                                              ? AppColors.darkPrimaryText
                                              : AppColors.primaryText,
                                        ),
                                      ),
                                      const material.SizedBox(height: 6),
                                      material.Text(
                                        f['content'] ?? '',
                                        style: material.TextStyle(
                                          color: material.Theme.of(context)
                                                      .brightness ==
                                                  material.Brightness.dark
                                              ? AppColors.darkSecondaryText
                                              : AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ],
                      ),
                    );
                  }),
                const material.Divider(height: 32),
                material.Text(
                  'Buat Tiket',
                  style: material.TextStyle(
                    fontSize: 18,
                    fontWeight: material.FontWeight.w600,
                    color: material.Theme.of(context).brightness ==
                            material.Brightness.dark
                        ? AppColors.darkPrimaryText
                        : AppColors.primaryText,
                  ),
                ),
                const material.SizedBox(height: 12),
                OurbitTextInput(
                    controller: _subjectController,
                    placeholder: 'Subjek keluhan/bug/request'),
                const material.SizedBox(height: 12),
                OurbitTextArea(
                    controller: _descController,
                    placeholder: 'Deskripsi',
                    height: 140),
                const material.SizedBox(height: 12),
                material.Text(
                  'Kategori',
                  style: material.TextStyle(
                    fontWeight: material.FontWeight.w600,
                    color: material.Theme.of(context).brightness ==
                            material.Brightness.dark
                        ? AppColors.darkPrimaryText
                        : AppColors.primaryText,
                  ),
                ),
                const material.SizedBox(height: 8),
                OurbitSelect<String>(
                  value: _category,
                  items: _categoryKeys,
                  itemBuilder: (context, item) =>
                      material.Text(_categoryLabels[item] ?? item),
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                const material.SizedBox(height: 12),
                material.Text(
                  'Aplikasi',
                  style: material.TextStyle(
                    fontWeight: material.FontWeight.w600,
                    color: material.Theme.of(context).brightness ==
                            material.Brightness.dark
                        ? AppColors.darkPrimaryText
                        : AppColors.primaryText,
                  ),
                ),
                const material.SizedBox(height: 8),
                OurbitSelect<String>(
                  value: _app,
                  items: _appKeys,
                  itemBuilder: (context, item) =>
                      material.Text(_appLabels[item] ?? item),
                  onChanged: (v) => setState(() => _app = v ?? _app),
                ),
                const material.SizedBox(height: 12),
                material.Text(
                  'Status',
                  style: material.TextStyle(
                    fontWeight: material.FontWeight.w600,
                    color: material.Theme.of(context).brightness ==
                            material.Brightness.dark
                        ? AppColors.darkPrimaryText
                        : AppColors.primaryText,
                  ),
                ),
                const material.SizedBox(height: 8),
                OurbitSelect<String>(
                  value: _status,
                  items: _statusKeysAll
                      .where((k) => k == 'open' || k == 'requested')
                      .toList(),
                  itemBuilder: (context, item) =>
                      material.Text(_statusLabels[item] ?? item),
                  onChanged: (v) => setState(() => _status = v ?? _status),
                ),
                const material.SizedBox(height: 16),
                material.SizedBox(
                  width: double.infinity,
                  child: OurbitButton.primary(
                    onPressed: _submitting ? null : _submitTicket,
                    label: _submitting ? 'Mengirim...' : 'Kirim Tiket',
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
