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

class _DiscountsContentMobileState
    extends material.State<DiscountsContentMobile> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    material.WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadDiscounts());
    });
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
              child: filtered.isEmpty
                  ? const material.Center(
                      child: material.Text('Tidak ada diskon'))
                  : material.ListView.separated(
                      padding: const material.EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const material.SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final d = filtered[index];
                        final isActive = (d['is_active'] ?? true) as bool;
                        return OurbitCard(
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
