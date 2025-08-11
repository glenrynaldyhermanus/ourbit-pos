import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';

class LoyaltyContentMobile extends material.StatefulWidget {
  const LoyaltyContentMobile({super.key});

  @override
  material.State<LoyaltyContentMobile> createState() =>
      _LoyaltyContentMobileState();
}

class _LoyaltyContentMobileState extends material.State<LoyaltyContentMobile>
    with material.TickerProviderStateMixin {
  String _query = '';
  late final material.AnimationController _listController;

  @override
  void initState() {
    super.initState();
    material.WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadLoyaltyPrograms());
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

        final data = state is LoyaltyProgramsLoaded
            ? state.programs
            : <Map<String, dynamic>>[];
        final filtered = _query.isEmpty
            ? data
            : data.where((p) {
                final name = (p['name'] ?? '').toString().toLowerCase();
                final q = _query.toLowerCase();
                return name.contains(q);
              }).toList();

        return material.Column(
          children: [
            material.Padding(
              padding: const material.EdgeInsets.all(16),
              child: material.TextField(
                decoration: const material.InputDecoration(
                  hintText: 'Cari program loyalitas...',
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
                        child: material.Text('Tidak ada program loyalitas'))
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
                            final p = filtered[index];
                            final isActive = (p['is_active'] ?? true) as bool;
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
                                    backgroundColor: material.Colors.amber[50],
                                    child: const material.Icon(
                                        material.Icons.card_giftcard,
                                        color: material.Colors.amber),
                                  ),
                                  title: material.Text(
                                    (p['name'] ?? '-').toString(),
                                    style: const material.TextStyle(
                                        fontWeight: material.FontWeight.w600),
                                  ),
                                  subtitle: material.Text(
                                      (p['description'] ?? '—').toString(),
                                      maxLines: 2,
                                      overflow: material.TextOverflow.ellipsis),
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
