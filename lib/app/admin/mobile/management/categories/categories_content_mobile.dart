import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_toast.dart';

class CategoriesContentMobile extends material.StatefulWidget {
  const CategoriesContentMobile({super.key});

  @override
  material.State<CategoriesContentMobile> createState() =>
      _CategoriesContentMobileState();
}

class _CategoriesContentMobileState
    extends material.State<CategoriesContentMobile> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    material.WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadCategories());
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

        return material.Column(
          children: [
            material.Padding(
              padding: const material.EdgeInsets.all(16),
              child: material.TextField(
                decoration: const material.InputDecoration(
                  hintText: 'Cari kategori...',
                  prefixIcon: material.Icon(material.Icons.search),
                  border: material.OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            material.Expanded(
              child: filtered.isEmpty
                  ? const material.Center(
                      child: material.Text('Tidak ada kategori'))
                  : material.ListView.separated(
                      padding: const material.EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const material.SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final c = filtered[index];
                        return OurbitCard(
                          child: material.ListTile(
                            leading: material.CircleAvatar(
                              backgroundColor: material.Colors.orange[50],
                              child: const material.Icon(
                                  material.Icons.grid_view,
                                  color: material.Colors.orange),
                            ),
                            title: material.Text(
                              (c['name'] ?? '-').toString(),
                              style: const material.TextStyle(
                                  fontWeight: material.FontWeight.w600),
                            ),
                            subtitle: material.Text(
                              (c['description'] ?? 'Tanpa deskripsi')
                                  .toString(),
                              maxLines: 2,
                              overflow: material.TextOverflow.ellipsis,
                            ),
                            trailing: material.Text(
                                '${c['product_count'] ?? 0} produk'),
                            onTap: () {},
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
