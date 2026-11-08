enum IndependenceLevel {
  notYet,
  withHelp,
  independent,
}

class IndependenceSkill {
  const IndependenceSkill({
    required this.id,
    required this.title,
    this.level = IndependenceLevel.notYet,
  });

  final String id;
  final String title;
  final IndependenceLevel level;

  IndependenceSkill copyWith({
    String? id,
    String? title,
    IndependenceLevel? level,
  }) {
    return IndependenceSkill(
      id: id ?? this.id,
      title: title ?? this.title,
      level: level ?? this.level,
    );
  }

  factory IndependenceSkill.fromMap(Map<String, dynamic> map) {
    return IndependenceSkill(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      level: IndependenceLevel.values.firstWhere(
        (value) => value.name == map['level'],
        orElse: () => IndependenceLevel.notYet,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'level': level.name,
    };
  }
}

class IndependenceArea {
  const IndependenceArea({
    required this.id,
    required this.title,
    required this.icon,
    required this.skills,
  });

  final String id;
  final String title;
  final String icon;
  final List<IndependenceSkill> skills;

  int get independentSkills => skills
      .where((skill) => skill.level == IndependenceLevel.independent)
      .length;

  int get withHelpSkills =>
      skills.where((skill) => skill.level == IndependenceLevel.withHelp).length;

  int get completedSkills =>
      skills.where((skill) => skill.level != IndependenceLevel.notYet).length;

  double get independenceRate {
    if (skills.isEmpty) return 0;
    return independentSkills / skills.length;
  }

  /// نعتبر المجال مستقلاً عندما ينجز الطفل
  /// 75% على الأقل من مهاراته بصورة مستقلة.
  bool get isIndependent => independenceRate >= 0.75;

  IndependenceArea copyWith({
    String? id,
    String? title,
    String? icon,
    List<IndependenceSkill>? skills,
  }) {
    return IndependenceArea(
      id: id ?? this.id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      skills: skills ?? this.skills,
    );
  }

  factory IndependenceArea.fromMap(Map<String, dynamic> map) {
    final rawSkills = map['skills'];

    return IndependenceArea(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      icon: map['icon'] as String? ?? '⭐',
      skills: rawSkills is List
          ? rawSkills
              .whereType<Map>()
              .map(
                (skill) => IndependenceSkill.fromMap(
                  Map<String, dynamic>.from(skill),
                ),
              )
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'skills': skills.map((skill) => skill.toMap()).toList(),
    };
  }
}
