extension IntExtentions on int {
  DateTime asDateTime() {
    if (this == null) {
      throw ArgumentError.notNull("int");
    }

    String strDate = this.toString();
    if (strDate.length != 8) {
      throw ArgumentError.value(strDate.length);
    }

    return DateTime(
      int.parse(strDate.substring(0, 4)),
      int.parse(strDate.substring(4, 6)),
      int.parse(strDate.substring(6, 8)),
    );
  }
}
