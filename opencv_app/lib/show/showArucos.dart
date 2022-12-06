import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:opencv_app/getX/modelosGet.dart';
class showAru extends StatefulWidget {
  const showAru({Key? key}) : super(key: key);

  @override
  State<showAru> createState() => _showAruState();
}

class _showAruState extends State<showAru> {
  File? imagen;
  final picker = ImagePicker();
  Future selImagen(op,controller) async{
    var pickedFile;
    if(op==1)
    {
      pickedFile=await picker.getImage(source: ImageSource.camera);
    }
    else
    {
      print(ImageSource.gallery);
      pickedFile=await picker.getImage(source: ImageSource.gallery);
    }
    setState(() {
      if(pickedFile!=null)
        {
          //imagen=File(pickedFile.path);
          cortar(File(pickedFile.path),controller);
        }
      else
        {
          print('No selecionaste una foto');
        }
    });
    Navigator.of(context).pop();
  }
  cortar(picked,controller) async{

    File? cortada=await ImageCropper().cropImage(sourcePath: picked.path, aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0));
    if (cortada!=null)
      {
        setState(() {
          imagen=cortada;
          controller.setPat(cortada.path.toString());
        });
      }
  }
  opciones(context,controller){
    showDialog(
        context: context, 
        builder: (BuildContext context){
          return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      selImagen(2,controller);
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),

                      child: Row(
                        children: [
                          Expanded(
                              child: Text('Seleccionar una foto',style: TextStyle(fontSize: 16),)
                          ),
                          Icon(Icons.image,color: Colors.blue,)
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.red,),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text('Cancelar',style: TextStyle(fontSize: 16, color: Colors.white),textAlign: TextAlign.center,)
                          ),
                          Icon(Icons.camera_alt,color: Colors.blue,)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
  @override
  Widget build(BuildContext context) {
    Controller controller=Get.put(Controller());
    return Scaffold(
      appBar: AppBar(title: Text('Seleccione su Aruco'),),
      body: ListView(
        children: [
          Padding(padding: EdgeInsets.all(20),
            child: Column(
              children: [
                ElevatedButton(onPressed: () {
                  opciones(context,controller);
                }, child: Text('Seleccione una imagen')
                ),
                SizedBox(height: 30,),
                imagen==null?Center(): Image.file(imagen!),
                imagen==null?Center(): Text(controller.pat.toString())
              ],
            ),
          )
        ],
      ),
    );
  }
}
