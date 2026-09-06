import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class IncomingShare {
  IncomingShare._();

  static const _channel = MethodChannel('com.amanah.amanah/incoming');
  static final _files = StreamController<String>.broadcast();
  static var _bound = false;

  static Stream<String> get files {
    _ensure();
    return _files.stream;
  }

  static Future<String?> takePending() async {
    _ensure();
    return _channel.invokeMethod<String>('takePending');
  }

  static void _ensure() {
    if (_bound) return;
    _bound = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onFile' && call.arguments is String) {
        _files.add(call.arguments as String);
      }
    });
  }
}

bool looksLikeAmanaatBackup(Uint8List bytes) {
  if (bytes.length < 4) return false;
  if (bytes[0] == 0x1f && bytes[1] == 0x8b) return true;
  if (bytes[0] == 0x50 && bytes[1] == 0x4b) return true;
  return false;
}

Future<Uint8List?> readIncomingFile(String path) async {
  final file = File(path);
  if (!await file.exists()) return null;
  return file.readAsBytes();
}
