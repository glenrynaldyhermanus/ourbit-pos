import 'dart:async';
import 'dart:io' show Platform;

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';

class PrinterService {
  PrinterService._internal();

  static final PrinterService _instance = PrinterService._internal();
  static PrinterService get instance => _instance;

  final BluetoothPrint _bluetoothPrint = BluetoothPrint.instance;
  BluetoothDevice? _connectedDevice;

  Future<BluetoothDevice?> connectPreferredPrinter(
      {Duration timeout = const Duration(seconds: 6)}) async {
    try {
      if (!(Platform.isAndroid || Platform.isIOS)) {
        throw UnsupportedError(
            'Bluetooth printing hanya didukung di Android/iOS');
      }
      final bool isConnected = await _bluetoothPrint.isConnected ?? false;
      if (isConnected && _connectedDevice != null) return _connectedDevice;

      await _bluetoothPrint.startScan(timeout: timeout);
      final List<BluetoothDevice> devices = await _bluetoothPrint
          .scanResults.first
          .timeout(timeout + const Duration(seconds: 1));

      BluetoothDevice? candidate;
      for (final d in devices) {
        final name = (d.name ?? '').toLowerCase();
        if (name.contains('rpp02') ||
            name.contains('mp-58') ||
            name.contains('mp58') ||
            name.contains('rpp02n')) {
          candidate = d;
          break;
        }
      }

      candidate ??= devices.isNotEmpty ? devices.first : null;
      if (candidate == null) return null;

      await _bluetoothPrint.connect(candidate);
      _connectedDevice = candidate;
      return candidate;
    } catch (_) {
      return null;
    } finally {
      await _bluetoothPrint.stopScan();
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
    final bool isConnected = await _bluetoothPrint.isConnected ?? false;
    if (!isConnected) {
      final device = await connectPreferredPrinter();
      if (device == null) return;
    }

    final List<LineText> lines = [];
    lines.add(LineText(
      type: LineText.TYPE_TEXT,
      content: title,
      weight: 2,
      width: 2,
      height: 2,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));
    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: '--------------------------------',
        linefeed: 1));

    for (final item in items) {
      final String name = item['product']['name'] ?? '';
      final int qty = item['quantity'] ?? 0;
      final double price = (item['price'] ?? 0).toDouble();
      final double amount = price * qty;
      lines.add(LineText(type: LineText.TYPE_TEXT, content: name, linefeed: 1));
      lines.add(LineText(
          type: LineText.TYPE_TEXT,
          content:
              '$qty x ${_formatCurrency(price)}   ${_formatCurrency(amount)}',
          align: LineText.ALIGN_RIGHT,
          linefeed: 1));
    }

    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: '--------------------------------',
        linefeed: 1));
    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Subtotal: ${_formatCurrency(subtotal)}',
        align: LineText.ALIGN_RIGHT,
        linefeed: 1));
    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Pajak (11%): ${_formatCurrency(tax)}',
        align: LineText.ALIGN_RIGHT,
        linefeed: 1));
    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Total: ${_formatCurrency(total)}',
        weight: 2,
        align: LineText.ALIGN_RIGHT,
        linefeed: 2));

    if (footerNote != null && footerNote.isNotEmpty) {
      lines.add(LineText(
          type: LineText.TYPE_TEXT,
          content: footerNote,
          align: LineText.ALIGN_CENTER,
          linefeed: 1));
    }

    lines.add(LineText(
        type: LineText.TYPE_TEXT,
        content: 'Terima kasih!',
        align: LineText.ALIGN_CENTER,
        linefeed: 2));

    await _bluetoothPrint.printReceipt({}, lines);
  }

  String _formatCurrency(double amount) {
    final s = amount.toStringAsFixed(0);
    final re = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = s.replaceAllMapped(re, (m) => '${m[1]}.');
    return 'Rp $formatted';
  }
}
