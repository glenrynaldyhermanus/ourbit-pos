import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class ReceiptPdfService {
  ReceiptPdfService._internal();
  static final ReceiptPdfService _instance = ReceiptPdfService._internal();
  static ReceiptPdfService get instance => _instance;

  Future<Uint8List> buildReceipt({
    required String title,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double total,
    String? footerNote,
  }) async {
    final doc = pw.Document();
    final pageTheme = await _buildPageTheme();

    doc.addPage(
      pw.Page(
        pageTheme: pageTheme,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(title,
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center),
              pw.SizedBox(height: 8),
              pw.Divider(),
              ...items.expand((item) {
                final String name = item['product']['name'] ?? '';
                final int qty = item['quantity'] ?? 0;
                final double price = (item['price'] ?? 0).toDouble();
                final double amount = price * qty;
                return [
                  pw.Text(name, style: const pw.TextStyle(fontSize: 10)),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('$qty x ${_formatCurrency(price)}',
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Text(_formatCurrency(amount),
                          style: pw.TextStyle(
                              fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                ];
              }),
              pw.Divider(),
              _row('Subtotal', _formatCurrency(subtotal)),
              _row('Pajak (11%)', _formatCurrency(tax)),
              pw.SizedBox(height: 4),
              _row('Total', _formatCurrency(total), isEmphasis: true),
              if (footerNote != null && footerNote.isNotEmpty) ...[
                pw.SizedBox(height: 12),
                pw.Text(footerNote, textAlign: pw.TextAlign.center),
              ],
              pw.SizedBox(height: 12),
              pw.Text('Terima kasih!', textAlign: pw.TextAlign.center),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  Future<void> printReceipt({
    required String title,
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double tax,
    required double total,
    String? footerNote,
  }) async {
    final bytes = await buildReceipt(
      title: title,
      items: items,
      subtotal: subtotal,
      tax: tax,
      total: total,
      footerNote: footerNote,
    );
    await Printing.layoutPdf(onLayout: (format) async => bytes);
  }

  String _formatCurrency(double amount) {
    final s = amount.toStringAsFixed(0);
    final re = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = s.replaceAllMapped(re, (m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  Future<pw.PageTheme> _buildPageTheme() async {
    return const pw.PageTheme(
      pageFormat: PdfPageFormat(58 * PdfPageFormat.mm, double.infinity,
          marginAll: 5 * PdfPageFormat.mm),
    );
  }

  pw.Widget _row(String left, String right, {bool isEmphasis = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(left, style: const pw.TextStyle(fontSize: 11)),
          pw.Text(
            right,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight:
                  isEmphasis ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
