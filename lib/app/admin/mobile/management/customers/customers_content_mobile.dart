import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_toast.dart';

class CustomersContentMobile extends material.StatefulWidget {
  const CustomersContentMobile({super.key});

  @override
  material.State<CustomersContentMobile> createState() =>
      _CustomersContentMobileState();
}

class _CustomersContentMobileState extends material
    .State<CustomersContentMobile> with material.TickerProviderStateMixin {
  String _query = '';
  late final material.AnimationController _listController;

  @override
  void initState() {
    super.initState();
    material.WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadCustomers());
      _listController.forward();
    });
    _listController = material.AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  material.Widget build(material.BuildContext context) {
    return BlocConsumer<ManagementBloc, ManagementState>(
      listener: (context, state) {
        if (state is ManagementError) {
          OurbitToast.error(
            context: context,
            title: 'Gagal',
            content: state.message,
          );
        }
      },
      builder: (context, state) {
        if (state is ManagementLoading || state is ManagementInitial) {
          return const material.Center(
              child: material.CircularProgressIndicator());
        }

        final data = state is CustomersLoaded
            ? state.customers
            : <Map<String, dynamic>>[];
        final filtered = _query.isEmpty
            ? data
            : data.where((c) {
                final name = (c['name'] ?? '').toString().toLowerCase();
                final email = (c['email'] ?? '').toString().toLowerCase();
                final phone = (c['phone'] ?? '').toString().toLowerCase();
                final q = _query.toLowerCase();
                return name.contains(q) ||
                    email.contains(q) ||
                    phone.contains(q);
              }).toList();

        return material.Column(
          children: [
            material.Padding(
              padding: const material.EdgeInsets.all(16),
              child: material.TextField(
                decoration: const material.InputDecoration(
                  hintText: 'Cari pelanggan (nama/email/telepon)...',
                  prefixIcon: material.Icon(material.Icons.search),
                  border: material.OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            material.Expanded(
              child: material.AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: filtered.isEmpty
                    ? const material.Center(
                        key: material.ValueKey('empty'),
                        child: material.Text('Tidak ada pelanggan'))
                    : material.FadeTransition(
                        key: const material.ValueKey('list'),
                        opacity: _listController,
                        child: material.ListView.separated(
                          padding: const material.EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const material.SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final c = filtered[index];
                            final isActive = (c['is_active'] ?? true) as bool;
                            return material.TweenAnimationBuilder<double>(
                              duration:
                                  Duration(milliseconds: 150 + index * 50),
                              tween: material.Tween(begin: 0.0, end: 1.0),
                              builder: (context, t, child) {
                                return material.Opacity(
                                  opacity: t,
                                  child: material.Transform.translate(
                                    offset: material.Offset(0, 16 * (1 - t)),
                                    child: child,
                                  ),
                                );
                              },
                              child: OurbitCard(
                                child: material.ListTile(
                                  leading: material.CircleAvatar(
                                    backgroundColor: material.Colors.grey[200],
                                    child: const material.Icon(
                                        material.Icons.person,
                                        color: material.Colors.grey),
                                  ),
                                  title: material.Text(
                                    (c['name'] ?? '-').toString(),
                                    style: const material.TextStyle(
                                        fontWeight: material.FontWeight.w600),
                                  ),
                                  subtitle: material.Text(
                                    [
                                      (c['email'] ?? '—').toString(),
                                      (c['phone'] ?? '—').toString(),
                                    ]
                                        .where((s) =>
                                            s.trim().isNotEmpty && s != '—')
                                        .join(' · '),
                                    maxLines: 2,
                                    overflow: material.TextOverflow.ellipsis,
                                  ),
                                  trailing: material.Container(
                                    padding:
                                        const material.EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                    decoration: material.BoxDecoration(
                                      color: isActive
                                          ? material.Colors.green
                                              .withValues(alpha: 0.1)
                                          : material.Colors.red
                                              .withValues(alpha: 0.1),
                                      borderRadius:
                                          material.BorderRadius.circular(999),
                                    ),
                                    child: material.Text(
                                      isActive ? 'Aktif' : 'Nonaktif',
                                      style: material.TextStyle(
                                        fontSize: 12,
                                        fontWeight: material.FontWeight.w600,
                                        color: isActive
                                            ? material.Colors.green[700]
                                            : material.Colors.red[700],
                                      ),
                                    ),
                                  ),
                                  onTap: () {},
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
