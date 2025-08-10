import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'package:ourbit_pos/src/core/services/theme_service.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_text_input.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_switch.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_button.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_radio_group.dart';
import 'package:ourbit_pos/src/widgets/ui/form/ourbit_radio_card.dart';

/// Ourbit SKU Generator
///
/// Widget untuk mengelola input SKU (kode produk) dengan opsi auto-generate sederhana.
/// - Menampilkan field SKU menggunakan OurbitTextInput
/// - Toggle "Auto SKU" untuk menghasilkan SKU dari nama produk
/// - Validasi dasar: minimal 3 karakter, karakter diizinkan [A-Z0-9-]
/// - Menyediakan callback perubahan nilai SKU dan status validasi
class OurbitSKUGenerator extends StatefulWidget {
  final String productName;
  final String? categoryId;
  final String? categoryName;
  final String? storeId;
  final String currentSKU;
  final bool disabled;
  final ValueChanged<String> onSKUChange;
  final void Function(bool isValid, String message)? onValidationChange;

  const OurbitSKUGenerator({
    super.key,
    required this.productName,
    required this.currentSKU,
    required this.onSKUChange,
    this.categoryId,
    this.categoryName,
    this.storeId,
    this.onValidationChange,
    this.disabled = false,
  });

  @override
  State<OurbitSKUGenerator> createState() => _OurbitSKUGeneratorState();
}

class _OurbitSKUGeneratorState extends State<OurbitSKUGenerator> {
  late TextEditingController _controller;
  bool _auto = false;
  String _validationMessage = '';
  bool _isValid = false;
  String _selectedPattern = 'category-sequential';
  String _customPrefix = 'PROD';
  String _customSuffix = '';
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentSKU);
    _validateAndNotify(widget.currentSKU);
  }

  @override
  void didUpdateWidget(covariant OurbitSKUGenerator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Regenerate ketika input sumber berubah
    if (_auto) {
      if (oldWidget.productName != widget.productName ||
          oldWidget.categoryId != widget.categoryId ||
          oldWidget.categoryName != widget.categoryName) {
        _generateSKU();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSKUChanged(String? value) {
    final text = value ?? '';
    _validateAndNotify(text);
    widget.onSKUChange(text);
  }

  void _validateAndNotify(String value) {
    final allowed = RegExp(r'^[A-Z0-9-]{0,}$');
    String message = '';
    bool ok = true;
    if (value.trim().isEmpty) {
      ok = false;
      message = '';
    } else if (value.trim().length < 3) {
      ok = false;
      message = 'Minimal 3 karakter';
    } else if (!allowed.hasMatch(value)) {
      ok = false;
      message = 'Hanya huruf/angka/dash (-)';
    }
    setState(() {
      _isValid = ok;
      _validationMessage = message;
    });
    widget.onValidationChange?.call(ok, message);
  }

  void _generateSKU() {
    final name = widget.productName.trim();
    if (_selectedPattern == 'name-based' && name.length < 3) return;

    String sequential = '001';
    String generated = '';

    String getCategoryCode(String? categoryName) {
      if (categoryName == null || categoryName.trim().isEmpty) return 'GEN';
      final words = categoryName.trim().split(RegExp(r'\s+'));
      if (words.length == 1) {
        return words[0].substring(0, words[0].length.clamp(0, 3)).toUpperCase();
      }
      return words
          .map((w) => w.isNotEmpty ? w[0] : '')
          .join()
          .substring(0, 3)
          .toUpperCase();
    }

    String getNameInitials(String productName) {
      if (productName.isEmpty) return 'PROD';
      final words = productName.trim().split(RegExp(r'\s+'));
      if (words.length == 1) {
        return words[0]
            .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
            .substring(0, words[0].length.clamp(0, 3))
            .toUpperCase();
      }
      return words
          .map((w) => w.isNotEmpty ? w[0] : '')
          .join()
          .substring(0, 3)
          .toUpperCase();
    }

    String formatDate() {
      final now = DateTime.now();
      final yy = (now.year % 100).toString().padLeft(2, '0');
      final mm = now.month.toString().padLeft(2, '0');
      final dd = now.day.toString().padLeft(2, '0');
      return '$yy$mm$dd';
    }

    switch (_selectedPattern) {
      case 'category-sequential':
        final code = getCategoryCode(widget.categoryName);
        generated = '$code-$sequential';
        break;
      case 'name-based':
        final initials = getNameInitials(name);
        generated = '$initials-$sequential';
        break;
      case 'date-based':
        final date = formatDate();
        generated = '$date-$sequential';
        break;
      case 'custom':
        final code = getCategoryCode(widget.categoryName);
        final prefix =
            _customPrefix.isEmpty ? 'PROD' : _customPrefix.toUpperCase();
        final suffix = _customSuffix.isEmpty ? '' : _customSuffix.toUpperCase();
        generated = suffix.isEmpty
            ? '$prefix-$code-$sequential'
            : '$prefix-$code-$sequential-$suffix';
        break;
      default:
        String prefix =
            name.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
        if (prefix.length > 6) prefix = prefix.substring(0, 6);
        generated = '$prefix-$sequential';
    }

    _controller.text = generated;
    _onSKUChanged(generated);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        final muted = Theme.of(context).colorScheme.mutedForeground;
        final success = Colors.green;
        final danger = Colors.red;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OurbitTextInput(
              placeholder: 'Kode Produk (SKU) — min. 3 karakter',
              controller: _controller,
              onChanged: _onSKUChanged,
              features: [
                if (_auto)
                  InputFeature.trailing(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.muted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('Auto',
                          style: TextStyle(color: muted, fontSize: 12)),
                    ),
                  ),
              ],
            ),
            const Gap(8),
            OurbitSwitchBuilder.withLabel(
              value: _auto,
              onChanged: (val) {
                if (widget.disabled) return;
                setState(() => _auto = val);
                if (val) _generateSKU();
              },
              label: 'Auto SKU',
            ),
            if (_auto) ...[
              const Gap(8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: OurbitRadioGroup<String>(
                      value: _selectedPattern,
                      onChanged: (val) {
                        setState(() => _selectedPattern = val);
                        _generateSKU();
                      },
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: const [
                            OurbitRadioCard<String>(
                              value: 'category-sequential',
                              child: Basic(
                                title: Text('Kategori + Sequential'),
                                content: Text(
                                    'Kode kategori + nomor urut (ELEC-001)'),
                              ),
                            ),
                            SizedBox(width: 8),
                            OurbitRadioCard<String>(
                              value: 'name-based',
                              child: Basic(
                                title: Text('Berdasarkan Nama'),
                                content:
                                    Text('Inisial nama + nomor urut (SU-001)'),
                              ),
                            ),
                            SizedBox(width: 8),
                            OurbitRadioCard<String>(
                              value: 'date-based',
                              child: Basic(
                                title: Text('Tanggal + Sequential'),
                                content:
                                    Text('YYMMDD + nomor urut (240101-001)'),
                              ),
                            ),
                            SizedBox(width: 8),
                            OurbitRadioCard<String>(
                              value: 'custom',
                              child: Basic(
                                title: Text('Kustom'),
                                content:
                                    Text('Prefix + kode kategori + nomor urut'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OurbitButton.outline(
                    onPressed: () {
                      setState(() => _isGenerating = true);
                      _generateSKU();
                      setState(() => _isGenerating = false);
                    },
                    label: _isGenerating ? 'Menghasilkan…' : 'Refresh',
                  ),
                ],
              ),
              if (_selectedPattern == 'custom') ...[
                const Gap(8),
                Row(
                  children: [
                    Expanded(
                      child: OurbitTextInput(
                        placeholder: 'Prefix (mis. PROD)',
                        onChanged: (v) {
                          setState(() => _customPrefix = (v ?? '').trim());
                          _generateSKU();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OurbitTextInput(
                        placeholder: 'Suffix (opsional, mis. 2024)',
                        onChanged: (v) {
                          setState(() => _customSuffix = (v ?? '').trim());
                          _generateSKU();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
            if (_validationMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(_isValid ? Icons.check_circle : Icons.error,
                        size: 16, color: _isValid ? success : danger),
                    const SizedBox(width: 6),
                    Text(
                      _validationMessage,
                      style: TextStyle(
                        color: _isValid ? success : danger,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
