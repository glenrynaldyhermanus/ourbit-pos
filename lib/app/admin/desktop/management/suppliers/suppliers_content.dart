import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
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

          // Non-empty: simple header + jumlah (placeholder untuk versi tabel penuh)
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
              Text('Total supplier: ${state.suppliers.length}'),
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
