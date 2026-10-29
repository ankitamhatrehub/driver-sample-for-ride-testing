import 'dart:io';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

/// Builds the earnings statement PDF and saves it to the device's Downloads
/// folder (Android 10+ needs no permission). Where that isn't possible (iOS,
/// older Android without storage permission) the share sheet opens so the
/// file can be saved from there.
///
/// The PDF's built-in font has no rupee glyph, so amounts use "Rs".
Future<void> downloadEarningsStatementPdf(
  BuildContext context, {
  required String driverName,
  required String phone,
  required String periodLabel,
  required List<MapEntry<String, double>> summary,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  String money(double v) => 'Rs ${v.toStringAsFixed(2)}';

  try {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Text('TORKK DRIVER EARNINGS STATEMENT', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          pw.Text('Driver: ${driverName.isEmpty ? 'Driver Partner' : driverName}'),
          pw.Text('Phone: $phone'),
          pw.Text('Period: $periodLabel'),
          pw.Text('Generated: ${DateTime.now().toString().split('.').first}'),
          pw.SizedBox(height: 16),
          pw.Text('Summary', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.TableHelper.fromTextArray(
            headers: ['Item', 'Amount'],
            data: [for (final e in summary) [e.key, money(e.value)]],
            cellAlignments: {1: pw.Alignment.centerRight},
          ),
        ],
      ),
    );
    final bytes = Uint8List.fromList(await doc.save());
    final name = 'TORKK_Statement_${phone.isEmpty ? 'Driver' : phone}_${DateTime.now().millisecondsSinceEpoch}';

    try {
      await FileSaver.instance.saveToDownloads(
        name: name,
        bytes: bytes,
        fileExtension: 'pdf',
        mimeType: MimeType.pdf,
      );
      messenger.showSnackBar(const SnackBar(content: Text('Statement saved to Downloads')));
    } catch (e) {
      debugPrint('Saving to Downloads failed ($e), opening share sheet');
      final dir = await getApplicationDocumentsDirectory();
      final file = await File('${dir.path}/$name.pdf').writeAsBytes(bytes);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'TORKK Driver Earnings Statement'),
      );
    }
  } catch (e) {
    debugPrint('Error generating statement PDF: $e');
    messenger.showSnackBar(
      const SnackBar(content: Text('Could not generate the statement'), backgroundColor: Colors.red),
    );
  }
}
