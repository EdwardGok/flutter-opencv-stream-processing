import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:native_opencv/native_opencv.dart';

// Esta clase se usará como argumento para el método init, ya que no podemos acceder a los activos incluidos.
// de un Isolate debemos obtener el marcador png del hilo principal
class InitRequest {
  SendPort toMainThread;
  ByteData markerPng;
  InitRequest({required this.toMainThread, required this.markerPng});
}

// esta es la clase que el hilo principal enviará aquí solicitando invocar una función en ArucoDetector
class Request {
  // una identificación de correlación para que el hilo principal pueda hacer coincidir la respuesta con la solicitud
  int reqId;
  String method;
  dynamic params;
  Request({required this.reqId, required this.method, this.params});
}

// esta es la clase que se enviará como respuesta al hilo principal
class Response {
  int reqId;
  dynamic data;
  Response({required this.reqId, this.data});
}

// Este es el puerto que se usará para enviar datos al hilo principal
late SendPort _toMainThread;
late _ArucoDetector _detector;

void init(InitRequest initReq) {
  // Crear ArucoDetector
  _detector = _ArucoDetector(initReq.markerPng);

  // Guarde el puerto en el que enviaremos mensajes al hilo principal
  _toMainThread = initReq.toMainThread;

  // Crear un puerto en el que el hilo principal pueda enviarnos mensajes y escucharlo.
  ReceivePort fromMainThread = ReceivePort();
  fromMainThread.listen(_handleMessage);

  // Enviar al hilo principal el puerto en el que puede enviarnos mensajes
  _toMainThread.send(fromMainThread.sendPort);
}

void _handleMessage(data) {
  if (data is Request) {
    dynamic res;
    switch (data.method) {
      case 'detect':
        var image = data.params['image'] as CameraImage;
        var rotation = data.params['rotation'];
        res = _detector.detect(image, rotation);
        break;
      case 'destroy':
        _detector.destroy();
        break;
      default:
        log('Unknown method: ${data.method}');
    }

    _toMainThread.send(Response(reqId: data.reqId, data: res));
  }
}

class _ArucoDetector {
  NativeOpencv? _nativeOpencv;

  _ArucoDetector(ByteData markerPng) {
    init(markerPng);
  }

  init(ByteData markerPng) async {
    // Tenga en cuenta que el detector de inicio de C++ espera que el marcador esté en formato png
    final pngBytes = markerPng.buffer.asUint8List();

    // iniciar el detector
    _nativeOpencv = NativeOpencv();
    _nativeOpencv!.initDetector(pngBytes, 36);
  }

  Float32List? detect(CameraImage image, int rotation) {
    // asegúrese de que tengamos un detector
    if (_nativeOpencv == null) {
      return null;
    }

    // En Android, el formato de imagen es YUV y obtenemos un búfer por canal,
    // en iOS el formato es BGRA y obtenemos un único búfer para todos los canales.
    // Entonces, la variable yBuffer en Android será solo el canal Y, pero en iOS será
    // toda la imagen
    var planes = image.planes;
    var yBuffer = planes[0].bytes;

    Uint8List? uBuffer;
    Uint8List? vBuffer;

    if (Platform.isAndroid) {
      uBuffer = planes[1].bytes;
      vBuffer = planes[2].bytes;
    }

    var res = _nativeOpencv!.detect(image.width, image.height, rotation, yBuffer, uBuffer, vBuffer);
    return res;
  }

  destroy() {
    if (_nativeOpencv != null) {
      _nativeOpencv!.destroy();
      _nativeOpencv = null;
    }
  }
}
