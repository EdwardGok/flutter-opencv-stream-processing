import 'dart:developer';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:opencv_app/detection/detections_layer.dart';
import 'package:opencv_app/detector/aruco_detector_async.dart';

class DetectionPage extends StatefulWidget {
  const DetectionPage({Key? key}) : super(key: key);

  @override
  _DetectionPageState createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> with WidgetsBindingObserver {
  CameraController? _camController;
  late ArucoDetectorAsync _arucoDetector;
  int _camFrameRotation = 0;
  double _camFrameToScreenScale = 0;
  int _lastRun = 0;
  bool _detectionInProgress = false;
  List<double> _arucos = List.empty();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _arucoDetector = ArucoDetectorAsync();
    initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _camController;

    // El estado de la aplicación cambió antes de que tuviéramos la
    // oportunidad de inicializar.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _arucoDetector.destroy();
    _camController?.dispose();
    super.dispose();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    var idx = cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
    if (idx < 0) {
      log("No se encontró cámara trasera - raro");
      return;
    }

    var desc = cameras[idx];
    _camFrameRotation = Platform.isAndroid ? desc.sensorOrientation : 0;
    _camController = CameraController(
      desc,
      ResolutionPreset.high, // 720p
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : ImageFormatGroup.bgra8888,
    );

    try {
      await _camController!.initialize();
      await _camController!.startImageStream((image) => _processCameraImage(image));
    } catch (e) {
      log("Error al inicializar la cámara, error: ${e.toString()}");
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _processCameraImage(CameraImage image) async {
    if (_detectionInProgress || !mounted || DateTime.now().millisecondsSinceEpoch - _lastRun < 30) {
      return;
    }

    // calcule el factor de escala para convertir de coordenadas
    // de cuadro de cámara a coordenadas de pantalla.
    // ¡¡¡¡NOTA!!!! Suponemos que el marco de la cámara ocupa
    // todo el ancho de la pantalla, si ese no es el caso
    // (como si la cámara es horizontal o el marco de la cámara
    // está limitado a un área), entonces
    // tiene que encontrar el factor de escala correcto de alguna otra
    // manera
    if (_camFrameToScreenScale == 0) {
      var w = (_camFrameRotation == 0 || _camFrameRotation == 180) ? image.width : image.height;
      _camFrameToScreenScale = MediaQuery.of(context).size.width / w;
    }

    // llama al detector
    _detectionInProgress = true;
    var res = await _arucoDetector.detect(image, _camFrameRotation);
    _detectionInProgress = false;
    _lastRun = DateTime.now().millisecondsSinceEpoch;

    // Asegúrese de que todavía estamos montados, el subproceso de
    // fondo puede devolver una respuesta después de que naveguemos
    // fuera de este pantalla pero antes de que se elimine el
    // subproceso bg
    if (!mounted || res == null || res.isEmpty) {
      return;
    }

    // Comprueba que el número de coordenadas que obtuvimos se divide
    // por 8 exactamente, cada aruco tiene 8 coordenadas (4 esquinas x/y)
    if ((res.length / 8) != (res.length ~/ 8)) {
      log('Obtuve una respuesta inválida de ArucoDetector, el número de coordenadas es ${res.length} y no representa arucos completos con 4 esquinas');
      return;
    }

    // convert arucos from camera frame coords to screen coords
    final arucos = res.map((x) => x * _camFrameToScreenScale).toList(growable: false);
    setState(() {
      _arucos = arucos;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_camController == null) {
      return const Center(
        child: Text('Loading...'),
      );
    }

    return Stack(
      children: [
        CameraPreview(_camController!),
        DetectionsLayer(
          arucos: _arucos,
        ),
      ],
    );
  }
}
