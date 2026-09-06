import 'dart:convert';

import 'package:flutter/material.dart';

enum FieldKind { text, password, pin, url, email, date, number, multiline }

class FieldSpec {
  const FieldSpec(this.key, this.label, this.kind);

  final String key;
  final String label;
  final FieldKind kind;

  Map<String, String> toJson() => {
        'key': key,
        'label': label,
        'kind': kind.name,
      };

  factory FieldSpec.fromJson(Map<String, dynamic> json) {
    return FieldSpec(
      json['key'] as String? ?? 'field',
      json['label'] as String? ?? 'Field',
      FieldKind.values.firstWhere(
        (kind) => kind.name == json['kind'],
        orElse: () => FieldKind.text,
      ),
    );
  }
}

enum RecordCategory {
  login,
  bank,
  card,
  identity,
  wifi,
  sim,
  note,
  insurance,
  education,
  property,
  vehicle,
  custom,
}

class CategoryDef {
  const CategoryDef({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.fields,
    this.userDefined = false,
  });

  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<FieldSpec> fields;
  final bool userDefined;
}

const builtInCategories = <CategoryDef>[
  CategoryDef(
    id: 'login',
    label: 'Logins',
    subtitle: 'Websites and apps',
    icon: Icons.login_rounded,
    color: Color(0xFF0F766E),
    fields: [
      FieldSpec('username', 'Username', FieldKind.text),
      FieldSpec('password', 'Password', FieldKind.password),
      FieldSpec('website', 'Website', FieldKind.url),
      FieldSpec('email', 'Email', FieldKind.email),
    ],
  ),
  CategoryDef(
    id: 'bank',
    label: 'Bank',
    subtitle: 'Accounts and IBAN',
    icon: Icons.account_balance_rounded,
    color: Color(0xFF1D4ED8),
    fields: [
      FieldSpec('bank', 'Bank name', FieldKind.text),
      FieldSpec('holder', 'Account holder', FieldKind.text),
      FieldSpec('number', 'Account number', FieldKind.text),
      FieldSpec('iban', 'IBAN', FieldKind.text),
      FieldSpec('branch', 'Branch', FieldKind.text),
      FieldSpec('pin', 'PIN', FieldKind.pin),
    ],
  ),
  CategoryDef(
    id: 'card',
    label: 'Cards',
    subtitle: 'Debit and credit',
    icon: Icons.credit_card_rounded,
    color: Color(0xFF7C3AED),
    fields: [
      FieldSpec('holder', 'Cardholder', FieldKind.text),
      FieldSpec('number', 'Card number', FieldKind.number),
      FieldSpec('expiry', 'Expiry', FieldKind.date),
      FieldSpec('cvv', 'CVV', FieldKind.pin),
      FieldSpec('pin', 'PIN', FieldKind.pin),
      FieldSpec('bank', 'Issuer', FieldKind.text),
    ],
  ),
  CategoryDef(
    id: 'identity',
    label: 'IDs',
    subtitle: 'CNIC, passport, licence',
    icon: Icons.badge_rounded,
    color: Color(0xFFB45309),
    fields: [
      FieldSpec('docType', 'Document type', FieldKind.text),
      FieldSpec('fullName', 'Full name', FieldKind.text),
      FieldSpec('number', 'Number', FieldKind.text),
      FieldSpec('issued', 'Issued', FieldKind.date),
      FieldSpec('expiry', 'Expiry', FieldKind.date),
    ],
  ),
  CategoryDef(
    id: 'wifi',
    label: 'Wi-Fi',
    subtitle: 'Networks and keys',
    icon: Icons.wifi_rounded,
    color: Color(0xFF0369A1),
    fields: [
      FieldSpec('ssid', 'Network name', FieldKind.text),
      FieldSpec('password', 'Password', FieldKind.password),
    ],
  ),
  CategoryDef(
    id: 'sim',
    label: 'SIM',
    subtitle: 'PIN, PUK, number',
    icon: Icons.sim_card_rounded,
    color: Color(0xFFBE185D),
    fields: [
      FieldSpec('carrier', 'Carrier', FieldKind.text),
      FieldSpec('number', 'Phone number', FieldKind.text),
      FieldSpec('pin', 'PIN', FieldKind.pin),
      FieldSpec('puk', 'PUK', FieldKind.pin),
    ],
  ),
  CategoryDef(
    id: 'note',
    label: 'Notes',
    subtitle: 'Private text',
    icon: Icons.notes_rounded,
    color: Color(0xFF3F6212),
    fields: [
      FieldSpec('body', 'Note', FieldKind.multiline),
    ],
  ),
  CategoryDef(
    id: 'insurance',
    label: 'Insurance',
    subtitle: 'Policies',
    icon: Icons.health_and_safety_rounded,
    color: Color(0xFF0F766E),
    fields: [
      FieldSpec('provider', 'Provider', FieldKind.text),
      FieldSpec('policy', 'Policy number', FieldKind.text),
      FieldSpec('expiry', 'Expiry', FieldKind.date),
    ],
  ),
  CategoryDef(
    id: 'education',
    label: 'Education',
    subtitle: 'Certificates',
    icon: Icons.school_rounded,
    color: Color(0xFF4338CA),
    fields: [
      FieldSpec('institution', 'Institution', FieldKind.text),
      FieldSpec('credential', 'Credential', FieldKind.text),
      FieldSpec('year', 'Year', FieldKind.text),
    ],
  ),
  CategoryDef(
    id: 'property',
    label: 'Property',
    subtitle: 'Deeds and files',
    icon: Icons.home_work_rounded,
    color: Color(0xFF9A3412),
    fields: [
      FieldSpec('titleNo', 'Title / registry no.', FieldKind.text),
      FieldSpec('address', 'Address', FieldKind.multiline),
    ],
  ),
  CategoryDef(
    id: 'vehicle',
    label: 'Vehicle',
    subtitle: 'Registration',
    icon: Icons.directions_car_rounded,
    color: Color(0xFF0F766E),
    fields: [
      FieldSpec('make', 'Make / model', FieldKind.text),
      FieldSpec('reg', 'Registration', FieldKind.text),
      FieldSpec('vin', 'VIN / chassis', FieldKind.text),
      FieldSpec('expiry', 'Token / tax expiry', FieldKind.date),
    ],
  ),
  CategoryDef(
    id: 'custom',
    label: 'Custom',
    subtitle: 'Anything else',
    icon: Icons.tune_rounded,
    color: Color(0xFF334155),
    fields: [
      FieldSpec('value', 'Value', FieldKind.text),
    ],
  ),
];

const categoryIconChoices = <IconData>[
  Icons.folder_rounded,
  Icons.notes_rounded,
  Icons.medical_services_rounded,
  Icons.account_balance_wallet_rounded,
  Icons.receipt_long_rounded,
  Icons.pets_rounded,
  Icons.flight_rounded,
  Icons.work_rounded,
  Icons.family_restroom_rounded,
  Icons.savings_rounded,
  Icons.gavel_rounded,
  Icons.apartment_rounded,
  Icons.local_hospital_rounded,
  Icons.phone_android_rounded,
  Icons.security_rounded,
  Icons.favorite_rounded,
  Icons.inventory_2_rounded,
  Icons.card_giftcard_rounded,
  Icons.menu_book_rounded,
  Icons.tune_rounded,
];

const categoryColorChoices = <Color>[
  Color(0xFF0F766E),
  Color(0xFF1D4ED8),
  Color(0xFF7C3AED),
  Color(0xFFB45309),
  Color(0xFFBE185D),
  Color(0xFF0369A1),
  Color(0xFF3F6212),
  Color(0xFF9A3412),
  Color(0xFF4338CA),
  Color(0xFF334155),
];

String fieldKindLabel(FieldKind kind) {
  return switch (kind) {
    FieldKind.text => 'Text',
    FieldKind.password => 'Password',
    FieldKind.pin => 'PIN',
    FieldKind.url => 'Website / URL',
    FieldKind.email => 'Email',
    FieldKind.date => 'Date',
    FieldKind.number => 'Number',
    FieldKind.multiline => 'Long text',
  };
}

String fieldKeyFromLabel(String label) {
  final slug = label.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  final trimmed = slug.replaceAll(RegExp(r'^_+|_+$'), '');
  return trimmed.isEmpty ? 'field' : trimmed;
}

String encodeFields(List<FieldSpec> fields) {
  return jsonEncode([for (final field in fields) field.toJson()]);
}

List<FieldSpec> decodeFields(String raw) {
  final decoded = jsonDecode(raw);
  if (decoded is! List) return const [FieldSpec('value', 'Value', FieldKind.text)];
  return [
    for (final entry in decoded)
      if (entry is Map)
        FieldSpec.fromJson(Map<String, dynamic>.from(entry)),
  ];
}

IconData iconFromStored(int code) {
  for (final icon in categoryIconChoices) {
    if (icon.codePoint == code) return icon;
  }
  return categoryIconChoices.first;
}

CategoryDef lookupCategory(String id, [List<CategoryDef> extra = const []]) {
  for (final category in extra) {
    if (category.id == id) return category;
  }
  for (final category in builtInCategories) {
    if (category.id == id) return category;
  }
  return builtInCategories.last;
}

/// Categories people show at a bank / SIM / registry counter.
bool supportsCounterPack(String categoryId) {
  return const {
    'identity',
    'vehicle',
    'education',
    'insurance',
    'sim',
  }.contains(categoryId);
}

/// Field keys that belong on the bright counter card (not PINs / passwords).
const counterFieldKeys = <String>{
  'docType',
  'fullName',
  'number',
  'issued',
  'expiry',
  'make',
  'reg',
  'vin',
  'institution',
  'credential',
  'year',
  'provider',
  'policy',
  'carrier',
};
