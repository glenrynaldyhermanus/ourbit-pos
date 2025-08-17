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

class CategoriesContentMobile extends StatefulWidget {
  const CategoriesContentMobile({super.key});

  @override
  State<CategoriesContentMobile> createState() =>
      _CategoriesContentMobileState();
}

class _CategoriesContentMobileState extends State<CategoriesContentMobile>
    with TickerProviderStateMixin {
  String _query = '';
  late final AnimationController _listController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadCategories());
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

        final categories = state is CategoriesLoaded
            ? state.categories
            : <Map<String, dynamic>>[];
        final filtered = _query.isEmpty
            ? categories
            : categories.where((c) {
                final name = (c['name'] ?? '').toString().toLowerCase();
                final desc = (c['description'] ?? '').toString().toLowerCase();
                final q = _query.toLowerCase();
                return name.contains(q) || desc.contains(q);
              }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: OurbitTextInput(
                placeholder: 'Cari kategori...',
                leading: const Icon(Icons.search, size: 16),
                onChanged: (v) => setState(() => _query = (v ?? '')),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: filtered.isEmpty
                    ? Center(
                        key: const ValueKey('empty'),
                        child: Text(
                          'Tidak ada kategori',
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
                            final c = filtered[index];
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
                                    backgroundColor: material.Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1),
                                    child: Icon(Icons.grid_view,
                                        color: Theme.of(context)
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
                                    (c['description'] ?? 'Tanpa deskripsi')
                                        .toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Theme.of(context).brightness ==
                                                material.Brightness.dark
                                            ? AppColors.darkSecondaryText
                                            : AppColors.secondaryText),
                                  ),
                                  trailing: Text(
                                      '${c['product_count'] ?? 0} produk',
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
