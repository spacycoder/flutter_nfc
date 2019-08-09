enum NfcState { enabled, disabled, notSupported }

/// Takes nfc state string and returns NfcState enum 
NfcState parseNfcState(String state) {
  switch (state) {
    case 'enabled':
      return NfcState.enabled;
    case 'disabled':
      return NfcState.disabled;
    case 'notSupported':
      return NfcState.notSupported;
    default:
      throw ArgumentError('$state is not a valid NfcState.');
  }
}