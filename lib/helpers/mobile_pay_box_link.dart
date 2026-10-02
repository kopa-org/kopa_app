/// MobilePay's shared Box links contain a UUID, not the six-character Box code.
class MobilePayBoxLink {
  static final _idPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static String? boxId(String value) {
    final trimmed = value.trim();
    if (_idPattern.hasMatch(trimmed)) return trimmed.toLowerCase();
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'qr.mobilepay.dk' ||
        uri.userInfo.isNotEmpty ||
        (uri.hasPort && uri.port != 443)) {
      return null;
    }
    final segments = uri.pathSegments;
    if (segments.length != 3 ||
        segments[0] != 'box' ||
        segments[2] != 'pay-in' ||
        !_idPattern.hasMatch(segments[1])) {
      return null;
    }
    return segments[1].toLowerCase();
  }

  static Uri? webUri(String value) {
    final id = boxId(value);
    return id == null ? null : Uri.https('qr.mobilepay.dk', '/box/$id/pay-in');
  }
}
