import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_circular_progress.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class CustomersContentMobile extends StatefulWidget {
  const CustomersContentMobile({super.key});

  @override
  State<CustomersContentMobile> createState() => _CustomersContentMobileState();
}

class _CustomersContentMobileState extends State<CustomersContentMobile>
    with TickerProviderStateMixin {
  String _query = '';
  late final AnimationController _listController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadCustomers());
      _listController.forward();
    });
    _listController = AnimationController(
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
  Widget build(BuildContext context) {
    return BlocConsumer<ManagementBloc, ManagementState>(
      listener: (context, state) {
        if (state is ManagementError) {
          material.ScaffoldMessenger.of(context).showSnackBar(
            material.SnackBar(
              content: material.Text(state.message),
              backgroundColor: AppColors.error,
              behavior: material.SnackBarBehavior.floating,
              shape: material.RoundedRectangleBorder(
                borderRadius: material.BorderRadius.circular(8),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ManagementLoading || state is ManagementInitial) {
          return const Center(child: OurbitCircularProgress());
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

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: OurbitTextInput(
                placeholder: 'Cari pelanggan (nama/email/telepon)...',
                leading: const Icon(Icons.search, size: 16),
                onChanged: (v) => setState(() => _query = (v ?? '')),
              ),
            ),
            material.Expanded(
              child: material.AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: filtered.isEmpty
                    ? material.Center(
                        key: const material.ValueKey('empty'),
                        child: material.Text(
                          'Tidak ada pelanggan',
                          style: material.TextStyle(
                            color: material.Theme.of(context).brightness ==
                                    material.Brightness.dark
                                ? AppColors.darkSecondaryText
                                : AppColors.secondaryText,
                          ),
                        ),
                      )
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
                                    backgroundColor: material.Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1),
                                    child: material.Icon(material.Icons.person,
                                        color: material.Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                  title: Text(
                                    (c['name'] ?? '-').toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).brightness ==
                                                material.Brightness.dark
                                            ? AppColors.darkPrimaryText
                                            : AppColors.primaryText),
                                  ),
                                  subtitle: Text(
                                    [
                                      (c['email'] ?? '—').toString(),
                                      (c['phone'] ?? '—').toString(),
                                    ]
                                        .where((s) =>
                                            s.trim().isNotEmpty && s != '—')
                                        .join(' · '),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Theme.of(context).brightness ==
                                                material.Brightness.dark
                                            ? AppColors.darkSecondaryText
                                            : AppColors.secondaryText),
                                  ),
                                  trailing: material.Container(
                                    padding:
                                        const material.EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                    decoration: material.BoxDecoration(
                                      color: (isActive
                                              ? material.Colors.green
                                              : material.Colors.red)
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          material.BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      isActive ? 'Aktif' : 'Nonaktif',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isActive
                                            ? Colors.green[600]
                                            : Colors.red[600],
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
