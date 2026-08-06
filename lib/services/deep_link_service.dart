import 'dart:async';

import 'package:flutter/services.dart';

class DeepLinkService {
  static const _methodChannel = MethodChannel('dk.kopa.app/deep_links');
  static const _eventChannel = EventChannel('dk.kopa.app/deep_link_events');

  static Future<String?> getInitialLink() async {
    final String? link;
    try {
      link = await _methodChannel.invokeMethod<String>('getInitialLink');
    } on MissingPluginException {
      return null;
    }

    if (link == null || link.trim().isEmpty) return null;
    return link;
  }

  static Stream<String> get linkStream {
    return _eventChannel
        .receiveBroadcastStream()
        .where((event) => event is String)
        .cast<String>();
  }
}
