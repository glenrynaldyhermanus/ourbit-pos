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

class _ProductsContentMobileState
    extends material.State<ProductsContentMobile> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Trigger load products once
    material.WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadProducts());
    });
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
              child: filtered.isEmpty
                  ? const material.Center(
                      child: material.Text('Tidak ada produk'))
                  : material.ListView.separated(
                      padding: const material.EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return OurbitCard(
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
                              'Harga: Rp ${product.sellingPrice.toStringAsFixed(0).replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (m) => '${m[1]}.',
                                  )}\nStok: ${product.stock}',
                            ),
                            isThreeLine: true,
                            trailing: const material.Icon(
                                material.Icons.chevron_right),
                            onTap: () {
                              // Placeholder action; future: open detail/edit sheet
                            },
                          ),
                        );
                      },
                      separatorBuilder: (_, __) =>
                          const material.SizedBox(height: 8),
                      itemCount: filtered.length,
                    ),
            ),
          ],
        );
      },
    );
  }
}
