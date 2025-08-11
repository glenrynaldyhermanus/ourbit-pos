import 'package:flutter/material.dart' as material;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';

class ExpensesContentMobile extends material.StatefulWidget {
  const ExpensesContentMobile({super.key});

  @override
  material.State<ExpensesContentMobile> createState() =>
      _ExpensesContentMobileState();
}

class _ExpensesContentMobileState
    extends material.State<ExpensesContentMobile> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    material.WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadExpenses());
    });
  }

  String _formatCurrency(num amount) {
    final value = amount.toDouble();
    return 'Rp ${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'), (m) => '${m[1]}.')}';
  }

  @override
  material.Widget build(material.BuildContext context) {
    return BlocBuilder<ManagementBloc, ManagementState>(
      builder: (context, state) {
        if (state is ManagementLoading || state is ManagementInitial) {
          return const material.Center(
              child: material.CircularProgressIndicator());
        }

        final data =
            state is ExpensesLoaded ? state.expenses : <Map<String, dynamic>>[];
        final filtered = _query.isEmpty
            ? data
            : data.where((e) {
                final note = (e['note'] ?? '').toString().toLowerCase();
                final category = (e['category'] ?? '').toString().toLowerCase();
                final q = _query.toLowerCase();
                return note.contains(q) || category.contains(q);
              }).toList();

        return material.Column(
          children: [
            material.Padding(
              padding: const material.EdgeInsets.all(16),
              child: material.TextField(
                decoration: const material.InputDecoration(
                  hintText: 'Cari pengeluaran...',
                  prefixIcon: material.Icon(material.Icons.search),
                  border: material.OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            material.Expanded(
              child: filtered.isEmpty
                  ? const material.Center(
                      child: material.Text('Tidak ada pengeluaran'))
                  : material.ListView.separated(
                      padding: const material.EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          const material.SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final e = filtered[index];
                        final isPaid = (e['is_paid'] ?? false) as bool;
                        return OurbitCard(
                          child: material.ListTile(
                            leading: material.CircleAvatar(
                              backgroundColor: material.Colors.red[50],
                              child: const material.Icon(
                                  material.Icons.receipt_long,
                                  color: material.Colors.red),
                            ),
                            title: material.Text(
                              (e['category'] ?? '-').toString(),
                              style: const material.TextStyle(
                                  fontWeight: material.FontWeight.w600),
                            ),
                            subtitle: material.Text(
                              (e['note'] ?? '—').toString(),
                              maxLines: 2,
                              overflow: material.TextOverflow.ellipsis,
                            ),
                            trailing: material.Column(
                              mainAxisAlignment:
                                  material.MainAxisAlignment.center,
                              crossAxisAlignment:
                                  material.CrossAxisAlignment.end,
                              children: [
                                material.Text(
                                  _formatCurrency((e['amount'] ?? 0) as num),
                                  style: const material.TextStyle(
                                      fontWeight: material.FontWeight.bold),
                                ),
                                const material.SizedBox(height: 4),
                                material.Text(
                                  isPaid ? 'Dibayar' : 'Belum dibayar',
                                  style: material.TextStyle(
                                    fontSize: 12,
                                    color: isPaid
                                        ? material.Colors.green
                                        : material.Colors.orange,
                                  ),
                                ),
                              ],
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
