import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_dialog.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_icon_button.dart';
import 'package:ourbit_pos/src/widgets/ui/table/ourbit_table.dart';
import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:provider/provider.dart';
import 'widgets/supplier_form_sheet.dart';

class SuppliersContent extends StatefulWidget {
  const SuppliersContent({super.key});

  @override
  State<SuppliersContent> createState() => _SuppliersContentState();
}

class _SuppliersContentState extends State<SuppliersContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadSuppliers());
    });
  }

  // No controller/state yet in simple view

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManagementBloc, ManagementState>(
      builder: (context, state) {
        if (state is ManagementLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is ManagementError) {
          return Center(
            child: Text('Error: ${state.message}'),
          );
        }

        if (state is SuppliersLoaded) {
          if (state.suppliers.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Supplier',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text('Kelola data supplier dan vendor'),
                        ],
                      ),
                    ),
                    OurbitButton.primary(
                      onPressed: () {
                        openSheet(
                          context: context,
                          builder: (c) => const SupplierFormSheet(),
                          position: OverlayPosition.right,
                        );
                      },
                      label: 'Tambah Supplier',
                      leadingIcon:
                          const Icon(Icons.add, size: 16, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Expanded(
                  child: Center(child: Text('Tidak ada data supplier')),
                ),
              ],
            );
          }

          // Non-empty: tampilkan tabel supplier dengan styling seperti pelanggan
          final suppliers = state.suppliers;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Supplier',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text('Kelola data supplier dan vendor'),
                      ],
                    ),
                  ),
                  OurbitButton.primary(
                    onPressed: () {
                      openSheet(
                        context: context,
                        builder: (c) => const SupplierFormSheet(),
                        position: OverlayPosition.right,
                      );
                    },
                    label: 'Tambah Supplier',
                    leadingIcon:
                        const Icon(Icons.add, size: 16, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<ThemeService>(
                builder: (context, themeService, _) {
                  final bool isDark = themeService.isDarkMode;
                  final Color borderColor = isDark
                      ? const Color(0xff292524)
                      : const Color(0xFFE5E7EB);

                  final headers = [
                    const OurbitTableCell(
                      child: Text('Supplier'),
                      isHeader: true,
                      expanded: false,
                      width: 320,
                    ).build(context),
                    const OurbitTableCell(
                      child: Text('Kontak'),
                      isHeader: true,
                      expanded: false,
                      width: 220,
                    ).build(context),
                    const OurbitTableCell(
                      child: Text('Alamat'),
                      isHeader: true,
                      expanded: false,
                      width: 360,
                    ).build(context),
                    const OurbitTableCell(
                      child: Text('Status'),
                      isHeader: true,
                      expanded: false,
                      width: 140,
                    ).build(context),
                    const OurbitTableCell(
                      child: Text(''),
                      isHeader: true,
                      expanded: false,
                      width: 96,
                    ).build(context),
                  ];

                  final rows = suppliers.map((s) {
                    return TableRow(cells: [
                      // Supplier (nama + email) dengan avatar
                      OurbitTableCell(
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.muted,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.business, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (s['name'] ?? '-').toString(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    (s['email'] ?? 'Tanpa email').toString(),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .mutedForeground,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        expanded: false,
                        width: 320,
                      ).build(context),

                      // Kontak (telepon + email ringan)
                      OurbitTableCell(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((s['phone'] ?? '').toString().isNotEmpty)
                              Text((s['phone'] ?? '').toString()),
                            Text(
                              (s['email'] ?? '—').toString(),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .mutedForeground,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        expanded: false,
                        width: 220,
                      ).build(context),

                      // Alamat
                      OurbitTableCell(
                        child: Text(
                          (s['address'] ?? '—').toString(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        expanded: false,
                        width: 360,
                      ).build(context),

                      // Status chip
                      OurbitTableCell(
                        child: _buildStatusChip(
                          context,
                          label:
                              (s['is_active'] ?? true) ? 'Aktif' : 'Nonaktif',
                          isPositive: (s['is_active'] ?? true),
                        ),
                        expanded: false,
                        width: 140,
                      ).build(context),

                      // Actions icon buttons
                      OurbitTableCell(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OurbitIconButton.ghost(
                              onPressed: () {
                                openSheet(
                                  context: context,
                                  builder: (c) => SupplierFormSheet(item: s),
                                  position: OverlayPosition.right,
                                );
                              },
                              icon: const Icon(Icons.edit, size: 16),
                            ),
                            const SizedBox(width: 6),
                            OurbitIconButton.destructive(
                              onPressed: () async {
                                final confirmed = await OurbitDialog.show(
                                  context: context,
                                  title: 'Hapus Supplier',
                                  content:
                                      'Apakah Anda yakin ingin menghapus "${(s['name'] ?? '-').toString()}"?',
                                  confirmText: 'Hapus',
                                  cancelText: 'Batal',
                                  isDestructive: true,
                                );
                                if (confirmed == true && context.mounted) {
                                  final id = (s['id'] ?? '').toString();
                                  if (id.isNotEmpty) {
                                    context
                                        .read<ManagementBloc>()
                                        .add(DeleteSupplier(supplierId: id));
                                  }
                                }
                              },
                              icon: const Icon(Icons.delete, size: 16),
                            ),
                          ],
                        ),
                        expanded: false,
                        width: 96,
                      ).build(context),
                    ]);
                  }).toList();

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: borderColor, width: 0.5),
                      borderRadius: Theme.of(context).borderRadiusMd,
                    ),
                    child: OurbitTable(
                      minHeight: 400,
                      scrollable: false,
                      borderRadius: Theme.of(context).borderRadiusMd,
                      borderColor: borderColor,
                      headers: headers,
                      rows: rows,
                    ),
                  );
                },
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header + actions even when empty
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Supplier',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('Kelola data supplier dan vendor'),
                    ],
                  ),
                ),
                OurbitButton.primary(
                  onPressed: () {
                    openSheet(
                      context: context,
                      builder: (c) => const SupplierFormSheet(),
                      position: OverlayPosition.right,
                    );
                  },
                  label: 'Tambah Supplier',
                  leadingIcon:
                      const Icon(Icons.add, size: 16, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Expanded(
              child: Center(
                child: Text('Tidak ada data supplier'),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildStatusChip(BuildContext context,
    {required String label, required bool isPositive}) {
  final Color fg = isPositive ? Colors.green.shade600 : Colors.red.shade600;
  final Color bg = isPositive
      ? Colors.green.withValues(alpha: 0.1)
      : Colors.red.withValues(alpha: 0.1);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
    ),
  );
}
