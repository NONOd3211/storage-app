class StorageLocation {
  static const String uncategorizedId = 'preset_uncategorized';

  final String id;
  String name;
  String? description;
  String icon;
  bool isPreset;

  StorageLocation({
    required this.id,
    required this.name,
    this.description,
    this.icon = 'archivebox',
    this.isPreset = false,
  });

  static final List<StorageLocation> presetLocations = [
    StorageLocation(
      id: uncategorizedId,
      name: '未分类',
      icon: 'help_outline',
      isPreset: true,
    ),
    StorageLocation(id: 'preset_1', name: '冰箱', icon: 'kitchen', isPreset: true),
    StorageLocation(id: 'preset_2', name: '橱柜', icon: 'door_sliding', isPreset: true),
    StorageLocation(id: 'preset_5', name: '架子', icon: 'shelves', isPreset: true),
  ];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'isPreset': isPreset ? 1 : 0,
    };
  }

  factory StorageLocation.fromMap(Map<String, dynamic> map) {
    return StorageLocation(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'],
      isPreset: map['isPreset'] == 1,
    );
  }
}
