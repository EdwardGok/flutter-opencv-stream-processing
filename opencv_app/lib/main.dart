import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_opencv/native_opencv.dart';
import 'package:opencv_app/Inicio.dart';
import 'package:opencv_app/detection/detection_page.dart';
import 'package:opencv_app/Create/createImage.dart';
import 'show/showArucos.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(OpenCVApp());
}
class OpenCVApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Inicio();
  }
}
