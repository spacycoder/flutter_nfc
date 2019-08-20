    
import 'package:flutter_nfc/models/nfc_record.dart';

class NfcMessage {
  NfcMessage({
    this.id,
    this.records,
    this.techList,
  });

  factory NfcMessage.fromMap(Map<dynamic, dynamic> data) => NfcMessage(
        id: data['id'],
        records: (data['records'] as List).map((pay) => NfcRecord.fromMap(pay)).toList(),
        techList: data['techList']?.cast<String>(),
      );

  /// The Tag Identifier (if it has one).
  String id;
  /// A string representation of the NdefRecords 
  List<NfcRecord> records;
  /// The technologies available in this tag, as fully qualified class names.
  List<String> techList;
}