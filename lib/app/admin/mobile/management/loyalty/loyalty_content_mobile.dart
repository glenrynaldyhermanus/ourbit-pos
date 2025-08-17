import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';

class LoyaltyContentMobile extends material.StatelessWidget {
  const LoyaltyContentMobile({super.key});

  @override
  material.Widget build(material.BuildContext context) {
    final scheme = material.Theme.of(context).colorScheme;
    return material.Center(
      child: OurbitCard(
        child: material.Padding(
          padding: const material.EdgeInsets.all(24),
          child: material.Column(
            mainAxisSize: material.MainAxisSize.min,
            children: [
              material.Icon(material.Icons.card_giftcard,
                  size: 64, color: scheme.onSurfaceVariant),
              const material.SizedBox(height: 16),
              const material.Text(
                'Program Loyalitas',
                style: material.TextStyle(
                    fontSize: 20, fontWeight: material.FontWeight.w600),
              ),
              const material.SizedBox(height: 8),
              material.Text(
                'Pengelolaan program loyalitas akan tersedia segera.',
                style: material.TextStyle(fontSize: 14, color: scheme.outline),
                textAlign: material.TextAlign.center,
              ),
              const material.SizedBox(height: 24),
              material.Container(
                padding: const material.EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: material.BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.1),
                  borderRadius: material.BorderRadius.circular(20),
                ),
                child: material.Text(
                  'Coming Soon',
                  style: material.TextStyle(
                    fontSize: 12,
                    fontWeight: material.FontWeight.w500,
                    color: scheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
