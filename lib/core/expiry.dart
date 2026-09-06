import '../../data/database.dart';

class ExpiringItem {
  const ExpiringItem({
    required this.item,
    required this.label,
    required this.date,
    required this.daysLeft,
  });

  final ItemWithFields item;
  final String label;
  final DateTime date;
  final int daysLeft;
}

List<ExpiringItem> expiringSoon(List<ItemWithFields> items, {int withinDays = 30}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final found = <ExpiringItem>[];
  for (final item in items) {
    for (final field in item.fields) {
      if (field.key != 'expiry' && !field.label.toLowerCase().contains('expir')) {
        continue;
      }
      final date = DateTime.tryParse(field.value);
      if (date == null) continue;
      final days = DateTime(date.year, date.month, date.day).difference(today).inDays;
      if (days <= withinDays) {
        found.add(
          ExpiringItem(
            item: item,
            label: field.label,
            date: date,
            daysLeft: days,
          ),
        );
      }
    }
  }
  found.sort((a, b) => a.daysLeft.compareTo(b.daysLeft));
  return found;
}
