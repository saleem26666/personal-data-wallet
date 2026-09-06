import 'package:flutter_riverpod/flutter_riverpod.dart';

final lockHoldCountProvider = StateProvider<int>((ref) => 0);

extension LockHoldRef on WidgetRef {
  Future<T> withLockHold<T>(Future<T> Function() action) async {
    final hold = read(lockHoldCountProvider.notifier);
    hold.update((count) => count + 1);
    try {
      return await action();
    } finally {
      hold.update((count) => count - 1);
    }
  }
}
