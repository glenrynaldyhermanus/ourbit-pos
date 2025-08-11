import 'package:flutter/material.dart' as material;
import 'dart:io' show Platform;
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:printing/printing.dart';

class PrinterContentMobile extends material.StatefulWidget {
  const PrinterContentMobile({super.key});

  @override
  material.State<PrinterContentMobile> createState() =>
      _PrinterContentMobileState();
}

class _PrinterContentMobileState extends material.State<PrinterContentMobile> {
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
      return;
    }
    final isConnected = await _bluetoothPrint.isConnected ?? false;
    if (isConnected) {
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
        material.ScaffoldMessenger.of(context).showSnackBar(
          material.SnackBar(
            content: material.Text('Printer dipilih: ${printer.name}'),
            backgroundColor: material.Colors.green,
          ),
        );
      }
    } catch (e) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: material.Text('Gagal memilih printer OS: $e'),
          backgroundColor: material.Colors.red,
        ),
      );
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    try {
      await _bluetoothPrint.connect(device);
      setState(() => _connected = device);
      if (mounted) {
        material.ScaffoldMessenger.of(context).showSnackBar(
          material.SnackBar(
            content: material.Text('Printer terhubung'),
            backgroundColor: material.Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        material.ScaffoldMessenger.of(context).showSnackBar(
          material.SnackBar(
            content: material.Text('Gagal menghubungkan printer'),
            backgroundColor: material.Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    try {
      await _bluetoothPrint.disconnect();
      setState(() => _connected = null);
      if (mounted) {
        material.ScaffoldMessenger.of(context).showSnackBar(
          material.SnackBar(
            content: material.Text('Printer terputus'),
            backgroundColor: material.Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        material.ScaffoldMessenger.of(context).showSnackBar(
          material.SnackBar(
            content: material.Text('Gagal memutuskan printer'),
            backgroundColor: material.Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _testPrint() async {
    try {
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: material.Text('Fitur test print akan segera tersedia'),
          backgroundColor: material.Colors.blue,
        ),
      );
    } catch (e) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: material.Text('Gagal test print: $e'),
          backgroundColor: material.Colors.red,
        ),
      );
    }
  }

  @override
  material.Widget build(material.BuildContext context) {
    return material.SingleChildScrollView(
      padding: const material.EdgeInsets.all(16),
      child: material.Column(
        crossAxisAlignment: material.CrossAxisAlignment.start,
        children: [
          // Header
          material.Text(
            'Pengaturan Printer',
            style: material.Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: material.FontWeight.bold,
                ),
          ),
          const material.SizedBox(height: 8),
          material.Text(
            'Kelola printer untuk cetak struk dan laporan',
            style: material.Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: material.Colors.grey[600],
                ),
          ),
          const material.SizedBox(height: 24),

          // Bluetooth Printer Section
          material.Card(
            child: material.Padding(
              padding: const material.EdgeInsets.all(16),
              child: material.Column(
                crossAxisAlignment: material.CrossAxisAlignment.start,
                children: [
                  material.Text(
                    'Printer Bluetooth',
                    style: material.Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: material.FontWeight.w600),
                  ),
                  const material.SizedBox(height: 16),

                  // Connection Status
                  if (_connected != null) ...[
                    material.Container(
                      padding: const material.EdgeInsets.all(12),
                      decoration: material.BoxDecoration(
                        color: material.Colors.green[50],
                        borderRadius: material.BorderRadius.circular(8),
                        border:
                            material.Border.all(color: material.Colors.green),
                      ),
                      child: material.Row(
                        children: [
                          material.Icon(
                            material.Icons.bluetooth_connected,
                            color: material.Colors.green,
                          ),
                          const material.SizedBox(width: 8),
                          material.Expanded(
                            child: material.Text(
                              'Terhubung ke: ${_connected!.name}',
                              style: material.TextStyle(
                                color: material.Colors.green[700],
                                fontWeight: material.FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const material.SizedBox(height: 12),
                    material.SizedBox(
                      width: double.infinity,
                      child: OurbitButton.secondary(
                        onPressed: _disconnect,
                        label: 'Putuskan',
                      ),
                    ),
                  ] else ...[
                    material.Container(
                      padding: const material.EdgeInsets.all(12),
                      decoration: material.BoxDecoration(
                        color: material.Colors.grey[50],
                        borderRadius: material.BorderRadius.circular(8),
                        border:
                            material.Border.all(color: material.Colors.grey),
                      ),
                      child: material.Row(
                        children: [
                          material.Icon(
                            material.Icons.bluetooth_disabled,
                            color: material.Colors.grey[600],
                          ),
                          const material.SizedBox(width: 8),
                          material.Text(
                            'Tidak terhubung',
                            style: material.TextStyle(
                              color: material.Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const material.SizedBox(height: 16),

                  // Scan Button
                  material.SizedBox(
                    width: double.infinity,
                    child: OurbitButton.primary(
                      onPressed: _scanning ? null : _refreshDevices,
                      label: _scanning ? 'Mencari...' : 'Cari Perangkat',
                    ),
                  ),

                  const material.SizedBox(height: 16),

                  // Device List
                  if (_devices.isNotEmpty) ...[
                    material.Text(
                      'Perangkat Tersedia',
                      style: material.Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: material.FontWeight.w600),
                    ),
                    const material.SizedBox(height: 8),
                    ...(_devices.map((device) => material.ListTile(
                          title: material.Text(device.name ?? 'Unknown'),
                          subtitle: material.Text(device.address ?? ''),
                          trailing: material.IconButton(
                            icon: const material.Icon(material.Icons.bluetooth),
                            onPressed: () => _connect(device),
                          ),
                        ))),
                  ],
                ],
              ),
            ),
          ),

          const material.SizedBox(height: 16),

          // OS Printer Section
          material.Card(
            child: material.Padding(
              padding: const material.EdgeInsets.all(16),
              child: material.Column(
                crossAxisAlignment: material.CrossAxisAlignment.start,
                children: [
                  material.Text(
                    'Printer Sistem',
                    style: material.Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: material.FontWeight.w600),
                  ),
                  const material.SizedBox(height: 16),
                  if (_pickedOsPrinter != null) ...[
                    material.Container(
                      padding: const material.EdgeInsets.all(12),
                      decoration: material.BoxDecoration(
                        color: material.Colors.blue[50],
                        borderRadius: material.BorderRadius.circular(8),
                        border:
                            material.Border.all(color: material.Colors.blue),
                      ),
                      child: material.Row(
                        children: [
                          material.Icon(
                            material.Icons.print,
                            color: material.Colors.blue,
                          ),
                          const material.SizedBox(width: 8),
                          material.Expanded(
                            child: material.Text(
                              'Dipilih: ${_pickedOsPrinter!.name}',
                              style: material.TextStyle(
                                color: material.Colors.blue[700],
                                fontWeight: material.FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    material.Container(
                      padding: const material.EdgeInsets.all(12),
                      decoration: material.BoxDecoration(
                        color: material.Colors.grey[50],
                        borderRadius: material.BorderRadius.circular(8),
                        border:
                            material.Border.all(color: material.Colors.grey),
                      ),
                      child: material.Row(
                        children: [
                          material.Icon(
                            material.Icons.print_disabled,
                            color: material.Colors.grey[600],
                          ),
                          const material.SizedBox(width: 8),
                          material.Text(
                            'Belum ada printer dipilih',
                            style: material.TextStyle(
                              color: material.Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const material.SizedBox(height: 16),
                  material.SizedBox(
                    width: double.infinity,
                    child: OurbitButton.primary(
                      onPressed: _pickOsPrinter,
                      label: 'Pilih Printer',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const material.SizedBox(height: 16),

          // Test Print Button
          material.SizedBox(
            width: double.infinity,
            child: OurbitButton.primary(
              onPressed: _testPrint,
              label: 'Test Print',
            ),
          ),
        ],
      ),
    );
  }
}
