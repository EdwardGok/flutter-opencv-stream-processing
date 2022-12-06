import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class DetectionsLayer extends StatelessWidget {
  const DetectionsLayer({Key? key, required this.arucos, this.Image}) : super(key: key);
  final List<double> arucos;
  final Image;
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ArucosPainter(arucos: arucos,Image: Image),
    );
  }
}
class ArucosPainter extends CustomPainter {
  ArucosPainter({required this.arucos,this.Image});
  // lista de coordenadas de aruco, cada aruco tiene 4 esquinas con x/y, total de 8 numeros por aruco
  final List<double> arucos;
  final Image;
  // pintura que usaremos para dibujar a arucos
  final _paint = Paint()
    ..strokeWidth = 2.0
    ..color = Colors.red
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {

    // Cada aruco son 8 números (4 esquinas * x,y) y las esquinas son a partir de
    // arriba a la izquierda en el sentido de las agujas del reloj
    if(arucos.isEmpty) {
      canvas.drawCircle(Offset.zero, 1, _paint);
      return;
    }
      final count = arucos.length ~/ 8;

      for (int i = 0; i < count; ++i) {
        // donde comienzan las coordenadas actuales de aruco
        int arucoIdx = i * 8;

        // Dibuja las 4 lineas del aruco
        for (int j = 0; j < 4; ++j) {
          // cada esquina tiene xey entonces saltamos en 2
          final corner1Idx = arucoIdx + j * 2;

          // dado que las esquinas son en el sentido de las agujas del reloj,
          // podemos tomar la siguiente esquina agregando 1 a j asegurándonos
          // de no desbordar al siguiente aruco, por lo tanto, el módulo 8, por
          // lo que cuando j = 3 la esquina 1 será la esquina inferior izquierda
          // y la esquina 2 será la arriba a la izquierda (como j=0)
          final corner2Idx = arucoIdx + ((j + 1) * 2) % 8;

          // Dibuja la línea entre las 2 esquinas.
          final from = Offset(arucos[corner1Idx], arucos[corner1Idx + 1]);
          final to = Offset(arucos[corner2Idx], arucos[corner2Idx + 1]);
          canvas.drawLine(from, to, _paint);
        }
        final center = Offset((arucos[0]), (arucos[1]));
        canvas.drawImage(Image, center, _paint);
      }
  }

  @override
  bool shouldRepaint(ArucosPainter oldDelegate) {
    //Verificamos si se cambió la matriz arucos, si es así debemos volver a pintar
    if (arucos.length != oldDelegate.arucos.length) {
      return true;
    }
    for (int i = 0; i < arucos.length; ++i) {
      if (arucos[i] != oldDelegate.arucos[i]) {
        return true;
      }
    }
    return false;
  }

}
