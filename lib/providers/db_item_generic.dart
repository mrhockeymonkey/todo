abstract class DbItem<T> {
  final String id;

  const DbItem({
    required this.id,
  });

  Map<String, dynamic> toMap();

  // not possible??
  // factory T.fromMap(Map<String, dynamic> map);
}
