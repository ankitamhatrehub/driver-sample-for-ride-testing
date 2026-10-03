import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';

/// Front camera with the face-frame overlay drawn on top.
/// A face held inside the frame is captured, then [onCaptured] runs.
class LiveFaceCamera extends StatefulWidget {
  const LiveFaceCamera({super.key, required this.onCaptured});

  final ValueChanged<XFile> onCaptured;

  @override
  State<LiveFaceCamera> createState() => _LiveFaceCameraState();
}

class _LiveFaceCameraState extends State<LiveFaceCamera> {
  static const _holdFrames = 6;

  CameraController? _controller;
  late final FaceDetector _detector;
  final _frameKey = GlobalKey();
  final _previewKey = GlobalKey();

  bool _ready = false;
  bool _detected = false;
  bool _capturing = false;
  bool _pending = false;
  bool _busy = false;
  int _frame = 0;
  int _inside = 0;
  int _captureToken = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        minFaceSize: 0.12,
      ),
    );
    _start();
  }

  Future<void> _start() async {
    try {
      final cameras = await availableCameras();
      final front = cameras.cast<CameraDescription?>().firstWhere(
            (camera) => camera?.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.isEmpty ? null : cameras.first,
          );
      if (front == null) {
        if (mounted) setState(() => _error = 'No camera found');
        return;
      }
      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );
      await controller.initialize();
      await controller.startImageStream(_onFrame);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _ready = true;
      });
    } catch (_) {
      if (mounted) setState(() => _error = 'Camera could not be opened');
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    _frame++;
    if (_busy || _capturing || _frame % 3 != 0) return;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final input = _inputImage(image, controller);
    if (input == null) return;

    _busy = true;
    var shouldCapture = false;
    try {
      final faces = await _detector.processImage(input);
      if (!mounted || _capturing) return;
      final upright = _uprightSize(image, input.metadata!.rotation);
      final inside = faces.any((face) => _faceInsideOval(face.boundingBox, upright));
      if (inside) {
        _inside++;
        if (!_detected && mounted) setState(() => _detected = true);
        if (_inside >= _holdFrames && !_pending) shouldCapture = true;
      } else {
        _inside = 0;
        _captureToken++;
        _pending = false;
        if (_detected && mounted) setState(() => _detected = false);
      }
    } catch (_) {
      _inside = 0;
    } finally {
      _busy = false;
    }
    if (shouldCapture) {
      _pending = true;
      await _capture();
    }
  }

  bool _faceInsideOval(Rect box, Size imageSize) {
    final previewBox = _previewKey.currentContext?.findRenderObject() as RenderBox?;
    final frameBox = _frameKey.currentContext?.findRenderObject() as RenderBox?;
    if (previewBox == null || frameBox == null || !previewBox.hasSize || !frameBox.hasSize) {
      return false;
    }
    final preview = previewBox.localToGlobal(Offset.zero) & previewBox.size;
    final frame = frameBox.localToGlobal(Offset.zero) & frameBox.size;
    final center = _mapPoint(box.center, imageSize, preview, mirror: true);
    final oval = Rect.fromCenter(
      center: frame.center,
      width: frame.width * 0.62,
      height: frame.height * 0.78,
    );
    final nx = (center.dx - oval.center.dx) / (oval.width / 2);
    final ny = (center.dy - oval.center.dy) / (oval.height / 2);
    final faceLargeEnough = box.width >= imageSize.width * 0.16;
    return nx * nx + ny * ny <= 1 && faceLargeEnough;
  }

  Offset _mapPoint(Offset point, Size imageSize, Rect preview, {required bool mirror}) {
    final scale = math.max(preview.width / imageSize.width, preview.height / imageSize.height);
    final fittedWidth = imageSize.width * scale;
    final fittedHeight = imageSize.height * scale;
    final dx = preview.left + (preview.width - fittedWidth) / 2;
    final dy = preview.top + (preview.height - fittedHeight) / 2;
    var x = point.dx * scale + dx;
    final y = point.dy * scale + dy;
    if (mirror) x = preview.left + preview.right - x;
    return Offset(x, y);
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _capturing) return;
    final token = ++_captureToken;
    if (mounted) setState(() => _detected = true);
    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted || token != _captureToken) {
      _pending = false;
      return;
    }
    _capturing = true;
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
      final shot = await controller.takePicture();
      if (!mounted) return;
      widget.onCaptured(shot);
    } catch (_) {
      _capturing = false;
      _pending = false;
      _inside = 0;
      if (mounted && controller.value.isInitialized && !controller.value.isStreamingImages) {
        await controller.startImageStream(_onFrame);
      }
    }
  }

  @override
  void dispose() {
    _captureToken++;
    final controller = _controller;
    _controller = null;
    controller?.dispose();
    _detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _detected ? AppColors.green600 : AppColors.error;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          KeyedSubtree(key: _previewKey, child: _preview()),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(context.w(24), context.h(28), context.w(24), context.h(24)),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(8)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(context.r(24)),
                      border: Border.all(color: const Color(0xFFE9D5FF)),
                    ),
                    child: Text(
                      AppStrings.faceInFrame,
                      style: AppTypography.regular.copyWith(fontSize: 13, color: const Color(0xFF6B21A8)),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    key: _frameKey,
                    width: context.w(260),
                    height: context.h(320),
                    child: CustomPaint(
                      painter: _FaceFramePainter(detected: _detected),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  SizedBox(height: context.h(20)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(8)),
                    decoration: BoxDecoration(
                      color: _detected ? const Color(0xFFF0FDF4) : Colors.white,
                      borderRadius: BorderRadius.circular(context.r(20)),
                      border: Border.all(color: _detected ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _detected ? Icons.check_circle : Icons.info,
                          color: statusColor,
                          size: context.w(16),
                        ),
                        SizedBox(width: context.w(6)),
                        Text(
                          _detected ? AppStrings.faceDetected : AppStrings.noFaceDetected,
                          style: AppTypography.bold.copyWith(fontSize: 13, height: 1.2, color: statusColor),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _preview() {
    final controller = _controller;
    if (_error != null) {
      return ColoredBox(
        color: Colors.black,
        child: Center(child: Text(_error!, style: const TextStyle(color: Colors.white))),
      );
    }
    if (!_ready || controller == null || !controller.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    final preview = controller.value.previewSize;
    if (preview == null) return CameraPreview(controller);
    return ClipRect(
      child: Transform.flip(
        flipX: true,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: preview.height,
            height: preview.width,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );
  }
}

InputImage? _inputImage(CameraImage image, CameraController controller) {
  final rotation = _rotation(controller);
  if (rotation == null || image.planes.isEmpty) return null;
  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  if (format == null) return null;
  if (Platform.isAndroid && format != InputImageFormat.nv21) return null;
  if (Platform.isIOS && format != InputImageFormat.bgra8888) return null;
  if (image.planes.length != 1) return null;
  final plane = image.planes.first;
  return InputImage.fromBytes(
    bytes: plane.bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: plane.bytesPerRow,
    ),
  );
}

InputImageRotation? _rotation(CameraController controller) {
  const turns = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };
  final camera = controller.description;
  if (Platform.isIOS) {
    return InputImageRotationValue.fromRawValue(camera.sensorOrientation);
  }
  final device = turns[controller.value.deviceOrientation];
  if (device == null) return null;
  final compensation = camera.lensDirection == CameraLensDirection.front
      ? (camera.sensorOrientation + device) % 360
      : (camera.sensorOrientation - device + 360) % 360;
  return InputImageRotationValue.fromRawValue(compensation);
}

Size _uprightSize(CameraImage image, InputImageRotation rotation) {
  final swap = rotation == InputImageRotation.rotation90deg || rotation == InputImageRotation.rotation270deg;
  return swap
      ? Size(image.height.toDouble(), image.width.toDouble())
      : Size(image.width.toDouble(), image.height.toDouble());
}

class _FaceFramePainter extends CustomPainter {
  const _FaceFramePainter({required this.detected});

  final bool detected;

  @override
  void paint(Canvas canvas, Size size) {
    final color = detected ? const Color(0xFF16A34A) : const Color(0xFFEF4444);
    final corner = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const length = 28.0;
    final w = size.width;
    final h = size.height;
    canvas.drawLine(Offset.zero, const Offset(length, 0), corner);
    canvas.drawLine(Offset.zero, const Offset(0, length), corner);
    canvas.drawLine(Offset(w, 0), Offset(w - length, 0), corner);
    canvas.drawLine(Offset(w, 0), Offset(w, length), corner);
    canvas.drawLine(Offset(0, h), Offset(length, h), corner);
    canvas.drawLine(Offset(0, h), Offset(0, h - length), corner);
    canvas.drawLine(Offset(w, h), Offset(w - length, h), corner);
    canvas.drawLine(Offset(w, h), Offset(w, h - length), corner);
  }

  @override
  bool shouldRepaint(covariant _FaceFramePainter oldDelegate) => oldDelegate.detected != detected;
}
