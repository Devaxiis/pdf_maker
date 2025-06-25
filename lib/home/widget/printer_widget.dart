import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:photo_view/photo_view.dart';

import 'package:printing/printing.dart';
import 'package:zoom_widget/zoom_widget.dart';


class ReportPage2 extends StatefulWidget {
  const ReportPage2({super.key});

  @override
  _ReportPage2State createState() => _ReportPage2State();
}

class _ReportPage2State extends State<ReportPage2> {
  final GlobalKey _captureKey = GlobalKey();
  double scale = 1.0;

  Future<Uint8List> _captureWidget() async {
    final boundary =
        _captureKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    // Pixel ratio – yuqori rezolyutsiya uchun
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _exportPdf() async {
    final pngBytes = await _captureWidget();
    final pdf = pw.Document();
    final pwImage = pw.MemoryImage(pngBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (ctx) {
          return pw.Center(child: pw.Image(pwImage));
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hisobot')),
      body: SingleChildScrollView(
        child: RepaintBoundary(
          key: _captureKey,
          child: Column(
            children: [
              // Bu yerga PDF ga kiritmoqchi bo‘lgan butun UI elementlarini joylang:
              Text('Sarlavha', style: TextStyle(fontSize: 24)),
              // ... ro‘yxatlar, grafikalar, jadvallar va h.k.

              
                 SizedBox(
                  height: 200,
                  width: 400,
                   child: Zoom(
                    maxScale: 100,
                    initScale: 15,
                    onMinZoom: (context){
                      
                    },
                     child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ...List.generate(20, (i){
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 20,
                              width: 100,
                              color: Colors.amberAccent,
                              alignment: Alignment(0, 0),
                              padding: EdgeInsets.all(12),
                              child: Text('Salom $i')),
                          );
                        })
                      ],
                                     ),
                   ),
                 ),
              
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.picture_as_pdf),
        onPressed: (){
          _exportPdf();
          },
      ),
    );
  }
}
