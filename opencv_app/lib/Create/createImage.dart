import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:opencv_app/SqlLite/sql.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:opencv_app/show/modelo.dart';
import 'package:permission_handler/permission_handler.dart';

import '../getX/modelosGet.dart';
import '../op.dart';
class Create extends StatefulWidget {
  const Create({Key? key}) : super(key: key);
  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> {
  Controller controller=Get.put(Controller());
  Uint8List? bytes;
  File? file;
  Future saveImage(Uint8List bytes) async{
    String Ar="";
    for(int f=1;f<=4;f++)
    {
      for(int c=1;c<=4;c++)
      {
        Ar=Ar+m[f][c].toString();
      }
    }
    if(await DB.getCod(Ar)){
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      final fileCache=File('${tempPath}/image.png');
      await Permission.storage.request();
      fileCache.writeAsBytes(bytes);
      File? cortada=await ImageCropper().cropImage(sourcePath: fileCache.path, aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0));
      if (cortada!=null)
      {
        setState(() {
          file=File('/storage/emulated/0/DCIM/Camera/${DateTime.now()}.png');
          file?.writeAsBytes(cortada.readAsBytesSync());
        });
      }
      final result = await ImageGallerySaver.saveFile(file!.path);
      modelo model=modelo(controller.getid(),file!.path,Ar,"87");
      DB.insert(model);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OpenCVApp()));
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aruco Guardado en el Dispositivo'))
      );
    }
    else
    {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aruco Repetido'))
      );
    }
  }
  List<List<int>> m=[ [1,1,1,1,1,1],
                      [1,0,0,0,0,1],
                      [1,0,0,0,0,1],
                      [1,0,0,0,0,1],
                      [1,0,0,0,0,1],
                      [1,1,1,1,1,1]];
  var vColor=[Colors.white,Colors.black];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: Text('Creador de Arucos'),
        backgroundColor: Colors.green.shade400,
      ),
      body: ListView(
          padding: EdgeInsets.all(16),
            children:[
            aruco(),
        ]
        ),
      floatingActionButton: FloatingActionButton(
          onPressed:() async {
            final controller = ScreenshotController();
            final bytes= await controller.captureFromWidget(aruco(),);
            setState(()=>this.bytes=bytes);
            saveImage(bytes);

          },
        child: Icon(Icons.photo_camera),
      ),
    );
  }
  Widget aruco()=>Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          nodo(0,0),
          nodo(0,0),
          nodo(0,0),
          nodo(0,0),
          nodo(0,0),
          nodo(0,0),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          nodo(0,0),
          nodo(1,1),
          nodo(1,2),
          nodo(1,3),
          nodo(1,4),
          nodo(0,0),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          nodo(0,0),
          nodo(2,1),
          nodo(2,2),
          nodo(2,3),
          nodo(2,4),
          nodo(0,0),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          nodo(0,0),
          nodo(3,1),
          nodo(3,2),
          nodo(3,3),
          nodo(3,4),
          nodo(0,0),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          nodo(0,0),
          nodo(4,1),
          nodo(4,2),
          nodo(4,3),
          nodo(4,4),
          nodo(0,0),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          nodo(0,0),
          nodo(0,0),
          nodo(0,0),
          nodo(0,0),
          nodo(0,0),
          nodo(0,0),
        ],
      ),
    ],
  );
  Widget nodo(f,c)
  {
    return Container(
      child: TextButton(
        onPressed: () {
          setState(() {
            if (f!=0 && c!=0)
            {
              if (m[f][c]==0)
              {
                m[f][c]=1;
              }
              else
              {
                m[f][c]=0;
              }
              //image_downloader: ^0.20.0
            }
          });
        },
        child: Text(''),
      ),
      height: 50,
      width: 50,
      decoration: BoxDecoration(
          color: vColor[m[f][c]]
      ),
    );
  }

}
