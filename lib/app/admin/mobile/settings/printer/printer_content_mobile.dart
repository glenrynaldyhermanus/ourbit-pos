import 'package:ourbit_pos/src/core/theme/app_theme.dart';
// Bluetooth printing temporarily disabled while migrating plugin
// import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:printing/printing.dart';
import 'package:ourbit_pos/src/widgets/ui/layout/ourbit_card.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/material.dart' as material;

class PrinterContentMobile extends StatefulWidget {
  const PrinterContentMobile({super.key});

  @override
  State<PrinterContentMobile> createState() => _PrinterContentMobileState();
}

class _PrinterContentMobileState extends State<PrinterContentMobile>
    with TickerProviderStateMixin {
  // Placeholder types until migration completes
  List<dynamic> _devices = const [];
  dynamic _connected;
  bool _scanning = false;
  Printer? _pickedOsPrinter;

  // Animation controllers
  late AnimationController _connectionController;
  late AnimationController _osPrinterController;
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _initAnimationControllers();
    _init();
  }

  void _initAnimationControllers() {
    _connectionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _osPrinterController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scanController = AnimationController(
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
            content: Text('Printer OS dipilih'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: Text('Gagal memilih printer OS: $e'),
          backgroundColor: Colors.red,
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
          content: Text('Cetak Bluetooth sementara dinonaktifkan'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(
          content: Text('Gagal test print: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildConnectionStatus() {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 300),
      crossFadeState: _connected != null
          ? CrossFadeState.showFirst
          : CrossFadeState.showSecond,
      firstChild: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green),
        ),
        child: Row(
          children: [
            Icon(
              Icons.bluetooth_connected,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Terhubung ke: ${_connected?.name ?? 'Perangkat'}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      secondChild: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.gray[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.gray),
        ),
        child: Row(
          children: [
            Icon(
              Icons.bluetooth_disabled,
              color: Colors.gray[600],
            ),
            const SizedBox(width: 8),
            Text(
              'Tidak terhubung',
              style: TextStyle(
                color: Colors.gray[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOsPrinterStatus() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _pickedOsPrinter != null ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: _pickedOsPrinter != null ? null : 0,
        child: _pickedOsPrinter != null
            ? Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.print,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Dipilih: ${_pickedOsPrinter!.name}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.gray[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.gray),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.print_disabled,
                      color: Colors.gray[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Belum ada printer dipilih',
                      style: TextStyle(
                        color: Colors.gray[600],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildScanButton() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        key: ValueKey(_scanning),
        width: double.infinity,
        child: OurbitButton.primary(
          onPressed: _scanning ? null : _refreshDevices,
          label: _scanning ? 'Mencari...' : 'Cari Perangkat',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Pengaturan Printer',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == material.Brightness.dark
                  ? AppColors.darkPrimaryText
                  : AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kelola printer untuk cetak struk dan laporan',
            style: TextStyle(
              color: Theme.of(context).brightness == material.Brightness.dark
                  ? AppColors.darkSecondaryText
                  : AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 24),

          // Bluetooth Printer Section
          OurbitCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Printer Bluetooth',
                    style: material.Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  // Connection Status
                  _buildConnectionStatus(),

                  if (_connected != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OurbitButton.secondary(
                        onPressed: _disconnect,
                        label: 'Putuskan',
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Scan Button
                  _buildScanButton(),

                  const SizedBox(height: 16),

                  // Device List
                  if (_devices.isNotEmpty) ...[
                    Text(
                      'Perangkat Tersedia',
                      style: material.Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...(_devices.map((device) => material.ListTile(
                          title: Text(device.name ?? 'Unknown'),
                          subtitle: Text(device.address ?? ''),
                          trailing: material.IconButton(
                            icon: const Icon(Icons.bluetooth),
                            onPressed: () => _connect(device),
                          ),
                        ))),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // OS Printer Section
          OurbitCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Printer Sistem',
                    style: material.Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _buildOsPrinterStatus(),
                  const SizedBox(height: 16),
                  SizedBox(
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

          const SizedBox(height: 16),

          // Test Print Button
          SizedBox(
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
