class ProgressPoint {
  const ProgressPoint({
    required this.date,
    required this.percent,
  });

  final DateTime date;
  final int percent;
}

class ReportNote {
  const ReportNote({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
}

class ChildReport {
  const ChildReport({
    required this.independentAreas,
    required this.cardsInUse,
    required this.routineCompletion,
    required this.progress,
    required this.notes,
  });

  final int independentAreas;
  final int cardsInUse;
  final int routineCompletion;
  final List<ProgressPoint> progress;
  final List<ReportNote> notes;
}
