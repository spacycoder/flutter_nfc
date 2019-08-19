import 'package:flutter_nfc/models/nfc_message.dart';

class NfcData {
  NfcData({
    this.error,
    this.message,
  });

  factory NfcData.fromMap(Map data) => NfcData(
        error: data['error'],
        message: data['message'] != null
            ? NfcMessage.fromMap(data['message'])
            : null,
      );

  /// error contains error messages from reading nfc
  String error;
  /// message contains the nfc NdefMessage
  NfcMessage message;
}