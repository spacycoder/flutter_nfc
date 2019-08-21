import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_nfc/models/nfc_data.dart';
import 'package:flutter_nfc/models/nfc_state.dart';

const EXTERNAL_RECORD = "EXTERNAL";
const APPLICATION_RECORD = "APPLICATION";
const MIME_RECORD = "MIME";
const TEXT_RECORD = "TEXT";
const URI_RECORD = "URI";

class FlutterNfc {
  factory FlutterNfc() {
    if (_instance == null) {
      final methodChannel = MethodChannel('flutter_nfc_method_channel');
      final eventChannel = EventChannel('flutter_nfc_event_channel');
      _instance = FlutterNfc.private(methodChannel, eventChannel);
    }
    return _instance;
  }

  FlutterNfc.private(this._methodChannel, this._eventChannel);

  static FlutterNfc _instance;

  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;
  Stream<NfcData> _onNfcMessage;

  /// Check if NFC is enabled
  Future<NfcState> get nfcState => _methodChannel
      .invokeMethod<String>('getNfcState')
      .then<NfcState>((String result) => parseNfcState(result));

  /// Check if the app was started with NFC
  /// and get NFC message started with
  Future<NfcData> get nfcStartedWith =>
      _methodChannel.invokeMethod<dynamic>('getNfcStartedWith').then<NfcData>(
          (dynamic event) => event != null ? NfcData.fromMap(event) : null);

  /// Fires whenever the nfc message received.
  Stream<NfcData> get listenForNfc {
    _onNfcMessage ??= _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => NfcData.fromMap(event));
    return _onNfcMessage;
  }

  /// Start writing to nfc tag. Will resolve when it has successfully written to a tag.
  /// If it fails it will throw an error
  Future<dynamic> startNfcWriting(List<Map<String, dynamic>> records) {
    return _methodChannel
        .invokeMethod<dynamic>('startNfcWrite', {"records": records});
  }

  Future<dynamic> stopNfcWriting() {
    return _methodChannel.invokeMethod<dynamic>('cancelNfcWrite');
  }

  /// Create a new Android Application Record given a [packageName]
  /// If the appliction is not installed on the device, a Market link will be opened to the first application.
  static Map<String, dynamic> createApplicationRecord(String packageName) {
    return {
      "recordType": APPLICATION_RECORD,
      "packageName": packageName,
    };
  }

  /// Create a new NDEF Record containing external (application-specific) data.
  /// Takes [domain] which is the domain-name of the issuing organization.
  /// domain-spesific [type] of data. And [data] which is the payload in bytes
  static Map<String, dynamic> createExternal(
      String domain, String type, Uint8List data) {
    return {
      "recordType": EXTERNAL_RECORD,
      "type": type,
      "domain": domain,
      "data": data,
    };
  }

  /// Create a new NDEF Record containing MIME data.
  /// takes a valid [mimeType] and [mimeData] stored in bytes
  static Map<String, dynamic> createMime(String mimeType, Uint8List mimeData) {
    return {
      "recordType": MIME_RECORD,
      "mimeType": mimeType,
      "mimeData": mimeData,
    };
  }

  /// Create a new NDEF record containing UTF-8 text data.
  /// The caller can either specify the [languageCode] for the provided [text],
  /// or otherwise the language code corresponding to the current default locale will be used.
  static Map<String, dynamic> createTextRecord(String text,
      {String languageCode}) {
    return {
      "recordType": TEXT_RECORD,
      "text": text,
      "languageCode": languageCode,
    };
  }

  /// Create a new NDEF Record containing a [uri].
  static Map<String, dynamic> createUriRecord(String uri) {
    return {
      "recordType": URI_RECORD,
      "uri": uri,
    };
  }
}
