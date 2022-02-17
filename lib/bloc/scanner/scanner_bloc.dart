import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:meta/meta.dart';

part 'scanner_event.dart';
part 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final _qrDetector = GoogleVision.instance.barcodeDetector();
  bool _alreadyCheckingStreamImage = false;

  List<CameraDescription>? cameras;

  @override
  Future<void> close() {
    _qrDetector.close();
    state.controller?.dispose();
    return super.close();
  }

  ScannerBloc() : super(ScannerInitialState()) {
    on<ScannerInitialize>(_scannerInitialize);
    on<DoScan>(_handleQRScan);
    on<ValidateResult>(_validateResult);
  }

  void _scannerInitialize(
    ScannerInitialize event,
    Emitter<ScannerState> emit,
  ) async {
    cameras = await availableCameras();
    await state.controller?.dispose();

    final _controller = CameraController(
      cameras!.first,
      ResolutionPreset.max,
      enableAudio: false,
    );

    await _controller.initialize();
    await _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);

    emit(ScannerReadyState(
      controller: _controller,
      hasDualCamera: cameras!.length > 1,
      isFlashOn: false,
    ));
  }

  void _handleQRScan(
    DoScan event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      await state.controller?.startImageStream((image) {
        if (_alreadyCheckingStreamImage) {
          return;
        }
        _alreadyCheckingStreamImage = true;

        final gvQRImage = GoogleVisionImage.fromBytes(
          _concatenatePlanes(image.planes),
          _buildMetaData(
            image,
            _rotationIntToImageRotation(
              state.controller?.description.sensorOrientation,
            ),
          ),
        );
        _mlKitScanner(
          gvQRImage,
        );
      });
    } catch (e) {
      print(e.toString());
      emit(ScanResultState(e.toString()));
    }
  }

  void _validateResult(
    ValidateResult event,
    Emitter<ScannerState> emit,
  ) async {
    if (event.data.isNotEmpty) {
      emit(ScanResultState(event.data));
    }
  }

  Future<void> _mlKitScanner(GoogleVisionImage imageToExtract) async {
    String? qrData;

    final List<Barcode>? result =
        await _qrDetector.detectInImage(imageToExtract);

    if (result != null && result.isNotEmpty) {
      await state.controller?.stopImageStream();
      qrData = _extractStringFromQR(result);

      add(ValidateResult(qrData));
    }

    _alreadyCheckingStreamImage = false;
  }

  static Uint8List _concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  static GoogleVisionImageMetadata _buildMetaData(
    CameraImage image,
    ImageRotation rotation,
  ) {
    return GoogleVisionImageMetadata(
      rawFormat: image.format.raw,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      planeData: image.planes.map(
        (Plane plane) {
          return GoogleVisionImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );
  }

  static String _extractStringFromQR(List<Barcode> barcodes) {
    String? qrData;
    for (final barcode in barcodes) {
      qrData = barcode.rawValue;
    }
    return qrData!;
  }

  static ImageRotation _rotationIntToImageRotation(int? rotation) {
    switch (rotation) {
      case 0:
        return ImageRotation.rotation0;
      case 90:
        return ImageRotation.rotation90;
      case 180:
        return ImageRotation.rotation180;
      default:
        return ImageRotation.rotation270;
    }
  }
}
