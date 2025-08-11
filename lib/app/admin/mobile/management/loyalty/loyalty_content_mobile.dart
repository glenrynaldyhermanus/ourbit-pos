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

class _LoyaltyContentMobileState extends material.State<LoyaltyContentMobile> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    material.WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadLoyaltyPrograms());
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
              child: filtered.isEmpty
                  ? const material.Center(
                      child: material.Text('Tidak ada program loyalitas'))
                  : material.ListView.separated(
                      padding: const material.EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const material.SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final p = filtered[index];
                        final isActive = (p['is_active'] ?? true) as bool;
                        return OurbitCard(
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
