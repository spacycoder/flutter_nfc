
Map<int, String> tnfToString = {
  NfcRecord.TNF_EMPTY: "Empty Record",
  NfcRecord.TNF_WELL_KNOWN: "Well-Known Record",
  NfcRecord.TNF_MIME_MEDIA: "MIME Media Record",
  NfcRecord.TNF_ABSOLUTE_URI: "Absolute URI Record",
  NfcRecord.TNF_EXTERNAL_TYPE: "External Record",
  NfcRecord.TNF_UNKNOWN: "Unknown Record",
  NfcRecord.TNF_UNCHANGED: "Unchanged Record"
};

class NfcRecord {
  static const TNF_EMPTY = 0;
  static const TNF_WELL_KNOWN = 1;
  static const TNF_MIME_MEDIA = 2;
  static const TNF_ABSOLUTE_URI = 3;
  static const TNF_EXTERNAL_TYPE = 4;
  static const TNF_UNKNOWN = 5;
  static const TNF_UNCHANGED = 6;

  NfcRecord({
    this.id,
    this.type,
    this.tnf,
    this.payload,
  });

  factory NfcRecord.fromMap(Map<dynamic, dynamic> data) => NfcRecord(
        id: data['id'],
        type: data['type'],
        tnf: data['tnf'],
        payload: data['payload'],
      );

  /// The Record Identifier (if it has one).
  String id;
  /// A description the type of data stored in the payload
  String type;
  /// The Type Name Format(TNF) int value that describes the record type,
  int tnf;
  /// The record payload.
  String payload;

  String getRecordType() {
    return tnfToString[tnf];
  }
}