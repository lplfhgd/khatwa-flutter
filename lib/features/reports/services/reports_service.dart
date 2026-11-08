import '../../communication/services/communication_service.dart';
import '../../routine/services/routine_service.dart';
import '../models/child_report.dart';
import '../../independence/services/independence_service.dart';

class ReportsService {
  ReportsService(
    this._communicationService,
    this._routineService,
    this._independenceService,
  );

  final CommunicationService _communicationService;
  final RoutineService _routineService;
  final IndependenceService _independenceService;

  Stream<ChildReport> watchReport(String childId) {
    final cardsStream = _communicationService.watchCards(childId);
    final routineStream = _routineService.watchRoutine(childId);
    final independenceStream = _independenceService.watchAreas(childId);

    return cardsStream.asyncExpand((cards) {
      return routineStream.asyncExpand((routine) {
        return independenceStream.map((areas) {
          final enabledTasks = routine.where((item) => item.enabled).toList();

          final completedTasks =
              enabledTasks.where((item) => item.isCompleted).length;

          final routineCompletion = enabledTasks.isEmpty
              ? 0
              : ((completedTasks / enabledTasks.length) * 100).round();

          final independentAreas =
              areas.where((area) => area.isIndependent).length;

          return ChildReport(
            independentAreas: independentAreas,
            cardsInUse: cards.length,
            routineCompletion: routineCompletion,
            progress: const [],
            notes: const [],
          );
        });
      });
    });
  }
}
