abstract class DbItem {
  String? get id;

  Map<String, dynamic> toJson();

  // Ideally we would also enforce the fromJson constructor here but not possible in dart
}
