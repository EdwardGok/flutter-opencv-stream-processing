import 'package:opencv_app/show/modelo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DB{
  static Future<Database>_openDB() async{
    return openDatabase(join(await getDatabasesPath(),'Amodelo.db'),
    onCreate: (db, version){
      return db.execute(
        'Create table amodelo(id integer primary key, RutaAruco text, CodAruco text, RutaFoto text)',
      );
    },version: 1);
  }
  static Future<List<modelo>> modelosCompletos() async{
    Database database= await _openDB();
    final List<Map<String,dynamic>> modelosMap=await database.rawQuery('Select * from amodelo where RutaFoto!=87');
    return List.generate(modelosMap.length,
            (i) => modelo(
            modelosMap[i]['id'],
            modelosMap[i]['RutaAruco'],
            modelosMap[i]['CodAruco'],
            modelosMap[i]['RutaFoto'])
    );
  }
  static Future<Future<int>> insert(modelo model) async{
    Database database= await _openDB();
    return database.insert('amodelo', model.toMap());
  }
  static Future<Future<int>> delete(modelo model) async{
    Database database= await _openDB();
    return database.delete('amodelo',where: 'id=?',whereArgs: [model.id]);
  }
  static Future<Future<int>> update(modelo model)async{
    Database database= await _openDB();
    return database.update('amodelo',model.toMap(),where: 'id=?',whereArgs: [model.id]);
  }
  static Future<List<modelo>> modelos() async{
    Database database= await _openDB();
    final List<Map<String,dynamic>> modelosMap=await database.query('amodelo');
    return List.generate(modelosMap.length,
            (i) => modelo(
                modelosMap[i]['id'],
                modelosMap[i]['RutaAruco'],
                modelosMap[i]['CodAruco'],
                modelosMap[i]['RutaFoto'])
    );
  }
  static Future<bool> getCod(String cod)async{
    Database database = await _openDB();
    final List<Map<String,dynamic>> modelosMap= await database.query('amodelo');
    for(int i=0;i<modelosMap.length;i++)
    {
      if(modelosMap[i]['CodAruco']==cod)
      {
        return false;
      }
    }
    return true;
  }
}