import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_nfc/flutter_nfc.dart';
import 'dart:convert';

class WriteExample extends StatefulWidget {
  @override
  _WriteExampleState createState() => _WriteExampleState();
}

class _WriteExampleState extends State<WriteExample> {
  bool isWriting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WRITING EXAMPLE"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 15.0,
              ),
              if (isWriting) buildStopWritingButton(),
              if (!isWriting) buildStartWritingButton()
            ],
          ),
        ),
      ),
    );
  }

  RaisedButton buildStopWritingButton() {
    return RaisedButton(
      onPressed: () async {
        setState(() {
          isWriting = false;
        });
        try {
          await FlutterNfc().stopNfcWriting();
        } catch (e) {
          print(e);
        }
      },
      child: Text("STOP WRITING"),
    );
  }

  RaisedButton buildStartWritingButton() {
    Uint8List bytes = utf8.encoder.convert("SomeData");
    return RaisedButton(
      onPressed: () async {
        setState(() {
          isWriting = true;
        });
        try {
          await FlutterNfc().startNfcWriting([
            FlutterNfc.createTextRecord("this is some random text"),
           /*  FlutterNfc.createExternal("com.example.app", "apptype", bytes), */
           FlutterNfc.createApplicationRecord("com.example.app"),
           /*  FlutterNfc.createMime("text/plain", bytes) */
          ]);
        } catch (e) {
          print(e);
        }
      },
      child: Text("START WRITING"),
    );
  }
}
