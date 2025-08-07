import 'package:shadcn_flutter/shadcn_flutter.dart';

class ProductLoading extends StatelessWidget {
  const ProductLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: 12, // Show 12 skeleton products
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Product image skeleton
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.slate[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                // Product name skeleton
                const Text('Product Name').semiBold().asSkeleton(),
                const SizedBox(height: 4),
                // Price skeleton
                const Text('Rp 0').muted().small().asSkeleton(),
                const SizedBox(height: 4),
                // Stock skeleton
                const Text('Stok: 0').muted().xSmall().asSkeleton(),
                const SizedBox(height: 8),
                // Button skeleton
                Container(
                  height: 32,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.slate[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 