import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:ourbit_pos/blocs/management_bloc.dart';
import 'package:ourbit_pos/blocs/management_event.dart';
import 'package:ourbit_pos/blocs/management_state.dart';

class DiscountsContent extends StatefulWidget {
  const DiscountsContent({super.key});

  @override
  State<DiscountsContent> createState() => _DiscountsContentState();
}

class _DiscountsContentState extends State<DiscountsContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ManagementBloc>().add(LoadDiscounts());
    });
  }

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

        if (state is DiscountsLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daftar Diskon',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text('Total diskon: ${state.discounts.length}'),
            ],
          );
        }

        return const Center(
          child: Text('Tidak ada data diskon'),
        );
      },
    );
  }
}
