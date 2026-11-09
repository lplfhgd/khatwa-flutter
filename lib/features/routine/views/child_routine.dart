import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pairing/services/linked_child_storage.dart';
import '../models/routine_model.dart';
import '../services/routine_service.dart';

class ChildRoutine extends StatefulWidget {
  const ChildRoutine({super.key});

  @override
  State<ChildRoutine> createState() => _ChildRoutineState();
}

class _ChildRoutineState extends State<ChildRoutine> {
  static const Color primary = Color(0xFF148F8C);
  static const Color background = Color(0xFFF7FBFA);
  static const Color textColor = Color(0xFF263F43);
  static const Color subtitleColor = Color(0xFF607983);

  final RoutineService _service = Get.find<RoutineService>();
  final LinkedChildStorage _storage = Get.find<LinkedChildStorage>();

  Stream<List<RoutineModel>>? _routineStream;

  String? _parentId;
  String? _childId;
  String? _error;

  final Set<String> _updatingTasks = {};

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final linkedChild = await _storage.read();

      if (!mounted) return;

      if (linkedChild == null) {
        setState(() {
          _error = 'تعذر العثور على بيانات الطفل المرتبط.';
        });
        return;
      }

      _parentId = linkedChild.parentId;
      _childId = linkedChild.childId;

      setState(() {
        _routineStream = _service.watchChildRoutine(
          parentId: linkedChild.parentId,
          childId: linkedChild.childId,
        );
      });
    } catch (error) {
      debugPrint('CHILD ROUTINE INIT ERROR: $error');

      if (!mounted) return;

      setState(() {
        _error = 'تعذر تحميل الروتين.';
      });
    }
  }

  Future<void> _toggleTask(RoutineModel task) async {
    final parentId = _parentId;
    final childId = _childId;

    if (parentId == null || childId == null) {
      return;
    }

    if (_updatingTasks.contains(task.id)) {
      return;
    }

    setState(() {
      _updatingTasks.add(task.id);
    });

    try {
      await _service.toggleChildRoutineItem(
        parentId: parentId,
        childId: childId,
        itemId: task.id,
        isCompleted: !task.isCompleted,
      );
    } catch (error) {
      debugPrint('CHILD ROUTINE TOGGLE ERROR: $error');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تعذر تحديث المهمة. حاول مرة أخرى.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingTasks.remove(task.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _EmptyRoutine(
        message: _error!,
      );
    }

    final stream = _routineStream;

    if (stream == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: primary,
        ),
      );
    }

    return StreamBuilder<List<RoutineModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint(
            'CHILD ROUTINE ERROR: ${snapshot.error}',
          );

          return const _EmptyRoutine(
            message: 'تعذر تحميل الروتين حاليًا.',
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: primary,
            ),
          );
        }

        final tasks = snapshot.data ?? const <RoutineModel>[];

        return Container(
          color: background,
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                18,
                22,
                18,
                30,
              ),
              children: [
                const Text(
                  'روتيني اليوم',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'خطوة بخطوة نحو يوم رائع',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: subtitleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                if (tasks.isEmpty)
                  const _EmptyRoutine(
                    message: 'لا توجد مهام في روتينك حاليًا',
                  )
                else
                  ...tasks.map(
                    (task) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 14,
                      ),
                      child: _RoutineCard(
                        task: task,
                        isUpdating: _updatingTasks.contains(
                          task.id,
                        ),
                        onTap: () => _toggleTask(task),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({
    required this.task,
    required this.onTap,
    required this.isUpdating,
  });

  final RoutineModel task;
  final VoidCallback onTap;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isUpdating ? null : onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 250,
        ),
        constraints: const BoxConstraints(
          minHeight: 94,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: task.isCompleted ? const Color(0xFFE5F3ED) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: task.isCompleted
                ? _ChildRoutineState.primary
                : const Color(0xFFE5F3ED),
            width: task.isCompleted ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.04,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 27,
              backgroundColor:
                  task.isCompleted ? Colors.white : const Color(0xFFE5F3ED),
              child: Icon(
                task.symbol,
                color: _ChildRoutineState.primary,
                size: 29,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.label,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: _ChildRoutineState.textColor,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    task.time,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _ChildRoutineState.subtitleColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (isUpdating)
              const SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: _ChildRoutineState.primary,
                ),
              )
            else
              AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 200,
                ),
                child: Icon(
                  task.isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  key: ValueKey(
                    task.isCompleted,
                  ),
                  color: task.isCompleted
                      ? Colors.green
                      : _ChildRoutineState.primary,
                  size: 34,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyRoutine extends StatelessWidget {
  const _EmptyRoutine({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.checklist_rounded,
              size: 64,
              color: _ChildRoutineState.primary,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _ChildRoutineState.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
