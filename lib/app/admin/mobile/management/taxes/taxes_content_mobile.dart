import 'package:flutter/material.dart' as material;

class TaxesContentMobile extends material.StatelessWidget {
  const TaxesContentMobile({super.key});

  @override
  material.Widget build(material.BuildContext context) {
    return const material.Center(
      child: material.Text(
        'Halaman Pajak (Mobile) - Segera Hadir',
        style: material.TextStyle(fontSize: 18),
      ),
    );
  }
}
