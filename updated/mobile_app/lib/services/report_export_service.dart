// import 'file_saver_stub.dart'
//     if (dart.library.io) 'file_saver_mobile.dart'
//     if (dart.library.html) 'file_saver_web.dart';
// import 'dart:typed_data'; // Added for Uint8List safety
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:excel/excel.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:intl/intl.dart';

// // ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html if (dart.library.io) 'dart:io';

// import '../models/sale_model.dart'; // Import your Sale model

// class ReportExportService {
//   static final _dateFormatter = DateFormat('MMM_dd_yyyy_HHmm');
//   static final _displayDate = DateFormat('MMM dd, yyyy HH:mm');
//   static final _tableDate = DateFormat('MMM dd, HH:mm');

//   // ==========================================
//   //                PDF EXPORT
//   // ==========================================
//   static Future<void> exportToPdf({
//     required String period,
//     required double revenue,
//     required double costs,
//     required double profit,
//     required List<Sale> items, // Changed type to List<Sale>
//   }) async {
//     final pdf = pw.Document();
//     final now = DateTime.now();
//     final reportedDate = _displayDate.format(now);

//     pdf.addPage(
//       pw.MultiPage( // Use MultiPage to handle long lists of sales
//         pageFormat: PdfPageFormat.a4,
//         build: (context) => [
//           pw.Text('Inventory & P&L Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
//           pw.SizedBox(height: 5),
//           pw.Text('Report Period: $period'),
//           pw.Text('Reported Date: $reportedDate'),
//           pw.Divider(),
//           pw.SizedBox(height: 20),
          
//           pw.Text('Financial Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
//           pw.SizedBox(height: 10),
//           _pwRow('Total Revenue', 'ETB ${revenue.toStringAsFixed(2)}'),
//           _pwRow('Total Costs (COGS)', 'ETB ${costs.toStringAsFixed(2)}'),
//           pw.Divider(),
//           _pwRow('Net Profit', 'ETB ${profit.toStringAsFixed(2)}', isBold: true),
          
//           pw.SizedBox(height: 30),
//           pw.Text('Transactions Log', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
//           pw.SizedBox(height: 10),
//           pw.TableHelper.fromTextArray(
//             headers: ['Date', 'Sale #', 'Customer', 'Profit', 'Total'],
//             headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//             data: items.map((sale) => [
//               _tableDate.format(sale.createdAt),
//               sale.saleNumber,
//               sale.customerName,
//               'ETB ${sale.profit.toStringAsFixed(0)}',
//               'ETB ${sale.total.toStringAsFixed(0)}'
//             ]).toList(),
//           ),
//         ],
//       ),
//     );

//     final Uint8List bytes = await pdf.save();
//     final fileName = "Report_${period}_${_dateFormatter.format(now)}.pdf";

//     if (kIsWeb) {
//       _downloadWeb(bytes, fileName, 'application/pdf');
//     } else {
//       await _shareMobile(bytes, fileName);
//     }
//   }

//   // ==========================================
//   //               EXCEL EXPORT
//   // ==========================================
//   static Future<void> exportToExcel({
//     required String period,
//     required double revenue,
//     required double costs,
//     required double profit,
//     required List<Sale> items, // Changed type to List<Sale>
//   }) async {
//     var excel = Excel.createExcel();
//     Sheet sheet = excel['Report'];
//     final now = DateTime.now();
//     final reportedDate = _displayDate.format(now);

//     // Setup Header
//     sheet.appendRow([TextCellValue('BUSINESS P&L REPORT'), TextCellValue(period)]);
//     sheet.appendRow([TextCellValue('Reported Date:'), TextCellValue(reportedDate)]);
//     sheet.appendRow([]);
//     sheet.appendRow([TextCellValue('Metric'), TextCellValue('Value (ETB)')]);
//     sheet.appendRow([TextCellValue('Total Revenue'), DoubleCellValue(revenue)]);
//     sheet.appendRow([TextCellValue('Total Costs'), DoubleCellValue(costs)]);
//     sheet.appendRow([TextCellValue('Net Profit'), DoubleCellValue(profit)]);
//     sheet.appendRow([]);
    
//     // Table Headers
//     sheet.appendRow([
//       TextCellValue('Date'), 
//       TextCellValue('Sale Number'), 
//       TextCellValue('Customer'), 
//       TextCellValue('Cost'),
//       TextCellValue('Revenue'),
//       TextCellValue('Profit')
//     ]);

//     // Data Rows
//     for (var sale in items) {
//       sheet.appendRow([
//         TextCellValue(_displayDate.format(sale.createdAt)),
//         TextCellValue(sale.saleNumber),
//         TextCellValue(sale.customerName),
//         DoubleCellValue(sale.totalCost),
//         DoubleCellValue(sale.total),
//         DoubleCellValue(sale.profit),
//       ]);
//     }

//     final bytes = excel.save();
//     if (bytes == null) return;
//     final fileName = "Report_${period}_${_dateFormatter.format(now)}.xlsx";

//     if (kIsWeb) {
//       _downloadWeb(Uint8List.fromList(bytes), fileName, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
//     } else {
//       await _shareMobile(Uint8List.fromList(bytes), fileName);
//     }
//   }

//   // ==========================================
//   //           PLATFORM HELPERS
//   // ==========================================

//   static void _downloadWeb(Uint8List bytes, String fileName, String type) {
//     final blob = html.Blob([bytes], type);
//     final url = html.Url.createObjectUrlFromBlob(blob);
//     final anchor = html.AnchorElement(href: url)
//       ..setAttribute("download", fileName)
//       ..click();
//     html.Url.revokeObjectUrl(url);
//   }

//   static Future<void> _shareMobile(Uint8List bytes, String fileName) async {
//     final directory = await getTemporaryDirectory();
//     final file = File('${directory.path}/$fileName');
//     await file.writeAsBytes(bytes);
//     await Share.shareXFiles([XFile(file.path)], text: 'Financial Report');
//   }

//   static pw.Widget _pwRow(String label, String value, {bool isBold = false}) {
//     return pw.Padding(
//       padding: const pw.EdgeInsets.symmetric(vertical: 2),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
//           pw.Text(value, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
//         ],
//       ),
//     );
//   }
// }

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';

import 'file_saver_stub.dart' 
    if (dart.library.io) 'file_saver_mobile.dart' 
    if (dart.library.html) 'file_saver_web.dart';

import '../models/sale_model.dart';

class ReportExportService {
  static final _dateFormatter = DateFormat('MMM_dd_yyyy_HHmm');
  static final _displayDate = DateFormat('MMM dd, yyyy HH:mm');
  static final _tableDate = DateFormat('MMM dd, HH:mm');

  static Future<void> exportToPdf({
    required String period,
    required double revenue,
    required double costs,
    required double profit,
    required List<Sale> items,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final reportedDate = _displayDate.format(now);
    pdf.addPage(pw.MultiPage(build: (context) => [ 
                pw.Text('Inventory & P&L Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('Report Period: $period'),
                pw.Text('Reported Date: $reportedDate'),
                pw.Divider(),
                pw.SizedBox(height: 20),
                
                pw.Text('Financial Summary', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                _pwRow('Total Revenue', 'ETB ${revenue.toStringAsFixed(2)}'),
                _pwRow('Total Costs (COGS)', 'ETB ${costs.toStringAsFixed(2)}'),
                pw.Divider(),
                _pwRow('Net Profit', 'ETB ${profit.toStringAsFixed(2)}', isBold: true),
                
                pw.SizedBox(height: 30),
                pw.Text('Transactions Log', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 10),
                pw.TableHelper.fromTextArray(
                  headers: ['Date', 'Sale #', 'Customer', 'Profit', 'Total'],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  data: items.map((sale) => [
                    _tableDate.format(sale.createdAt),
                    sale.saleNumber,
                    sale.customerName,
                    'ETB ${sale.profit.toStringAsFixed(0)}',
                    'ETB ${sale.total.toStringAsFixed(0)}'
                  ]).toList(),
                ),
            ]));

    final Uint8List bytes = await pdf.save();
    final fileName = "Report_${period}_${_dateFormatter.format(DateTime.now())}.pdf";

    await saveAndLaunchFile(bytes, fileName);
  }

  static Future<void> exportToExcel({
    required String period,
    required double revenue,
    required double costs,
    required double profit,
    required List<Sale> items,
  }) async {
    var excel = Excel.createExcel();

    final bytes = excel.save();
    if (bytes == null) return;
    final fileName = "Report_${period}_${_dateFormatter.format(DateTime.now())}.xlsx";

    await saveAndLaunchFile(Uint8List.fromList(bytes), fileName);
  }

  static pw.Widget _pwRow(String label, String value, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          pw.Text(value, style: pw.TextStyle(fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
        ],
      ),
    );
  }
}