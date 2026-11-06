import 'package:cloud_firestore/cloud_firestore.dart';

enum CommunicationMethod {
  picturesAndSound,
  sound,
  pictures,
}

enum SensoryPreference {
  calmColors,
  calmSounds,
  dimLights,
}

enum DailyGoal {
  emotions,
  routine,
  requests,
}

enum LessonUnit {
  communication,
  emotions,
  routine,
}

enum ChildGender {
  male,
  female,
}

class ChildModel {
  const ChildModel({
    required this.id,
    required this.name,
    this.birthYear,
    this.gender,
    this.communicationMethod = CommunicationMethod.picturesAndSound,
    this.sensoryPreferences = const {},
    this.goals = const {},
    this.lessonUnit = LessonUnit.communication,
    this.level = 1,
    this.progressPercent = 0,
    this.communicationFilesCount = 0,
    this.pendingSync = false,
  });

  final String id;
  final String name;
  final int? birthYear;
  final ChildGender? gender;

  final CommunicationMethod communicationMethod;
  final Set<SensoryPreference> sensoryPreferences;
  final Set<DailyGoal> goals;
  final LessonUnit lessonUnit;

  final int level;
  final int progressPercent;
  final int communicationFilesCount;
  final bool pendingSync;

  factory ChildModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    return ChildModel(
      id: document.id,
      name: data['name'] is String ? data['name'] as String : 'طفل',
      birthYear: data['birthYear'] is int ? data['birthYear'] as int : null,
      gender: data['gender'] == null
          ? null
          : _enumValue(
              ChildGender.values,
              data['gender'],
              ChildGender.male,
            ),
      communicationMethod: _enumValue(
        CommunicationMethod.values,
        data['communicationMethod'],
        CommunicationMethod.picturesAndSound,
      ),
      sensoryPreferences: _enumSet(
        SensoryPreference.values,
        data['sensoryPreferences'],
      ),
      goals: _enumSet(
        DailyGoal.values,
        data['goals'],
      ),
      lessonUnit: _enumValue(
        LessonUnit.values,
        data['lessonUnit'],
        LessonUnit.communication,
      ),
      level: data['level'] is int ? data['level'] as int : 1,
      progressPercent:
          data['progressPercent'] is int ? data['progressPercent'] as int : 0,
      communicationFilesCount: data['communicationFilesCount'] is int
          ? data['communicationFilesCount'] as int
          : 0,
      pendingSync:
          data['pendingSync'] is bool ? data['pendingSync'] as bool : false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'birthYear': birthYear,
      'gender': gender?.name,
      'communicationMethod': communicationMethod.name,
      'sensoryPreferences':
          sensoryPreferences.map((item) => item.name).toList(),
      'goals': goals.map((item) => item.name).toList(),
      'lessonUnit': lessonUnit.name,
      'level': level,
      'progressPercent': progressPercent,
      'communicationFilesCount': communicationFilesCount,
      'pendingSync': pendingSync,
    };
  }

  ChildModel copyWith({
    String? name,
    int? birthYear,
    CommunicationMethod? communicationMethod,
    Set<SensoryPreference>? sensoryPreferences,
    Set<DailyGoal>? goals,
    LessonUnit? lessonUnit,
    int? level,
    int? progressPercent,
    int? communicationFilesCount,
    bool? pendingSync,
    ChildGender? gender,
  }) {
    return ChildModel(
      id: id,
      name: name ?? this.name,
      birthYear: birthYear ?? this.birthYear,
      gender: gender ?? this.gender,
      communicationMethod: communicationMethod ?? this.communicationMethod,
      sensoryPreferences: sensoryPreferences ?? this.sensoryPreferences,
      goals: goals ?? this.goals,
      lessonUnit: lessonUnit ?? this.lessonUnit,
      level: level ?? this.level,
      progressPercent: progressPercent ?? this.progressPercent,
      communicationFilesCount:
          communicationFilesCount ?? this.communicationFilesCount,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }

  static T _enumValue<T extends Enum>(
    List<T> values,
    Object? raw,
    T fallback,
  ) {
    if (raw is! String) {
      return fallback;
    }

    for (final value in values) {
      if (value.name == raw) {
        return value;
      }
    }

    return fallback;
  }

  static Set<T> _enumSet<T extends Enum>(
    List<T> values,
    Object? raw,
  ) {
    if (raw is! List) {
      return <T>{};
    }

    final result = <T>{};

    for (final item in raw) {
      if (item is! String) {
        continue;
      }

      for (final value in values) {
        if (value.name == item) {
          result.add(value);
          break;
        }
      }
    }

    return result;
  }
}
