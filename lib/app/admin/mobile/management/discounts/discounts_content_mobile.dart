import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';

class DiscountsContentMobile extends material.StatefulWidget {
  const DiscountsContentMobile({super.key});

  @override
  material.State<DiscountsContentMobile> createState() =>
      _DiscountsContentMobileState();
}

class _DiscountsContentMobileState extends material
    .State<DiscountsContentMobile> with material.TickerProviderStateMixin {
  String _query = '';
  late final material.AnimationController _listController;

  @override
  void initState() {
    super.initState();
    material.WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadDiscounts());
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
    return BlocBuilder<ManagementBloc, ManagementState>(
      builder: (context, state) {
        if (state is ManagementLoading || state is ManagementInitial) {
          return const material.Center(
              child: material.CircularProgressIndicator());
        }

        final data = state is DiscountsLoaded
            ? state.discounts
            : <Map<String, dynamic>>[];
        final filtered = _query.isEmpty
            ? data
            : data.where((d) {
                final name = (d['name'] ?? '').toString().toLowerCase();
                final type = (d['type'] ?? '').toString().toLowerCase();
                final q = _query.toLowerCase();
                return name.contains(q) || type.contains(q);
              }).toList();

        return material.Column(
          children: [
            material.Padding(
              padding: const material.EdgeInsets.all(16),
              child: material.TextField(
                decoration: const material.InputDecoration(
                  hintText: 'Cari diskon...',
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
                        child: material.Text('Tidak ada diskon'))
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
                            final d = filtered[index];
                            final isActive = (d['is_active'] ?? true) as bool;
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
                                    backgroundColor: material.Colors.teal[50],
                                    child: const material.Icon(
                                        material.Icons.local_offer,
                                        color: material.Colors.teal),
                                  ),
                                  title: material.Text(
                                    (d['name'] ?? '-').toString(),
                                    style: const material.TextStyle(
                                        fontWeight: material.FontWeight.w600),
                                  ),
                                  subtitle: material.Text(
                                    'Tipe: ${(d['type'] ?? '-')} · Nilai: ${(d['value'] ?? 0)}',
                                  ),
                                  trailing: material.Text(
                                    isActive ? 'Aktif' : 'Nonaktif',
                                    style: material.TextStyle(
                                      fontSize: 12,
                                      color: isActive
                                          ? material.Colors.green
                                          : material.Colors.red,
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
