import 'dart:math';

class GeneratorOptions {
  const GeneratorOptions({
    this.length = 20,
    this.lowercase = true,
    this.uppercase = true,
    this.digits = true,
    this.symbols = true,
    this.passphrase = false,
    this.wordCount = 5,
  });

  final int length;
  final bool lowercase;
  final bool uppercase;
  final bool digits;
  final bool symbols;
  final bool passphrase;
  final int wordCount;

  GeneratorOptions copyWith({
    int? length,
    bool? lowercase,
    bool? uppercase,
    bool? digits,
    bool? symbols,
    bool? passphrase,
    int? wordCount,
  }) {
    return GeneratorOptions(
      length: length ?? this.length,
      lowercase: lowercase ?? this.lowercase,
      uppercase: uppercase ?? this.uppercase,
      digits: digits ?? this.digits,
      symbols: symbols ?? this.symbols,
      passphrase: passphrase ?? this.passphrase,
      wordCount: wordCount ?? this.wordCount,
    );
  }
}

class PasswordGenerator {
  PasswordGenerator({Random? random}) : _random = random ?? Random.secure();

  final Random _random;

  static const _lower = 'abcdefghijkmnopqrstuvwxyz';
  static const _upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const _digits = '23456789';
  static const _symbols = r'!@#$%^&*()-_=+[]{}';

  static const words = [
    'amber', 'anvil', 'arc', 'atlas', 'autumn', 'badge', 'bamboo', 'basin',
    'beacon', 'birch', 'bloom', 'brave', 'breeze', 'brick', 'brook', 'canyon',
    'cedar', 'charm', 'citadel', 'clear', 'cliff', 'cloud', 'cobalt', 'comet',
    'copper', 'coral', 'crisp', 'crown', 'dune', 'dusk', 'eagle', 'ember',
    'fable', 'falcon', 'fern', 'field', 'flint', 'fog', 'forest', 'forge',
    'garden', 'gate', 'glade', 'gold', 'grain', 'grove', 'harbor', 'haven',
    'hazel', 'hearth', 'hill', 'horizon', 'iris', 'ivory', 'jade', 'jasper',
    'keel', 'kind', 'lagoon', 'lantern', 'lark', 'leaf', 'linen', 'lotus',
    'maple', 'marble', 'meadow', 'mirror', 'mist', 'moon', 'moss', 'nest',
    'north', 'nova', 'oak', 'oasis', 'olive', 'onyx', 'orbit', 'orchid',
    'otter', 'pearl', 'pebble', 'pine', 'plain', 'plum', 'pond', 'prairie',
    'quartz', 'quiet', 'rain', 'raven', 'ridge', 'river', 'robin', 'root',
    'saffron', 'sage', 'sail', 'sand', 'seed', 'shade', 'shell', 'silk',
    'silver', 'sky', 'slope', 'snow', 'spark', 'spring', 'stone', 'storm',
    'summit', 'swift', 'teal', 'thorn', 'tide', 'timber', 'trail', 'true',
    'valley', 'vapor', 'velvet', 'violet', 'vista', 'wave', 'willow', 'wind',
    'winter', 'wolf', 'wood', 'zenith',
  ];

  String generate(GeneratorOptions options) {
    if (options.passphrase) {
      final count = options.wordCount.clamp(3, 8);
      final picked = List<String>.generate(
        count,
        (_) => words[_random.nextInt(words.length)],
      );
      return picked.join('-');
    }

    final buffer = StringBuffer();
    if (options.lowercase) buffer.write(_lower);
    if (options.uppercase) buffer.write(_upper);
    if (options.digits) buffer.write(_digits);
    if (options.symbols) buffer.write(_symbols);
    final alphabet = buffer.toString();
    if (alphabet.isEmpty) {
      throw ArgumentError('Select at least one character set.');
    }

    final required = <String>[];
    if (options.lowercase) {
      required.add(_lower[_random.nextInt(_lower.length)]);
    }
    if (options.uppercase) {
      required.add(_upper[_random.nextInt(_upper.length)]);
    }
    if (options.digits) {
      required.add(_digits[_random.nextInt(_digits.length)]);
    }
    if (options.symbols) {
      required.add(_symbols[_random.nextInt(_symbols.length)]);
    }

    final chars = List<String>.generate(
      options.length,
      (_) => alphabet[_random.nextInt(alphabet.length)],
    );
    for (var i = 0; i < required.length && i < chars.length; i++) {
      chars[i] = required[i];
    }
    chars.shuffle(_random);
    return chars.join();
  }
}
