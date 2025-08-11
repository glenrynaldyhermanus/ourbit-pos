import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/data/objects/product.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_toast.dart';

class ProductsContentMobile extends material.StatefulWidget {
  const ProductsContentMobile({super.key});

  @override
  material.State<ProductsContentMobile> createState() =>
      _ProductsContentMobileState();
}

class _ProductsContentMobileState extends material.State<ProductsContentMobile>
    with material.TickerProviderStateMixin {
  String _query = '';
  late final material.AnimationController _listController;

  @override
  void initState() {
    super.initState();
    // Trigger load products once
    material.WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadProducts());
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

        if (state is ManagementError) {
          return material.Center(
            child: material.Column(
              mainAxisSize: material.MainAxisSize.min,
              children: [
                const material.Icon(material.Icons.error_outline,
                    color: material.Colors.red, size: 48),
                const material.SizedBox(height: 12),
                material.Text(state.message),
                const material.SizedBox(height: 12),
                material.ElevatedButton(
                  onPressed: () =>
                      context.read<ManagementBloc>().add(LoadProducts()),
                  child: const material.Text('Muat Ulang'),
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

        return material.Column(
          children: [
            // Search
            material.Padding(
              padding: const material.EdgeInsets.all(16),
              child: material.TextField(
                decoration: const material.InputDecoration(
                  hintText: 'Cari produk...',
                  prefixIcon: material.Icon(material.Icons.search),
                  border: material.OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),

            // List
            material.Expanded(
              child: material.AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: filtered.isEmpty
                    ? const material.Center(
                        key: material.ValueKey('empty'),
                        child: material.Text('Tidak ada produk'))
                    : material.FadeTransition(
                        key: const material.ValueKey('list'),
                        opacity: _listController,
                        child: material.ListView.separated(
                          padding: const material.EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemBuilder: (context, index) {
                            final product = filtered[index];
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
                                    backgroundColor: material.Colors.blue[50],
                                    child: material.Text(
                                      product.name.isNotEmpty
                                          ? product.name[0].toUpperCase()
                                          : '?',
                                      style: const material.TextStyle(
                                        color: material.Colors.blue,
                                        fontWeight: material.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: material.Text(
                                    product.name,
                                    style: const material.TextStyle(
                                        fontWeight: material.FontWeight.w600),
                                  ),
                                  subtitle: material.Text(
                                    'Harga: Rp ${product.sellingPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}\nStok: ${product.stock}',
                                  ),
                                  isThreeLine: true,
                                  trailing: const material.Icon(
                                      material.Icons.chevron_right),
                                  onTap: () {
                                    // Placeholder action; future: open detail/edit sheet
                                  },
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const material.SizedBox(height: 8),
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
