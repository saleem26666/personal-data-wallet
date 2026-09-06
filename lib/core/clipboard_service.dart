import 'dart:async';

import 'package:flutter/services.dart';

class ClipboardService {
  ClipboardService({this.clearAfter = const Duration(seconds: 30)});

  final Duration clearAfter;
  Timer? _timer;
  String? _lastCopied;

  Future<void> copy(String value) async {
    _timer?.cancel();
    _lastCopied = value;
    await Clipboard.setData(ClipboardData(text: value));
    _timer = Timer(clearAfter, () async {
      final current = await Clipboard.getData('text/plain');
      if (current?.text == _lastCopied) {
        await Clipboard.setData(const ClipboardData(text: ''));
      }
      _lastCopied = null;
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}
