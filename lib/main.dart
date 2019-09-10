import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

const URL = "https://api.hgbrasil.com/finance/?format=json&key=67ad20cc";
const ImageHGFinance = "https://hgbrasil.com/assets/hg-br-logo-29abe59800e509879c6b79ff8861370119567f923c815595f7d19dff4986d786.png";
main(List<String> args) {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(primaryColor: Colors.black),
    ));
}
//Requisicao da API
Future<Map>getDados() async{
  http.Response response  = await http.get(URL);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}



class _HomeState extends State<Home> {
  //Controladores
  final dollarcontroller = TextEditingController();
  final realcontroller = TextEditingController();
  final eurocontroller = TextEditingController();
  var dolar = 0.0;
  var euro = 0.0;
  
  //Funcoes para alterar os campos
  void _limparCampos(){
      dollarcontroller.text = "";
      realcontroller.text = "";
      eurocontroller.text = "";
  }

  void _changeDolar(String text){
      if(text.isEmpty){
        _limparCampos();
        return;
      }
      var valor = double.parse(text);
      realcontroller.text = (valor * dolar).toStringAsFixed(2);
      eurocontroller.text = (valor * dolar/euro).toStringAsPrecision(2);

      
  }
  void _changeReal(String text){
    if(text.isEmpty){
        _limparCampos();
        return;
      }
      var valor = double.parse(text);
      dollarcontroller.text = (valor/dolar).toStringAsFixed(2);
      eurocontroller.text = (valor/euro).toStringAsFixed(2);

  }
  void _changeEuro(String text){
    if(text.isEmpty){
        _limparCampos();
        return;
      }
      var valor = double.parse(text);
      realcontroller.text = (valor * euro).toStringAsPrecision(2);
      dollarcontroller.text = (valor * euro / dolar).toStringAsPrecision(2);

  }
  
  
  // @override
  // initState() {
  //   super.initState();
  //   getDados().then((value){
  //     print(value);
  //   });
  // }


  //TextField para cada moeda
  //Tipo da moeda e o controlador passando por parametro
  Widget _moedaTextField(String moeda,String  prefix,TextEditingController controlador,Function changeMoeda){
    return TextField(
      controller: controlador,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      
      decoration: InputDecoration(
        prefixText: prefix,
        labelText: moeda,
      ),
      onChanged: changeMoeda,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Convesor de moeda"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.recycle),
            onPressed: _limparCampos,
          )
        ],  
      ),
      
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Padding(
            padding: EdgeInsets.all(50),
            child: Image.network(
                  ImageHGFinance,
                  fit: BoxFit.fill,
                ),
            ),
          ),
          FutureBuilder<Map>(
            future: getDados(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Text(
                    "Carregando...",
                    style: TextStyle(fontSize: 25),
                    textAlign: TextAlign.center,
                    );
                    break;
                default:
                  if (snapshot.hasError) {
                    return Text("Erro ao carregar dados >:(",
                                style: TextStyle(fontSize: 25),
                    );
                  }else{
                    dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                    euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                    return Column(
                      children: <Widget>[
                         _moedaTextField("Real","R\$",realcontroller,_changeReal),
                          Divider(),
                          _moedaTextField("Dolar","US\$",dollarcontroller,_changeDolar),
                          Divider(),
                        _moedaTextField("Euro","EU\$",eurocontroller,_changeEuro),
                      ],
                    );
                  }
                  
              }
             },
          ),
         
        ],
      ),
      )
    );  
  }
  
}
