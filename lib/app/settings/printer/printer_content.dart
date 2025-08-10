import 'dart:io' show Platform;

import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as material;
import 'package:ourbit_pos/src/core/theme/app_theme.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/core/services/printer_service.dart';
import 'package:ourbit_pos/src/widgets/ui/feedback/ourbit_toast.dart';
import 'package:ourbit_pos/src/core/services/receipt_pdf_service.dart';
import 'package:printing/printing.dart';

class PrinterContent extends StatefulWidget {
  const PrinterContent({super.key});

  @override
  State<PrinterContent> createState() => _PrinterContentState();
}

class _PrinterContentState extends State<PrinterContent> {
  final BluetoothPrint _bluetoothPrint = BluetoothPrint.instance;
  List<BluetoothDevice> _devices = const [];
  BluetoothDevice? _connected;
  bool _scanning = false;
  Printer? _pickedOsPrinter;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      // Desktop init
      return;
    }
    final isConnected = await _bluetoothPrint.isConnected ?? false;
    if (isConnected) {
      // Note: plugin doesn't expose current device directly
      setState(() {
        _connected = null;
      });
    }
    await _refreshDevices();
  }

  Future<void> _refreshDevices() async {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      setState(() {
        _devices = const [];
      });
      return;
    }

    setState(() => _scanning = true);
    await _bluetoothPrint.startScan(timeout: const Duration(seconds: 4));
    try {
      final list = await _bluetoothPrint.scanResults.first
          .timeout(const Duration(seconds: 6));
      setState(() {
        _devices = list;
      });
    } finally {
      await _bluetoothPrint.stopScan();
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _pickOsPrinter() async {
    try {
      final printer = await Printing.pickPrinter(context: context);
      if (printer != null) {
        setState(() => _pickedOsPrinter = printer);
        OurbitToast.success(
          context: context,
          title: 'Berhasil',
          content: 'Printer dipilih: ${printer.name}',
        );
      }
    } catch (e) {
      OurbitToast.error(
        context: context,
        title: 'Gagal',
        content: 'Gagal memilih printer OS: $e',
      );
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    try {
      await _bluetoothPrint.connect(device);
      setState(() => _connected = device);
      if (mounted) {
        OurbitToast.success(
          context: context,
          title: 'Berhasil',
          content: 'Printer terhubung',
        );
      }
    } catch (e) {
      if (mounted) {
        OurbitToast.error(
          context: context,
          title: 'Gagal',
          content: 'Gagal menghubungkan: $e',
        );
      }
    }
  }

  Future<void> _disconnect() async {
    try {
      await _bluetoothPrint.disconnect();
      setState(() => _connected = null);
    } catch (_) {}
  }

  Future<void> _testPrint() async {
    try {
      const items = [
        {
          'product': {'name': 'Contoh Item'},
          'quantity': 1,
          'price': 10000.0,
        }
      ];
      if (Platform.isAndroid || Platform.isIOS) {
        await PrinterService.instance.printReceipt(
          title: 'Tes Printer',
          items: items,
          subtotal: 10000,
          tax: 1100,
          total: 11100,
          footerNote: 'Tes berhasil',
        );
      } else {
        if (_pickedOsPrinter != null) {
          final bytes = await ReceiptPdfService.instance.buildReceipt(
            title: 'Tes Printer',
            items: items,
            subtotal: 10000,
            tax: 1100,
            total: 11100,
            footerNote: 'Tes berhasil',
          );
          await Printing.directPrintPdf(
            printer: _pickedOsPrinter!,
            onLayout: (format) async => bytes,
          );
        } else {
          await ReceiptPdfService.instance.printReceipt(
            title: 'Tes Printer',
            items: items,
            subtotal: 10000,
            tax: 1100,
            total: 11100,
            footerNote: 'Tes berhasil',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        OurbitToast.error(
          context: context,
          title: 'Gagal',
          content: 'Tes print gagal: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Pengaturan Printer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryText,
              ),
            ),
            const Spacer(),
            OurbitButton.outline(
              onPressed: _scanning ? null : _refreshDevices,
              label: 'Refresh',
              leadingIcon: const Icon(Icons.refresh, size: 16),
            ),
            const SizedBox(width: 8),
            OurbitButton.primary(
              onPressed: () async {
                if (!(Platform.isAndroid || Platform.isIOS)) {
                  OurbitToast.info(
                    context: context,
                    title: 'Info',
                    content: 'Menambah printer hanya didukung di Android/iOS',
                  );
                  return;
                }
                await _refreshDevices();
              },
              label: 'Tambah Printer',
              leadingIcon: const Icon(Icons.add, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!(Platform.isAndroid || Platform.isIOS))
          const Text('Cetak via Sistem (PDF) tersedia di platform ini.'),
        if (Platform.isAndroid || Platform.isIOS) ...[
          if (_connected != null)
            Row(
              children: [
                const Icon(Icons.bluetooth_connected),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(_connected!.name ?? 'Perangkat terhubung'),
                ),
                OurbitButton.outline(
                  onPressed: _disconnect,
                  label: 'Putuskan',
                ),
                const SizedBox(width: 8),
                OurbitButton.primary(
                  onPressed: _testPrint,
                  label: Platform.isAndroid || Platform.isIOS
                      ? 'Tes Print (Bluetooth)'
                      : 'Tes Print (Cetak Sistem)',
                  leadingIcon: const Icon(Icons.print, size: 16),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                for (final d in _devices)
                  material.ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(d.name ?? 'Unknown'),
                    subtitle: Text(d.address ?? ''),
                    trailing: OurbitButton(
                      onPressed: () => _connect(d),
                      label: 'Hubungkan',
                    ),
                  ),
                if (_devices.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Tidak ada perangkat ditemukan'),
                  )
              ],
            ),
          ),
        ] else ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Printer OS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
              const Spacer(),
              OurbitButton.outline(
                onPressed: _pickOsPrinter,
                label: 'Pilih Printer OS',
                leadingIcon: const Icon(Icons.print, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _pickedOsPrinter == null
                      ? 'Belum ada printer OS dipilih'
                      : 'Dipilih: ${_pickedOsPrinter!.name}',
                ),
              ),
              OurbitButton.primary(
                onPressed: _testPrint,
                label: 'Tes Print (Printer OS)',
                leadingIcon: const Icon(Icons.print, size: 16),
              ),
            ],
          ),
        ]
      ],
    );
  }
}
