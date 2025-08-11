import 'dart:async';
import 'dart:io' show Platform;

// Temporarily remove direct bluetooth_print dependency. We will re-implement using
// flutter_bluetooth_printer API later.
// import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';

class PrinterService {
  PrinterService._internal();

  static final PrinterService _instance = PrinterService._internal();
  static PrinterService get instance => _instance;

  // TODO: Rewire to flutter_bluetooth_printer implementation
  dynamic _connectedDevice;

  Future<dynamic> connectPreferredPrinter(
      {Duration timeout = const Duration(seconds: 6)}) async {
    try {
      if (!(Platform.isAndroid || Platform.isIOS)) {
        throw UnsupportedError(
            'Bluetooth printing hanya didukung di Android/iOS');
      }
      return null; // No-op for now
    } catch (_) {
      return null;
    }
  }

  Future<void> printReceipt({
    required String title,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double total,
    String? footerNote,
  }) async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      throw UnsupportedError(
          'Bluetooth printing hanya didukung di Android/iOS');
    }
    // No-op until bluetooth printer re-integrated

    // Intentionally no-op for now to keep build green while migrating plugin
  }

  String _formatCurrency(double amount) {
    final s = amount.toStringAsFixed(0);
    final re = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = s.replaceAllMapped(re, (m) => '${m[1]}.');
    return 'Rp $formatted';
  }
}
