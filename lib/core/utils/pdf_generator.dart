import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

class PdfGenerator {
  static Future<void> generateAndDownloadSessionSummaryPdf({required String sessionId, required String summaryContent}) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build:
            (context) => [
              pw.Header(
                level: 0,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Copyright Clinic', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                    pw.SizedBox(height: 5),
                    pw.Text('Session Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 3),
                    pw.Text('Session ID: $sessionId', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    pw.Divider(thickness: 2),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(summaryContent, style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5), textAlign: pw.TextAlign.justify),
            ],
        footer:
            (context) => pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 10),
              child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
            ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'session_summary_$sessionId.pdf');
  }

  static Future<File?> saveSessionSummaryPdf({required String sessionId, required String summaryContent}) async {
    try {
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build:
              (context) => [
                pw.Header(
                  level: 0,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Copyright Clinic', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
                      pw.SizedBox(height: 5),
                      pw.Text('Session Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 3),
                      pw.Text('Session ID: $sessionId', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                      pw.Divider(thickness: 2),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(summaryContent, style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5), textAlign: pw.TextAlign.justify),
              ],
          footer:
              (context) => pw.Container(
                alignment: pw.Alignment.centerRight,
                margin: const pw.EdgeInsets.only(top: 10),
                child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
              ),
        ),
      );

      final output = await getApplicationDocumentsDirectory();
      final file = File('${output.path}/session_summary_$sessionId.pdf');
      await file.writeAsBytes(await pdf.save());
      return file;
    } catch (e) {
      return null;
    }
  }
}
