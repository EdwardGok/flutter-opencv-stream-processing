import 'package:flutter/material.dart';
import 'dart:io';
import '../SqlLite/sql.dart';
import '../getX/modelosGet.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../op.dart';
import 'modelo.dart';

class Asignar extends StatefulWidget {
  const Asignar({Key? key}) : super(key: key);

  @override
  State<Asignar> createState() => _AsignarState();
}

class _AsignarState extends State<Asignar> {
  File? imagen;
  final picker = ImagePicker();
  List<modelo> model=[];
  Controller controller=Get.put(Controller());
  @override
  void initState() {
    cargaModelo();
    super.initState();
  }
  Future cargaModelo() async{
    List<modelo> auxModelo= await DB.modelos();
    setState(() {
      model=auxModelo;
    });
  }
  Future selImagen(index) async{
    var pickedFile;
    pickedFile=await picker.getImage(source: ImageSource.gallery);
    setState(() {
      if(pickedFile!=null)
      {
        imagen=File(pickedFile.path);
        model[index].RutaFoto=imagen!.path;
        DB.update(model[index]);
        setState(() {
        });
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OpenCVApp()));
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Asignar()));
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Imagen Asignada Correctamente'))
        );
      }
      else
      {
        print('No selecionaste una foto');
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: Text('Modificar'),
        backgroundColor: Colors.green.shade400,
      ),
      body: SingleChildScrollView(
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
                  selImagen(index);

                },
                onLongPress: () {
                  _showDialogEliminar(context, index);
                },
              ),
              color: Colors.greenAccent,
              elevation: 3.0,
            );
          },
        ),
      ),
    );
  }
  _showDialogEliminar(context,index)
  {
    showDialog(
        context: context, 
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text('ELIMINAR COMBINACIÓN'),
            content: Text('Esta seguro de eliminar la combinación ${model[index].id}'),
            actions: [
              TextButton(
                  onPressed: () {
                    setState(() {
                    });
                    Navigator.of(context).pop();
                  }, child: Text('Cancelar')),
              TextButton(onPressed: () {
                DB.delete(model[index]);
                setState(() {
                });
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>OpenCVApp()));
                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>Asignar()));
              }, child: Text('Ok'))
            ],
          );
        },);
  }
}

