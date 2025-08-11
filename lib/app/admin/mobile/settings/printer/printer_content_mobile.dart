import 'package:flutter/material.dart' as material;
// Bluetooth printing temporarily disabled while migrating plugin
// import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:printing/printing.dart';

class PrinterContentMobile extends material.StatefulWidget {
  const PrinterContentMobile({super.key});

  @override
  material.State<PrinterContentMobile> createState() =>
      _PrinterContentMobileState();
}

class _PrinterContentMobileState extends material.State<PrinterContentMobile>
    with material.TickerProviderStateMixin {
  // Placeholder types until migration completes
  List<dynamic> _devices = const [];
  dynamic _connected;
  bool _scanning = false;
  Printer? _pickedOsPrinter;

  // Animation controllers
  late material.AnimationController _connectionController;
  late material.AnimationController _osPrinterController;
  late material.AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _initAnimationControllers();
    _init();
  }

  void _initAnimationControllers() {
    _connectionController = material.AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _osPrinterController = material.AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scanController = material.AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _connectionController.dispose();
    _osPrinterController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    // Skip bluetooth init for now
  }

  Future<void> _refreshDevices() async {
    setState(() {
      _devices = const [];
      _scanning = true;
    });

    _scanController.forward();

    // Simulate scanning delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _scanning = false;
      });
      _scanController.reverse();
    }
  }

  Future<void> _pickOsPrinter() async {
    try {
      final printer = await Printing.pickPrinter(context: context);
      if (printer != null) {
        setState(() => _pickedOsPrinter = printer);
        _osPrinterController.forward();
        material.ScaffoldMessenger.of(context).showSnackBar(
          const material.SnackBar(
            content: material.Text('Printer OS dipilih'),
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

  Future<void> _connect(dynamic device) async {
    // Disabled for now
  }

  Future<void> _disconnect() async {
    _connectionController.reverse().then((_) {
      setState(() => _connected = null);
    });
  }

  Future<void> _testPrint() async {
    try {
      material.ScaffoldMessenger.of(context).showSnackBar(
        const material.SnackBar(
          content: material.Text('Cetak Bluetooth sementara dinonaktifkan'),
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

  material.Widget _buildConnectionStatus() {
    return material.AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: _connected != null
          ? material.CrossFadeState.showFirst
          : material.CrossFadeState.showSecond,
      firstChild: material.Container(
        padding: const material.EdgeInsets.all(12),
        decoration: material.BoxDecoration(
          color: material.Colors.green[50],
          borderRadius: material.BorderRadius.circular(8),
          border: material.Border.all(color: material.Colors.green),
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
      secondChild: material.Container(
        padding: const material.EdgeInsets.all(12),
        decoration: material.BoxDecoration(
          color: material.Colors.grey[50],
          borderRadius: material.BorderRadius.circular(8),
          border: material.Border.all(color: material.Colors.grey),
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
    );
  }

  material.Widget _buildOsPrinterStatus() {
    return material.AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _pickedOsPrinter != null ? 1.0 : 0.0,
      child: material.AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _pickedOsPrinter != null ? null : 0,
        child: _pickedOsPrinter != null
            ? material.Container(
                padding: const material.EdgeInsets.all(12),
                decoration: material.BoxDecoration(
                  color: material.Colors.blue[50],
                  borderRadius: material.BorderRadius.circular(8),
                  border: material.Border.all(color: material.Colors.blue),
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
              )
            : material.Container(
                padding: const material.EdgeInsets.all(12),
                decoration: material.BoxDecoration(
                  color: material.Colors.grey[50],
                  borderRadius: material.BorderRadius.circular(8),
                  border: material.Border.all(color: material.Colors.grey),
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
      ),
    );
  }

  material.Widget _buildScanButton() {
    return material.AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: material.SizedBox(
        key: material.ValueKey(_scanning),
        width: double.infinity,
        child: OurbitButton.primary(
          onPressed: _scanning ? null : _refreshDevices,
          label: _scanning ? 'Mencari...' : 'Cari Perangkat',
        ),
      ),
    );
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
                  _buildConnectionStatus(),

                  if (_connected != null) ...[
                    const material.SizedBox(height: 12),
                    material.SizedBox(
                      width: double.infinity,
                      child: OurbitButton.secondary(
                        onPressed: _disconnect,
                        label: 'Putuskan',
                      ),
                    ),
                  ],

                  const material.SizedBox(height: 16),

                  // Scan Button
                  _buildScanButton(),

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
                  _buildOsPrinterStatus(),
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
