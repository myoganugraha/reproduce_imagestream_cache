import 'package:barcode_ml_scanner/bloc/scanner/scanner_bloc.dart';
import 'package:barcode_ml_scanner/ui/home_ui.dart';
import 'package:barcode_ml_scanner/ui/scanner_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/scanner': (_) => const ScannerScreen(),
      },
    );
  }
}
