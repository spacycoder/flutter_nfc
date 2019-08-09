#import "NfcReadWriterPlugin.h"
#import <nfc_read_writer/nfc_read_writer-Swift.h>

@implementation NfcReadWriterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNfcReadWriterPlugin registerWithRegistrar:registrar];
}
@end
