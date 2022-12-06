import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:opencv_app/detector/aruco_detector.dart' as aruco_detector;
import 'package:get/get.dart';
import 'package:opencv_app/getX/modelosGet.dart';
class ArucoDetectorAsync {
  Controller controllerg=Get.put(Controller());
  bool arThreadReady = false;
  late Isolate _detectorThread;
  late SendPort _toDetectorThread;
  int _reqId = 0;
  final Map<int, Completer> _cbs = {};

  ArucoDetectorAsync() {
    _initDetectionThread();
  }

  void _initDetectionThread() async {
    // Crea el puerto en el que el hilo detector nos enviará mensajes y escúchalo.
    ReceivePort fromDetectorThread = ReceivePort();
    fromDetectorThread.listen(_handleMessage, onDone: () {
      arThreadReady = false;
    });

    // Genera un nuevo Isolate utilizando el método ArucoDetector.init como punto de entrada y
    // el puerto en el que puede enviarnos mensajes como parámetro
    final bytes = await new File(controllerg.pat.toString()).readAsBytes();
    final initReq = aruco_detector.InitRequest(toMainThread: fromDetectorThread.sendPort, markerPng: bytes.buffer.asByteData());
    _detectorThread = await Isolate.spawn(aruco_detector.init, initReq);
  }

  Future<Float32List?> detect(CameraImage image, int rotation) {
    if (!arThreadReady) {
      return Future.value(null);
    }

    var reqId = ++_reqId;
    var res = Completer<Float32List?>();
    _cbs[reqId] = res;
    var msg = aruco_detector.Request(
      reqId: reqId,
      method: 'detect',
      params: {'image': image, 'rotation': rotation},
    );

    _toDetectorThread.send(msg);
    return res.future;
  }

  void destroy() async {
    if (!arThreadReady) {
      return;
    }

    arThreadReady = false;

    // We send a Destroy request and wait for a response before killing the thread
    var reqId = ++_reqId;
    var res = Completer();
    _cbs[reqId] = res;
    var msg = aruco_detector.Request(reqId: reqId, method: 'destroy');
    _toDetectorThread.send(msg);

    // Wait for the detector to acknoledge the destory and kill the thread
    await res.future;
    _detectorThread.kill();
  }

  void _handleMessage(data) {
    // The detector thread send us its SendPort on init, if we got it this meand the detector is ready
    if (data is SendPort) {
      _toDetectorThread = data;
      arThreadReady = true;
      return;
    }

    // Make sure we got a Response object
    if (data is aruco_detector.Response) {
      // Find the Completer associated with this request and resolve it
      var reqId = data.reqId;
      _cbs[reqId]?.complete(data.data);
      _cbs.remove(reqId);
      return;
    }

    log('Unknown message from ArucoDetector, got: $data');
  }
}
