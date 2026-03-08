import 'package:flutter_test/flutter_test.dart';
import 'package:storage_app/models/item.dart';

void main() {
  test('ItemCategory.fromString supports enum name and label', () {
    expect(ItemCategory.fromString('food'), ItemCategory.food);
    expect(ItemCategory.fromString('药品'), ItemCategory.medicine);
    expect(ItemCategory.fromString('unknown'), ItemCategory.other);
  });

  test('Expiration status respects warning and urgent thresholds', () {
    final soonItem = Item(
      id: '1',
      name: 'Milk',
      category: ItemCategory.food,
      storageLocation: '冰箱',
      expirationDate: DateTime.now().add(const Duration(days: 5)),
    );

    final expiredItem = Item(
      id: '2',
      name: 'Yogurt',
      category: ItemCategory.food,
      storageLocation: '冰箱',
      expirationDate: DateTime.now().subtract(const Duration(days: 1)),
    );

    expect(
      soonItem.getExpirationStatus(warningDays: 30, urgentDays: 7),
      ExpirationStatus.urgent,
    );
    expect(
      expiredItem.getExpirationStatus(warningDays: 30, urgentDays: 7),
      ExpirationStatus.expired,
    );
  });
}
