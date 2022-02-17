part of 'scanner_bloc.dart';

@immutable
abstract class ScannerEvent extends Equatable {
  @override
  List<Object> get props => [runtimeType];
}

class ScannerInitialize extends ScannerEvent {}

class DoScan extends ScannerEvent {}

class ValidateResult extends ScannerEvent {
  final String data;

  ValidateResult(this.data);
}
