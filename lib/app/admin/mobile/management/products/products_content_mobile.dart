import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/data/objects/product.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_circular_progress.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class ProductsContentMobile extends StatefulWidget {
  const ProductsContentMobile({super.key});

  @override
  State<ProductsContentMobile> createState() => _ProductsContentMobileState();
}

class _ProductsContentMobileState extends State<ProductsContentMobile>
    with TickerProviderStateMixin {
  String _query = '';
  late final AnimationController _listController;

  @override
  void initState() {
    super.initState();
    // Trigger load products once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadProducts());
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

        if (state is ManagementError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.amber, size: 48),
                const SizedBox(height: 12),
                Text(
                  state.message,
                  style: TextStyle(
                    color:
                        Theme.of(context).brightness == material.Brightness.dark
                            ? AppColors.darkSecondaryText
                            : AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 12),
                OurbitButton.primary(
                  onPressed: () =>
                      context.read<ManagementBloc>().add(LoadProducts()),
                  label: 'Muat Ulang',
                ),
              ],
            ),
          );
        }

        final products = state is ProductsLoaded ? state.products : <Product>[];
        final filtered = _query.isEmpty
            ? products
            : products
                .where(
                    (p) => p.name.toLowerCase().contains(_query.toLowerCase()))
                .toList();

        return Column(
          children: [
            // Search
            Padding(
              padding: const EdgeInsets.all(16),
              child: OurbitTextInput(
                placeholder: 'Cari produk...',
                leading: const Icon(Icons.search),
                onChanged: (v) => setState(() => _query = v ?? ''),
              ),
            ),

            // List
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: filtered.isEmpty
                    ? Center(
                        key: const ValueKey('empty'),
                        child: Text(
                          'Tidak ada produk',
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
                          itemBuilder: (context, index) {
                            final product = filtered[index];
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
                                    child: Text(
                                      product.name.isNotEmpty
                                          ? product.name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    product.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).brightness ==
                                                material.Brightness.dark
                                            ? AppColors.darkPrimaryText
                                            : AppColors.primaryText),
                                  ),
                                  subtitle: Text(
                                    'Harga: Rp ${product.sellingPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}\nStok: ${product.stock}',
                                    style: TextStyle(
                                        color: Theme.of(context).brightness ==
                                                material.Brightness.dark
                                            ? AppColors.darkSecondaryText
                                            : AppColors.secondaryText),
                                  ),
                                  isThreeLine: true,
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    // Placeholder action; future: open detail/edit sheet
                                  },
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemCount: filtered.length,
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
