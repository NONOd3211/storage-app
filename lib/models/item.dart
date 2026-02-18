enum ItemCategory {
  food('食品'),
  medicine('药品'),
  cosmetics('化妆品'),
  daily('日用品'),
  other('其他');

  final String label;
  const ItemCategory(this.label);

  static ItemCategory fromString(String value) {
    return ItemCategory.values.firstWhere(
      (e) => e.name == value || e.label == value,
      orElse: () => ItemCategory.other,
    );
  }
}

enum ExpirationStatus {
  fresh,
  warning,
  urgent,
  expired;

  String get colorName {
    switch (this) {
      case ExpirationStatus.fresh:
        return 'green';
      case ExpirationStatus.warning:
        return 'yellow';
      case ExpirationStatus.urgent:
        return 'orange';
      case ExpirationStatus.expired:
        return 'red';
    }
  }
}

class Item {
  final String id;
  String name;
  ItemCategory category;
  String storageLocation;
  int quantity;
  DateTime? productionDate;
  int? expirationDays;
  DateTime? expirationDate;
  String? notes;
  DateTime createdAt;
  DateTime updatedAt;

  Item({
    required this.id,
    required this.name,
    required this.category,
    required this.storageLocation,
    this.quantity = 1,
    this.productionDate,
    this.expirationDays,
    this.expirationDate,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  DateTime? get calculatedExpirationDate {
    if (expirationDate != null) return expirationDate;
    if (productionDate != null && expirationDays != null) {
      return productionDate!.add(Duration(days: expirationDays!));
    }
    return null;
  }

  int? get daysUntilExpiration {
    final expDate = calculatedExpirationDate;
    if (expDate == null) return null;
    return expDate.difference(DateTime.now()).inDays;
  }

  ExpirationStatus get expirationStatus {
    final days = daysUntilExpiration;
    if (days == null) return ExpirationStatus.fresh;
    if (days < 0) return ExpirationStatus.expired;
    if (days < 30) return ExpirationStatus.urgent;
    if (days < 90) return ExpirationStatus.warning;
    return ExpirationStatus.fresh;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'storageLocation': storageLocation,
      'quantity': quantity,
      'productionDate': productionDate?.millisecondsSinceEpoch,
      'expirationDays': expirationDays,
      'expirationDate': expirationDate?.millisecondsSinceEpoch,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      name: map['name'],
      category: ItemCategory.fromString(map['category']),
      storageLocation: map['storageLocation'],
      quantity: map['quantity'] ?? 1,
      productionDate: map['productionDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['productionDate'])
          : null,
      expirationDays: map['expirationDays'],
      expirationDate: map['expirationDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['expirationDate'])
          : null,
      notes: map['notes'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  Item copyWith({
    String? id,
    String? name,
    ItemCategory? category,
    String? storageLocation,
    int? quantity,
    DateTime? productionDate,
    int? expirationDays,
    DateTime? expirationDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      storageLocation: storageLocation ?? this.storageLocation,
      quantity: quantity ?? this.quantity,
      productionDate: productionDate ?? this.productionDate,
      expirationDays: expirationDays ?? this.expirationDays,
      expirationDate: expirationDate ?? this.expirationDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}