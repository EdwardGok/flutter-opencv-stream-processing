import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:native_opencv/native_opencv.dart';
import 'package:opencv_app/SqlLite/sql.dart';
import 'package:opencv_app/detection/detection_page.dart';
import 'package:opencv_app/Create/createImage.dart';
import 'package:opencv_app/show/AsignarAruco.dart';
import 'package:opencv_app/show/modelo.dart';
import 'package:sqflite/sqflite.dart';
import 'getX/modelosGet.dart';
import 'SqlLite/sql.dart';
class OpenCVApp extends StatefulWidget {
  const OpenCVApp({Key? key}) : super(key: key);

  @override
  State<OpenCVApp> createState() => _OpenCVAppState();
}

class _OpenCVAppState extends State<OpenCVApp> {
  List<modelo> model=[];
  Controller controller=Get.put(Controller());
  @override
  void initState() {
    cargaModelo();
    obtenerid();
    super.initState();
  }
  Future cargaModelo() async{
    List<modelo> auxModelo= await DB.modelosCompletos();
    setState(() {
      model=auxModelo;
    });
  }
  Future obtenerid() async{
    List<modelo> auxModelo= await DB.modelos();
    controller.setId(auxModelo[auxModelo.length-1].id+1);
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Menú'),
        backgroundColor: Colors.green.shade400,
      ),
      body: Container(
        color: Colors.green,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 200,
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: model.length,
                        itemBuilder:(context, index) {
                        return Card(
                          child: ListTile(
                            title:Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('${model[index].id}'),
                                Image.file(File(model[index].RutaAruco),height: 50,width: 50,),
                                model[index].RutaFoto=="87"?Center():Image.file(File(model[index].RutaFoto),height: 50,width: 50,),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                controller.setEleccion(model[index].id);
                                controller.setPat(model[index].RutaAruco);
                                controller.setFoto(model[index].RutaFoto);
                              });
                            },
                          ),
                          color: Colors.greenAccent,
                          elevation: 3.0,
                        );
                        },
                    ),
                  ),
              ),

              Divider(
                height: 50,
                thickness: 2,
                color: Colors.white,
                endIndent: 50,
                indent: 50,
              ),
              ElevatedButton(
                child: const Text('Crear Aruco'),
                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.grey)),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Create()));
                },
              ),
              Divider(
                height: 50,
                thickness: 2,
                color: Colors.white,
                endIndent: 50,
                indent: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Numero de Combinación:', style: TextStyle(color: Colors.white),),
                  Text('${controller.getEleccion()}', style: TextStyle(color: Colors.white),),
                ],
              ),
              ElevatedButton(
                child: const Text('Cámara'),
                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.grey)),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
                    return const DetectionPage();
                  }));
                },
              ),
              Divider(
                height: 50,
                thickness: 2,
                color: Colors.white,
                endIndent: 50,
                indent: 50,
              ),
              ElevatedButton(
                child: const Text('Modificaciones'),
                style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.grey)),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Asignar()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
