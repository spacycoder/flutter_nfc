import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_nfc/flutter_nfc.dart';

class ReadExample extends StatefulWidget {
  @override
  _ReadExampleState createState() => _ReadExampleState();
}

class _ReadExampleState extends State<ReadExample> {
  bool isReading = false;
  StreamSubscription subscription;

  List<String> records = []; 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("READING EXAMPLE"),
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
              isReading
                  ? RaisedButton(
                      onPressed: () {
                        setState(() {
                          isReading = false;
                        });
                        subscription.cancel();
                      },
                      child: Text("STOP READING"),
                    )
                  : RaisedButton(
                      onPressed: () {
                        setState(() {
                          isReading = true;
                        });
                        subscription = FlutterNfc().listenForNfc.listen((onData) {
                          print("error: " + onData?.error);
                          setState(() {
                            records = onData.message?.payload ?? [];
                          });
                        });
                      },
                      child: Text("START READING"),
                    ),
                    ...records.map((record) => Text(record)).toList()
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if(subscription != null) {
      subscription.cancel();
    }
  }
}
