import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nfc_read_writer/nfc_read_writer.dart';
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
          await NfcReadWriter().stopNfcWriting();
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
          await NfcReadWriter().startNfcWriting([
            /* NfcReadWriter.createTextRecord("this is some random text"), */
           /*  NfcReadWriter.createExternal("com.example.app", "apptype", bytes), */
            /* NfcReadWriter.createApplicationRecord("com.example.app"), */
            NfcReadWriter.createMime("text/plain", bytes)
          ]);
        } catch (e) {
          print(e);
        }
      },
      child: Text("START WRITING"),
    );
  }
}
