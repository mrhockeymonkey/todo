abstract class DbItem {
  String? get id;

  // const DbItem({
  //   this.id, // TODO ?? inherit? make abstract?
  // });

  Map<String, dynamic> toMap();
}
