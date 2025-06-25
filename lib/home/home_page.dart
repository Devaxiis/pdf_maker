import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'model/machine_model.dart';

// 2) UI sahifasi
class ReportPage extends StatelessWidget {
  // Bu sizning ilovangiz ekrandagi ro‘yxat ob’yektlari
  final List<Machine> machines = List.generate(
    23,
    (i) => Machine(
      sku: 'SKU-${i + 1}',
      imageUrl:
          'https://images.unsplash.com/photo-1580274455191-1c62238fa333?q=80&w=764&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      weight: '${6 + (i % 3) * 2}kg',
    ),
  );

  ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mashinalar Hisoboti'),
        actions: [
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () => exportMachineReportPdf(context, machines),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          itemCount: machines.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4 ustun
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final m = machines[index];
            return Column(
              children: [
                Expanded(
                  child: Image.network(m.imageUrl, fit: BoxFit.contain),
                ),
                const SizedBox(height: 4),
                Text(m.weight, style: const TextStyle(fontSize: 12)),
                Text(m.sku, style: const TextStyle(fontSize: 8)),
              ],
            );
          },
        ),
      ),
    );
  }

Future<Uint8List> getImageBytes() async {
  final ByteData data = await rootBundle.load('assets/img.jpg');
  return data.buffer.asUint8List();
}
  // 4) PDF eksport funksiyasi
  Future<void> exportMachineReportPdf(
      BuildContext context, List<Machine> machines) async {
    try {
      final pdf = pw.Document();
       final img =await getImageBytes();
      // PDF yaratishdan oldin barcha rasmlarni parallel ravishda yuklab olamiz.
      // Bu jarayonni tezlashtiradi.
      final imageBytesList = await Future.wait(
        machines.map((m) => networkImage(m.imageUrl)),
      );

      // Yuklangan rasmlarni `pw.MemoryImage` ga o'tkazamiz.
      final images =
          imageBytesList.map((bytes) => pw.MemoryImage(img)).toList();

      // Qator va ustun sozlamalari sahifa kengligiga moslashadi
      final pageFormat = PdfPageFormat.a4;
      const margin = 16.0;
      final usableWidth = pageFormat.availableWidth - margin * 2;
      const columns = 4;
      const spacing = 8.0;
      final cellWidth = (usableWidth - spacing * (columns - 1)) / columns;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(margin),
          header: (ctx) => pw.Text(
            'Mashinalar Hisoboti',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          footer: (ctx) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Sahifa ${ctx.pageNumber}/${ctx.pagesCount}',
              style: const pw.TextStyle(fontSize: 8),
            ),
          ),
          build: (ctx) {
            return [
              pw.Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (var i = 0; i < machines.length; i++)
                    pw.Container(
                      width: cellWidth,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(4),
                      ),
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Column(
                        children: [
                          pw.SizedBox(
                            height: cellWidth, // kvadrat rasm katagi
                            child: pw.Image(images[i], fit: pw.BoxFit.contain),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(machines[i].weight,
                              style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(machines[i].sku,
                              style: const pw.TextStyle(fontSize: 8),
                              textAlign: pw.TextAlign.center),
                        ],
                      ),
                    ),
                ],
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF yaratishda xatolik yuz berdi: $e')),
      );
    }
  }
}
