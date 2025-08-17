import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/widgets/navigation/sidebar.dart';
import 'package:ourbit_pos/src/widgets/navigation/appbar.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_area.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_select.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_toast.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HelpPage extends material.StatefulWidget {
  const HelpPage({super.key});

  @override
  material.State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends material.State<HelpPage> {
  final _subjectController = material.TextEditingController();
  final _descController = material.TextEditingController();
  String? _category;
  String? _status; // only 'open' | 'requested' at create time
  String? _app;
  bool _submitting = false;

  bool _loading = true;
  List<String> _appKeys = const [];
  Map<String, String> _appLabels = const {};
  List<String> _categoryKeys = const [];
  Map<String, String> _categoryLabels = const {};
  List<String> _statusKeysAll = const [];
  Map<String, String> _statusLabels = const {};
  List<Map<String, dynamic>> _myTickets = const [];
  List<Map<String, dynamic>> _faqCategories = const [];
  Map<String, List<Map<String, dynamic>>> _faqsByCategory = const {};

  @override
  void initState() {
    super.initState();
    _loadOptionsAndTickets();
  }

  Future<void> _loadOptionsAndTickets() async {
    setState(() => _loading = true);
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
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
      // My tickets
      if (user != null) {
        _myTickets = await client
            .schema('common')
            .from('support_tickets')
            .select('id, app, status, subject, category, created_at')
            .eq('requester_user_id', user.id)
            .order('created_at', ascending: false)
            .limit(50);
      } else {
        _myTickets = const [];
      }

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
    } catch (_) {
      _myTickets = const [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submitTicket() async {
    setState(() => _submitting = true);
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) {
        OurbitToast.error(
          context: context,
          title: 'Gagal',
          content: 'Tidak ada pengguna yang login',
        );
        return;
      }

      await client.schema('common').from('support_tickets').insert({
        'requester_user_id': user.id,
        'app': _app,
        'status': _status,
        'subject': _subjectController.text.trim(),
        'category': _category,
        'description': _descController.text.trim(),
      });

      _subjectController.clear();
      _descController.clear();
      await _loadOptionsAndTickets();
      OurbitToast.success(
        context: context,
        title: 'Berhasil',
        content: 'Tiket berhasil dibuat',
      );
    } catch (_) {
      OurbitToast.error(
        context: context,
        title: 'Gagal',
        content: 'Tidak dapat membuat tiket',
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
      return const Center(child: material.CircularProgressIndicator());
    }
    return Scaffold(
      child: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Column(
              children: [
                const OurbitAppBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('FAQ'),
                              const SizedBox(height: 12),
                              Expanded(
                                child: _faqCategories.isEmpty
                                    ? const Center(child: Text('Belum ada FAQ'))
                                    : ListView.builder(
                                        itemCount: _faqCategories.length,
                                        itemBuilder: (context, idx) {
                                          final cat = _faqCategories[idx];
                                          final catId = cat['id'] as String;
                                          final items =
                                              _faqsByCategory[catId] ??
                                                  const [];
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(cat['name'] ?? ''),
                                                const SizedBox(height: 8),
                                                ...items.map((f) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              bottom: 8),
                                                      child: OutlinedContainer(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(12),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(f['title'] ??
                                                                ''),
                                                            const SizedBox(
                                                                height: 6),
                                                            Text(f['content'] ??
                                                                    '')
                                                                .muted(),
                                                          ],
                                                        ),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Buat Tiket'),
                              const SizedBox(height: 12),
                              OurbitTextInput(
                                controller: _subjectController,
                                placeholder: 'Subjek keluhan/bug/request',
                              ),
                              const SizedBox(height: 12),
                              OurbitTextArea(
                                controller: _descController,
                                placeholder: 'Deskripsi',
                                height: 140,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Kategori'),
                                        const SizedBox(height: 8),
                                        OurbitSelect<String>(
                                          value: _category,
                                          items: _categoryKeys,
                                          itemBuilder: (context, item) => Text(
                                              _categoryLabels[item] ?? item),
                                          onChanged: (v) => setState(
                                              () => _category = v ?? _category),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Aplikasi'),
                                        const SizedBox(height: 8),
                                        OurbitSelect<String>(
                                          value: _app,
                                          items: _appKeys,
                                          itemBuilder: (context, item) =>
                                              Text(_appLabels[item] ?? item),
                                          onChanged: (v) =>
                                              setState(() => _app = v ?? _app),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Status'),
                                  const SizedBox(height: 8),
                                  OurbitSelect<String>(
                                    value: _status,
                                    items: _statusKeysAll
                                        .where((k) =>
                                            k == 'open' || k == 'requested')
                                        .toList(),
                                    itemBuilder: (context, item) =>
                                        Text(_statusLabels[item] ?? item),
                                    onChanged: (v) =>
                                        setState(() => _status = v ?? _status),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              OurbitButton.primary(
                                onPressed: _submitting ? null : _submitTicket,
                                label:
                                    _submitting ? 'Mengirim...' : 'Kirim Tiket',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tiket Saya'),
                              const SizedBox(height: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0xFFE5E7EB),
                                        width: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: _myTickets.isEmpty
                                      ? const Center(
                                          child: Text('Belum ada tiket'))
                                      : ListView.separated(
                                          itemCount: _myTickets.length,
                                          separatorBuilder: (_, __) =>
                                              const Divider(height: 1),
                                          itemBuilder: (context, index) {
                                            final t = _myTickets[index];
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 10,
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            t['subject'] ?? ''),
                                                        const SizedBox(
                                                            height: 2),
                                                        Text(
                                                          '${_appLabels[t['app']] ?? t['app']} • ${_statusLabels[t['status']] ?? t['status']} • ${t['category']}',
                                                        ).muted(),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    (t['created_at'] ?? '')
                                                        .toString(),
                                                  ).muted(),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
