import 'package:flutter/material.dart' as material;
import 'package:go_router/go_router.dart';

import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SuccessPageMobile extends StatefulWidget {
  const SuccessPageMobile({super.key});

  @override
  State<SuccessPageMobile> createState() => _SuccessPageMobileState();
}

class _SuccessPageMobileState extends State<SuccessPageMobile>
    with material.TickerProviderStateMixin {
  late material.AnimationController _animationController;
  late material.AnimationController _pulseController;
  late material.Animation<double> _scaleAnimation;
  late material.Animation<double> _fadeAnimation;
  late material.Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimationControllers();
  }

  void _initAnimationControllers() {
    _animationController = material.AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = material.AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = material.Tween<double>(begin: 0.0, end: 1.0).animate(
      material.CurvedAnimation(
        parent: _animationController,
        curve: material.Curves.elasticOut,
      ),
    );

    _fadeAnimation = material.Tween<double>(begin: 0.0, end: 1.0).animate(
      material.CurvedAnimation(
        parent: _animationController,
        curve: material.Curves.easeInOut,
      ),
    );

    _pulseAnimation = material.Tween<double>(begin: 1.0, end: 1.05).animate(
      material.CurvedAnimation(
        parent: _pulseController,
        curve: material.Curves.easeInOut,
      ),
    );

    // Start main animation
    _animationController.forward();
    
    // Start pulse animation after scale completes
    _animationController.addStatusListener((status) {
      if (status == material.AnimationStatus.completed) {
        _pulseController.forward().then((_) {
          _pulseController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return material.Scaffold(
      backgroundColor: material.Colors.green[50],
      body: material.SafeArea(
        child: material.Padding(
          padding: const material.EdgeInsets.all(24),
          child: material.Column(
            mainAxisAlignment: material.MainAxisAlignment.center,
            children: [
              // Success Icon with Animation
              material.AnimatedBuilder(
                animation: material.Listenable.merge([_scaleAnimation, _pulseAnimation]),
                builder: (context, child) {
                  final scale = _scaleAnimation.value * _pulseAnimation.value;
                  return material.Transform.scale(
                    scale: scale,
                    child: material.Container(
                      width: 120,
                      height: 120,
                      decoration: material.BoxDecoration(
                        color: material.Colors.green,
                        shape: material.BoxShape.circle,
                      ),
                      child: const material.Icon(
                        material.Icons.check,
                        size: 60,
                        color: material.Colors.white,
                      ),
                    ),
                  );
                },
              ),

              const material.SizedBox(height: 32),

              // Success Message
              material.AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return material.Opacity(
                    opacity: _fadeAnimation.value,
                    child: material.Transform.translate(
                      offset: material.Offset(0, 10 * (1 - _fadeAnimation.value)),
                      child: material.Column(
                        children: [
                          const material.Text(
                            'Pembayaran Berhasil!',
                            style: material.TextStyle(
                              fontSize: 24,
                              fontWeight: material.FontWeight.bold,
                              color: material.Colors.green,
                            ),
                            textAlign: material.TextAlign.center,
                          ),
                          const material.SizedBox(height: 12),
                          material.Text(
                            'Transaksi telah berhasil diproses dan struk telah dicetak.',
                            style: material.TextStyle(
                              fontSize: 16,
                              color: material.Colors.grey[600],
                            ),
                            textAlign: material.TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const material.SizedBox(height: 48),

              // Action Buttons
              material.AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return material.Opacity(
                    opacity: _fadeAnimation.value,
                    child: material.Transform.translate(
                      offset: material.Offset(0, 20 * (1 - _fadeAnimation.value)),
                      child: material.Column(
                        children: [
                          material.SizedBox(
                            width: double.infinity,
                            child: OurbitButton.primary(
                              onPressed: () => context.go('/pos'),
                              label: 'Kembali ke Kasir',
                            ),
                          ),
                          const material.SizedBox(height: 16),
                          material.SizedBox(
                            width: double.infinity,
                            child: OurbitButton.outline(
                              onPressed: () => context.go('/reports'),
                              label: 'Lihat Laporan',
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
