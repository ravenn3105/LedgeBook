class NotebookModel {
  final String id;
  final String title;
  final String? description;
  final String currency;
  final double? budget;
  final String? icon;
  final int? color;
  final bool isArchived;
  final int createdAt;

  NotebookModel({
    required this.id,
    required this.title,
    this.description,
    this.currency = 'INR',
    this.budget,
    this.icon,
    this.color,
    this.isArchived = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'description': description,
    'currency': currency, 'budget': budget, 'icon': icon,
    'color': color, 'is_archived': isArchived ? 1 : 0,
    'created_at': createdAt,
  };

  factory NotebookModel.fromMap(Map<String, dynamic> m) => NotebookModel(
    id: m['id'], title: m['title'], description: m['description'],
    currency: m['currency'] ?? 'INR', budget: m['budget'],
    icon: m['icon'], color: m['color'],
    isArchived: m['is_archived'] == 1, createdAt: m['created_at'],
  );
}