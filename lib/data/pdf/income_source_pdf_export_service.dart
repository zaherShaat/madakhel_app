// ignore_for_file: unused_import

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:madakhel_app/data/db/app_db.dart';
import 'package:madakhel_app/model/income_source_with_balance.dart';
import 'package:madakhel_app/model/transaction_direction.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class IncomeSourcePdfExportService {
  static const _folderName = 'Madakhel';
  static const _fontAsset = 'assets/fonts/NotoSansArabic.ttf';
  static const _storageChannel = MethodChannel('madakhel_app/document_storage');

  Future<String> saveIncomeSourceDetails({
    required IncomeSourceWithBalance source,
    required List<FinancialTransaction> transactions,
    required List<TransactionCategory> categories,
    required double inSum,
    required double outSum,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final fontData = await rootBundle.load(_fontAsset);
    final font = pw.Font.ttf(fontData.buffer.asByteData());
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: font, bold: font),
    );
    final categoryById = {
      for (final category in categories) category.id: category,
    };
    final exportedAt = DateTime.now();
    final balance = inSum - outSum;

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          theme: pw.ThemeData.withFont(base: font, bold: font),
          textDirection: pw.TextDirection.rtl,
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerLeft,
          child: pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
          ),
        ),
        build: (context) => [
          _header(source, exportedAt, startDate: startDate, endDate: endDate),
          pw.SizedBox(height: 18),
          pw.Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _statBox('الرصيد', _money(balance, source.currency)),
              _statBox('إجمالي الدخل', _money(inSum, source.currency)),
              _statBox('إجمالي المصروف', _money(outSum, source.currency)),
              _statBox('عدد المعاملات', transactions.length.toString()),
            ],
          ),
          pw.SizedBox(height: 22),
          pw.Text(
            'المعاملات',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 8),
          if (transactions.isEmpty)
            _emptyTransactions()
          else
            ...transactions.map(
              (transaction) => _transactionRow(
                transaction,
                source.currency,
                categoryById[transaction.categoryId],
              ),
            ),
        ],
      ),
    );

    final outputDir = await _madakhelDirectory();

    final fileName =
        'income_source_${_safeFilePart(source.name)}_${DateFormat('yyyyMMdd_HHmmss').format(exportedAt)}.pdf';
    final bytes = await pdf.save();

    final file = File(p.join(outputDir.path, fileName));
    final savedFile = await file.writeAsBytes(bytes);
    return savedFile.path;
  }

  Future<Directory> _madakhelDirectory() async {
    Directory? documentsDir;
    if (Platform.isIOS) {
      documentsDir = await getApplicationDocumentsDirectory();
    } else {
      documentsDir = Directory('/storage/emulated/0/Documents');
      // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
      // ignore: avoid_slow_async_io
      if (!await documentsDir.exists()) {
        documentsDir = await getExternalStorageDirectory();
      }
    }
    documentsDir = Directory('/storage/emulated/0/Documents');
    final madakhelDir = Directory(p.join(documentsDir.path, _folderName));
    await madakhelDir.create(recursive: true);

    return madakhelDir;
  }

  Future<void> openSavedPdf(String path) async {
    if (!Platform.isAndroid) return;
    // ignore: avoid_slow_async_io
    if (!await File(path).exists()) return;
    await _storageChannel.invokeMethod<void>('openDocument', {'path': path});
  }

  pw.Widget _header(
    IncomeSourceWithBalance source,
    DateTime exportedAt, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final rangeLabel = _dateRangeLabel(startDate, endDate);
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(18),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#0F766E'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(14)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Madakhel',
            textDirection: pw.TextDirection.ltr,
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            source.name,
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'تقرير تفاصيل مصدر الدخل - ${DateFormat('yyyy-MM-dd HH:mm').format(exportedAt)}',
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.white),
          ),
          if (rangeLabel != null) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              rangeLabel,
              textDirection: pw.TextDirection.ltr,
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.white),
            ),
          ],
        ],
      ),
    );
  }

  pw.Widget _statBox(String label, String value) {
    return pw.Container(
      width: 245,
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F3F7F5'),
        border: pw.Border.all(color: PdfColor.fromHex('#DDE7E4')),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            value,
            textDirection: pw.TextDirection.ltr,
            style: pw.TextStyle(
              fontSize: 15,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _transactionRow(
    FinancialTransaction transaction,
    String currency,
    TransactionCategory? category,
  ) {
    final isIncome = transaction.direction == TransactionDirection.inFlow;
    final directionLabel = isIncome ? 'دخل' : 'مصروف';
    final directionColor = isIncome
        ? PdfColor.fromHex('#0F766E')
        : PdfColor.fromHex('#B3242C');

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E2E7E5')),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  category?.name ?? transaction.note ?? 'معاملة',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  DateFormat('yyyy-MM-dd').format(transaction.date),
                  textDirection: pw.TextDirection.ltr,
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey700,
                  ),
                ),
                if (transaction.note != null &&
                    transaction.note!.trim().isNotEmpty) ...[
                  pw.SizedBox(height: 5),
                  pw.Text(
                    transaction.note!.trim(),
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                directionLabel,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: directionColor,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                _money(transaction.amount, currency),
                textDirection: pw.TextDirection.ltr,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: directionColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _emptyTransactions() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F3F7F5'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(10)),
      ),
      child: pw.Text(
        'لا توجد معاملات حتى الآن',
        style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
      ),
    );
  }

  String _money(double amount, String currency) {
    return '${amount.toStringAsFixed(2)} $currency';
  }

  String _safeFilePart(String value) {
    final sanitized = value
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
    if (sanitized.isEmpty) return 'source';
    return sanitized.length > 40 ? sanitized.substring(0, 40) : sanitized;
  }

  String? _dateRangeLabel(DateTime? startDate, DateTime? endDate) {
    if (startDate == null && endDate == null) return null;
    final formatter = DateFormat('yyyy-MM-dd');
    final start = startDate == null ? 'first' : formatter.format(startDate);
    final end = endDate == null ? 'latest' : formatter.format(endDate);
    return 'Range: $start - $end';
  }
}
