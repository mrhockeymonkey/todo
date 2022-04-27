class Date {
  final DateTime dateTime;

  Date(DateTime dateTime)
      : this.dateTime =
            new DateTime(dateTime.year, dateTime.month, dateTime.day);

  factory Date.now() {
    var now = DateTime.now();
    return new Date(now);
  }
}
