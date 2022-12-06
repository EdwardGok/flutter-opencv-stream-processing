
class modelo{
  int id;
  String RutaAruco;
  String CodAruco;
  String RutaFoto;
  modelo(this.id,this.RutaAruco,this.CodAruco,this.RutaFoto);
  Map<String,dynamic> toMap(){
    return{'id':id,'RutaAruco':RutaAruco,'CodAruco':CodAruco,'RutaFoto':RutaFoto};
  }
}