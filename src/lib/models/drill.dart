class Drill {
  String title;
  int durationInMinutes;
  String description;
  List<String> tags;

  Drill(
      {this.title = "",
      this.durationInMinutes = 0,
      this.description = "",
      this.tags = const [""]});
}

class ExpandableDrill {
  Drill drill;
  bool isExpanded = false;
  ExpandableDrill({required this.drill, this.isExpanded = false});
}
