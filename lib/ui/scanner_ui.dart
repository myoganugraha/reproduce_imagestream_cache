import 'package:barcode_ml_scanner/bloc/scanner/scanner_bloc.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late ScannerBloc scannerBloc;

  @override
  void initState() {
    scannerBloc = ScannerBloc()..add(ScannerInitialize());
    super.initState();
  }

  @override
  void dispose() {
    scannerBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => scannerBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Scanner'),
        ),
        body: BlocConsumer<ScannerBloc, ScannerState>(
          bloc: scannerBloc,
          listener: (_, state) {
            print(state.toString());
            if (state is ScannerReadyState) {
              Future.delayed(const Duration(seconds: 1), () {
                scannerBloc.add(DoScan());
              });
            }
            if (state is ScanResultState) {
              print(state.result);
              Navigator.pop(context);
            }
          },
          builder: (_, state) {
            print(state.toString());
            return Container(
              child: state.controller == null
                  ? Container()
                  : Center(child: CameraPreview(state.controller!)),
            );
          },
        ),
      ),
    );
  }
}
