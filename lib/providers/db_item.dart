class DbItem {
  final String id;

  const DbItem({
    this.id,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
      };
}
