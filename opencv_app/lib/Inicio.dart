import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'op.dart';
class Inicio extends StatefulWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(),
            Text('Detector de Aruco',textAlign: TextAlign.center,style: GoogleFonts.nerkoOne(
              textStyle: TextStyle(fontSize: 50, color: Colors.white)
            )
            ),
            ElevatedButton(
              child: const Text('Empezar'),
              style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.grey)),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {return const OpenCVApp();}));
              },
            ),
          ],
        ),
      ),

    );
  }
}
