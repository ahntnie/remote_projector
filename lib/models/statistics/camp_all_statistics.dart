class CampAllStatistics {
  final String label;
  final List<int> data;

  CampAllStatistics(this.label, this.data);
}

class CampSingleStatistics {
  final String day;
  final int data;

  CampSingleStatistics({required this.day, required this.data});
}