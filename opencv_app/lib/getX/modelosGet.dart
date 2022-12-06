import 'package:get/get.dart';
class Controller extends GetxController{
  final RxString pat="".obs;
  final RxString foto=''.obs;
  final RxInt id=0.obs;
  final RxInt eleccion=0.obs;
  void setFoto(String v)
  {
    foto.value=v;
  }
  String getFoto()
  {
    return foto.value;
  }
  void setEleccion(int e)
  {
    eleccion.value=e;
  }
  int getEleccion()
  {
    return eleccion.value;
  }
  void setPat(String v)
  {
    pat.value=v;
  }
  String getPat()
  {
    return pat.value;
  }
  int getid()
  {
    return id.value;
  }
  void idPlus(){
    id.value=id.value+1;
  }
  void setId(int idw)
  {
    id.value=idw;
  }
}