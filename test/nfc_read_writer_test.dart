import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_read_writer/nfc_read_writer.dart';

void main() {
  const MethodChannel channel = MethodChannel('nfc_read_writer');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await NfcReadWriter.platformVersion, '42');
  });
}
