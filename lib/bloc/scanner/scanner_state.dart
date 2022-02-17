part of 'scanner_bloc.dart';

@immutable
abstract class ScannerState {
  final CameraController? controller;
  final bool? hasDualCamera;
  final bool? isFlashOn;

  const ScannerState({
    this.controller,
    this.hasDualCamera = false,
    this.isFlashOn = false,
  });
}

class ScannerInitialState extends ScannerState {}

class ScannerReadyState extends ScannerState {
  @override
  final CameraController? controller;
  @override
  final bool? hasDualCamera;
  @override
  final bool? isFlashOn;

  const ScannerReadyState({
    @required this.controller,
    @required this.hasDualCamera,
    @required this.isFlashOn,
  }) : super(
          controller: controller,
          hasDualCamera: hasDualCamera,
          isFlashOn: isFlashOn,
        );
}

class ScanResultState extends ScannerState {
  final String result;

  const ScanResultState(this.result);
}
