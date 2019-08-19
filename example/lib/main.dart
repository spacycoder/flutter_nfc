import 'package:flutter/material.dart';

import 'package:flutter_nfc_example/pages/read_example.dart';
import 'package:flutter_nfc_example/pages/write_example.dart';
import 'package:flutter_nfc/flutter_nfc.dart';
import 'package:flutter_nfc/models/nfc_state.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NFC READER/WRITER",
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    Key key,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  NfcState _nfcStatus;

  @override
  void initState() {
    super.initState();
    getNfcState();
  }

  getNfcState() async {
    _nfcStatus = await FlutterNfc().nfcState;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SafeArea(
              child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              RaisedButton(
                child: Text("WRITING EXAMPLE"),
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => WriteExample(),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 10.0,
              ),
              RaisedButton(
                child: Text("READING EXAMPLE"),
                onPressed: () async {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReadExample(),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 10.0,
              ),
              Center(child: Text(_nfcStatus?.toString() ?? ""))
            ],
          ),
        ),
      ),
    );
  }
}
