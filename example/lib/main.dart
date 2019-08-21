import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_nfc_example/pages/read_example.dart';
import 'package:flutter_nfc_example/pages/write_example.dart';
import 'package:flutter_nfc/flutter_nfc.dart';
import 'package:flutter_nfc/models/nfc_state.dart';
import 'package:flutter_nfc/models/nfc_data.dart';

void main() {
  runApp(MyApp());
}

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

class _HomeState extends State<Home> with WidgetsBindingObserver {
  NfcState _nfcStatus;
  bool startedWithNfc = false;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    getNfcState();
    getStartupState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
     print("check startup");
     getStartupState();
    }
  }

  getStartupState() async {
    final NfcData res = await FlutterNfc().nfcStartedWith;
    if (res != null) {
      print("not null");
      setState(() {
        startedWithNfc = true;
      });
    }
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
              Center(child: Text(_nfcStatus?.toString() ?? "")),
              SizedBox(
                height: 10.0,
              ),
              Center(
                  child: Text(startedWithNfc
                      ? "STARTED WITH NFC"
                      : "NOT STARTED WITH NFC")),
            ],
          ),
        ),
      ),
    );
  }
}
