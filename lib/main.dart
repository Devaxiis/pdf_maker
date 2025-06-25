import 'package:flutter/material.dart';
import 'package:pdf_makerapp/home/home_page.dart';
import 'package:pdf_makerapp/home/widget/printer_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ReportPage2(),
    );
  }
}

