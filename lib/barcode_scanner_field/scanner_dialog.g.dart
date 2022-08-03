// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanner_dialog.dart';

// **************************************************************************
// FunctionalWidgetGenerator
// **************************************************************************

class ScannerDialog extends HookConsumerWidget {
  const ScannerDialog(
      {Key? key, required this.enableSmartScan, required this.onScan})
      : super(key: key);

  final bool enableSmartScan;

  final void Function(BarcodeResult) onScan;

  @override
  Widget build(BuildContext _context, WidgetRef _ref) =>
      _scannerDialog(_ref, enableSmartScan: enableSmartScan, onScan: onScan);
}

class _PreviewDialog extends StatelessWidget {
  const _PreviewDialog(
      {Key? key,
      required this.controller,
      required this.onPressedPicker,
      required this.onPressedFlash})
      : super(key: key);

  final Option<CameraController> controller;

  final void Function() onPressedPicker;

  final void Function() onPressedFlash;

  @override
  Widget build(BuildContext _context) => __previewDialog(_context,
      controller: controller,
      onPressedPicker: onPressedPicker,
      onPressedFlash: onPressedFlash);
}

class _CameraPreview extends StatelessWidget {
  const _CameraPreview({Key? key, required this.controller}) : super(key: key);

  final CameraController controller;

  @override
  Widget build(BuildContext _context) =>
      __cameraPreview(controller: controller);
}
