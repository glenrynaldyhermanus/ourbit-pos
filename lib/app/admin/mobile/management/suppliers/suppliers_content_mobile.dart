import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_toast.dart';

class SuppliersContentMobile extends material.StatefulWidget {
  const SuppliersContentMobile({super.key});

  @override
  material.State<SuppliersContentMobile> createState() =>
      _SuppliersContentMobileState();
}

class _SuppliersContentMobileState
    extends material.State<SuppliersContentMobile> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    material.WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadSuppliers());
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

        return material.Column(
          children: [
            material.Padding(
              padding: const material.EdgeInsets.all(16),
              child: material.TextField(
                decoration: const material.InputDecoration(
                  hintText: 'Cari supplier (nama/email/telepon)...',
                  prefixIcon: material.Icon(material.Icons.search),
                  border: material.OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            material.Expanded(
              child: filtered.isEmpty
                  ? const material.Center(
                      child: material.Text('Tidak ada supplier'))
                  : material.ListView.separated(
                      padding: const material.EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const material.SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final s = filtered[index];
                        return OurbitCard(
                          child: material.ListTile(
                            leading: material.CircleAvatar(
                              backgroundColor: material.Colors.purple[50],
                              child: const material.Icon(
                                  material.Icons.business,
                                  color: material.Colors.purple),
                            ),
                            title: material.Text(
                              (s['name'] ?? '-').toString(),
                              style: const material.TextStyle(
                                  fontWeight: material.FontWeight.w600),
                            ),
                            subtitle: material.Text(
                              [
                                (s['email'] ?? '—').toString(),
                                (s['phone'] ?? '—').toString(),
                              ]
                                  .where((x) => x.trim().isNotEmpty && x != '—')
                                  .join(' · '),
                              maxLines: 2,
                              overflow: material.TextOverflow.ellipsis,
                            ),
                            trailing: material.Text(
                                (s['address'] ?? '').toString(),
                                maxLines: 1,
                                overflow: material.TextOverflow.ellipsis),
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
