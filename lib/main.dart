import 'package:chat/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() async {

  runApp(MyApp());

}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.blue
        )
      ),
      home: ChatScrenn(),
    );
  }
}

//  Firestore.instance.collection("mensagens").snapshots().listen((dado) {
//    dado.documents.forEach((d) {
//      print(d.data);
//    });
//  });

//
//  QuerySnapshot querySnapshot = await Firestore.instance.collection("mensagens").getDocuments();
//  querySnapshot.documents.forEach((cadaDocumento) {
//    print(cadaDocumento.documentID);
//  });

//  QuerySnapshot - Todos os documentos
//  DocumentSnapshot - apenas um documento
//  QuerySnapshot querySnapshot = await Firestore.instance.collection("mensagens").getDocuments();
//  querySnapshot.documents.forEach((cadaDocumento) {
//    print(cadaDocumento.data);
//  });
//  Incluir dados no firebase
//  Firestore.instance
//      .collection("mensagens")
//      .document("msg2")
//      .collection("arquivos")
//      .document()
//      .setData(
//          {'arquivoName': 'Foto do arquivo', 'from': 'Kianny', 'read': false});
