class UserModel {
  final int? id;
  final String firebaseUid;
  final String? name;
  final String? email;
  final String? photoUrl;
  final String defaultCurrency;
  final String theme;
  final double? monthlyBudget;
  final String locale;
  final int createdAt;

  UserModel({
    this.id,
    required this.firebaseUid,
    this.name,
    this.email,
    this.photoUrl,
    this.defaultCurrency = 'INR',
    this.theme = 'system',
    this.monthlyBudget,
    this.locale = 'en_IN',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'firebase_uid': firebaseUid,
    'name': name,
    'email': email,
    'photo_url': photoUrl,
    'default_currency': defaultCurrency,
    'theme': theme,
    'monthly_budget': monthlyBudget,
    'locale': locale,
    'created_at': createdAt,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'],
    firebaseUid: map['firebase_uid'],
    name: map['name'],
    email: map['email'],
    photoUrl: map['photo_url'],
    defaultCurrency: map['default_currency'] ?? 'INR',
    theme: map['theme'] ?? 'system',
    monthlyBudget: map['monthly_budget'],
    locale: map['locale'] ?? 'en_IN',
    createdAt: map['created_at'],
  );
}