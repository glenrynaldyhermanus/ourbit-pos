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

class SuppliersContentMobile extends StatefulWidget {
  const SuppliersContentMobile({super.key});

  @override
  State<SuppliersContentMobile> createState() => _SuppliersContentMobileState();
}

class _SuppliersContentMobileState extends State<SuppliersContentMobile>
    with TickerProviderStateMixin {
  String _query = '';
  late final AnimationController _listController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadSuppliers());
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
              content: Text(state.message),
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

        final data = state is SuppliersLoaded
            ? state.suppliers
            : <Map<String, dynamic>>[];
        final filtered = _query.isEmpty
            ? data
            : data.where((s) {
                final name = (s['name'] ?? '').toString().toLowerCase();
                final email = (s['email'] ?? '').toString().toLowerCase();
                final phone = (s['phone'] ?? '').toString().toLowerCase();
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
                placeholder: 'Cari supplier (nama/email/telepon)...',
                leading: const Icon(Icons.search),
                onChanged: (v) => setState(() => _query = v ?? ''),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: filtered.isEmpty
                    ? Center(
                        key: const ValueKey('empty'),
                        child: Text(
                          'Tidak ada supplier',
                          style: TextStyle(
                            color: Theme.of(context).brightness ==
                                    material.Brightness.dark
                                ? AppColors.darkSecondaryText
                                : AppColors.secondaryText,
                          ),
                        ),
                      )
                    : FadeTransition(
                        key: const ValueKey('list'),
                        opacity: _listController,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final s = filtered[index];
                            return TweenAnimationBuilder<double>(
                              duration:
                                  Duration(milliseconds: 150 + index * 50),
                              tween: Tween(begin: 0.0, end: 1.0),
                              builder: (context, t, child) {
                                return Opacity(
                                  opacity: t,
                                  child: Transform.translate(
                                    offset: Offset(0, 16 * (1 - t)),
                                    child: child,
                                  ),
                                );
                              },
                              child: OurbitCard(
                                child: material.ListTile(
                                  leading: material.CircleAvatar(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1),
                                    child: Icon(Icons.business,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary),
                                  ),
                                  title: Text(
                                    (s['name'] ?? '-').toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).brightness ==
                                                material.Brightness.dark
                                            ? AppColors.darkPrimaryText
                                            : AppColors.primaryText),
                                  ),
                                  subtitle: Text(
                                    [
                                      (s['email'] ?? '—').toString(),
                                      (s['phone'] ?? '—').toString(),
                                    ]
                                        .where((x) =>
                                            x.trim().isNotEmpty && x != '—')
                                        .join(' · '),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Theme.of(context).brightness ==
                                                material.Brightness.dark
                                            ? AppColors.darkSecondaryText
                                            : AppColors.secondaryText),
                                  ),
                                  trailing: Text(
                                      (s['address'] ?? '').toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Theme.of(context).brightness ==
                                                  material.Brightness.dark
                                              ? AppColors.darkSecondaryText
                                              : AppColors.secondaryText)),
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
