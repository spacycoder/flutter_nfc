    
class NfcMessage {
  NfcMessage({
    this.id,
    this.payload,
    this.techList,
  });

  factory NfcMessage.fromMap(Map<dynamic, dynamic> data) => NfcMessage(
        id: data['id'],
        payload: data['payload']?.cast<String>(),
        techList: data['techList']?.cast<String>(),
      );

  /// The Tag Identifier (if it has one).
  String id;
  /// A string representation of the NdefRecords 
  List<String> payload;
  /// The technologies available in this tag, as fully qualified class names.
  List<String> techList;
}