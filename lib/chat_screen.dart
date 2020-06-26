import 'dart:io';

import 'package:chat/text_composer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'chat_message.dart';

class ChatScrenn extends StatefulWidget {
  @override
  _ChatScrennState createState() => _ChatScrennState();
}

class _ChatScrennState extends State<ChatScrenn> {

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final GlobalKey<ScaffoldState> _scaffold = GlobalKey<ScaffoldState>();

  FirebaseUser _correntUSer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.onAuthStateChanged.listen((user) {
      setState(() {
        _correntUSer = user;
      });
    });
  }

  Future<FirebaseUser> _getUser() async{

    if(_correntUSer != null) return _correntUSer;

    try{
      //GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      //Conta da pessoa, liberando Nome, Email, etc
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();

      //Pegou dados account para fazer conexão com o Firebase
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      //Pegando as duas credenciais para fazer logion no Firebase
      final AuthCredential credential = GoogleAuthProvider.getCredential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken);

      //Fazendo login no Firebase
      final AuthResult authResult = await FirebaseAuth.instance.signInWithCredential(credential);

      //Resultado do logion
      final FirebaseUser user = authResult.user;

      return user;

    } catch (error){
      return null;
    }
  }

  //Precisa habilitar o Storage do Firebase para fazer upload de imagens
  void _sendMessage({String text, File imgFile}) async{

    final FirebaseUser user = await _getUser();

    if(user == null){
      _scaffold.currentState.showSnackBar(
        SnackBar(
          content: Text("Não foi possivel fazer Login. Tente novamente!"),
          backgroundColor: Colors.deepOrange,
        )
      );
    }

    Map<String, dynamic> data = {
      "uid": user.uid,
      "senderName": user.displayName,
      "senderPhotoUrl": user.photoUrl,
      "time": Timestamp.now(),
    };

    if(imgFile != null){
//      StorageUploadTask task = FirebaseStorage.instance.ref().child('pasta').child('pasta2').child(path)
      StorageUploadTask task = FirebaseStorage.instance.ref().child(
        //nome do arquivo sendo unico
          DateTime.now().millisecondsSinceEpoch.toString()
      ).putFile(imgFile);

      setState(() {
        _isLoading = true;
      });

      //Salva o retorno da task.onComplete
      StorageTaskSnapshot taskSnopshot = await task.onComplete;
      //Url de download
      String url = await taskSnopshot.ref.getDownloadURL();
      data['imgUrl'] = url;

      setState(() {
        _isLoading = false;
      });
    }

    if(text != null) data['text'] = text;

    Firestore.instance.collection('messages').add(data);
  }

  @override
  Widget build(BuildContext context) {
    //Scaffold - Barra no topo
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        title: Text(
          _correntUSer != null ? 'Fala-e, ${_correntUSer.displayName}' : 'Chat App'
        ),
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          _correntUSer != null ? IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: (){
              FirebaseAuth.instance.signOut();
              googleSignIn.signOut();
              _scaffold.currentState.showSnackBar(
                  SnackBar(
                    content: Text("Desconectado com sucesso"),
                    backgroundColor: Colors.red,
                  )
              );

            },
          ) : Container()
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            //StreamBuilder - Recarregar tela/Lista
            child: StreamBuilder <QuerySnapshot>(
              stream: Firestore.instance.collection('messages').orderBy('time').snapshots(),
              builder: (context, snapshot){
                switch(snapshot.connectionState){
                  case ConnectionState.none:
                  case ConnectionState.waiting:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  default:
                    List<DocumentSnapshot> documents = snapshot.data.documents.reversed.toList();
                    return ListView.builder(
                        itemCount: documents.length,
                        reverse: true,
                        itemBuilder: (context, index){
                          return ChatMessage(documents[index].data,
                              documents[index].data['uid'] == _correntUSer?.uid
                          );
                        });
                }
              },
            ),
          ),
          _isLoading ? LinearProgressIndicator() : Container(),
          TextComposer(_sendMessage),
        ],
      ),
    );
  }
}
