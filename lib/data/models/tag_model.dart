class TagModel {
  final String id;
  final String name;
  final int? color;
  final String? icon;
  final int usageCount;

  TagModel({required this.id, required this.name,
    this.color, this.icon, this.usageCount = 0});

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'color': color,
    'icon': icon, 'usage_count': usageCount,
  };

  factory TagModel.fromMap(Map<String, dynamic> m) => TagModel(
    id: m['id'], name: m['name'], color: m['color'],
    icon: m['icon'], usageCount: m['usage_count'] ?? 0,
  );
}