class EventFormOptions {
  EventFormOptions._();

  static const addYoursLabel = 'Add yours';

  static const eventTypes = [
    'Adoption Day',
    'Anniversary',
    'Baby Shower',
    'Bar Mitzvah',
    'Bat Mitzvah',
    'Baptism',
    'Birthday',
    'Bridal Shower',
    'Confirmation',
    'Engagement',
    'Farewell',
    'First Day of School',
    'Graduation',
    'Housewarming',
    'Launch Day',
    'Memorial',
    'Moving Day',
    'New Baby',
    'Promotion',
    'Reunion',
    'Retirement',
    'Sobriety Milestone',
    'Wedding',
    'Work Anniversary',
  ];

  static const relationships = [
    'Aunt',
    'Best Friend',
    'Boss',
    'Boyfriend',
    'Brother',
    'Child',
    'Client',
    'Coach',
    'Colleague',
    'Cousin',
    'Daughter',
    'Ex-Husband',
    'Ex-Wife',
    'Family',
    'Father',
    'Fiancé',
    'Fiancée',
    'Friend',
    'Girlfriend',
    'Godfather',
    'Godmother',
    'Granddaughter',
    'Grandfather',
    'Grandmother',
    'Grandson',
    'Husband',
    'Mentor',
    'Mother',
    'Neighbor',
    'Nephew',
    'Niece',
    'Parent',
    'Partner',
    'Sister',
    'Son',
    'Stepbrother',
    'Stepfather',
    'Stepmother',
    'Stepsister',
    'Teacher',
    'Uncle',
    'Wife',
  ];

  static const sexOptions = ['Female', 'Male', 'Other'];

  static const faithContexts = [
    'None',
    'Christianity',
    'Islam',
    'Judaism',
    'Hinduism',
    'Buddhism',
    'Other',
  ];

  static const _masculineRelationships = {
    'Husband',
    'Boyfriend',
    'Fiancé',
    'Ex-Husband',
    'Father',
    'Grandfather',
    'Stepfather',
    'Brother',
    'Stepbrother',
    'Son',
    'Grandson',
    'Uncle',
    'Nephew',
    'Godfather',
  };

  static const _feminineRelationships = {
    'Wife',
    'Girlfriend',
    'Fiancée',
    'Ex-Wife',
    'Mother',
    'Grandmother',
    'Stepmother',
    'Sister',
    'Stepsister',
    'Daughter',
    'Granddaughter',
    'Aunt',
    'Niece',
    'Godmother',
  };

  static List<String> optionsWithCustom({
    required List<String> presets,
    required String? current,
  }) {
    final options = List<String>.from(presets);
    final trimmed = current?.trim();
    if (trimmed != null &&
        trimmed.isNotEmpty &&
        trimmed != addYoursLabel &&
        !options.contains(trimmed)) {
      options.add(trimmed);
      options.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }
    return options;
  }

  /// Infers an event type when the name contains a recognizable cue.
  static String? inferEventTypeFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.trim().isEmpty) return null;

    const keywordCues = <String, String>{
      'baby shower': 'Baby Shower',
      'work anniversary': 'Work Anniversary',
      'first day of school': 'First Day of School',
      'sobriety milestone': 'Sobriety Milestone',
      'bar mitzvah': 'Bar Mitzvah',
      'bat mitzvah': 'Bat Mitzvah',
      'bridal shower': 'Bridal Shower',
      'housewarming': 'Housewarming',
      'anniversary': 'Anniversary',
      'graduation': 'Graduation',
      'engagement': 'Engagement',
      'retirement': 'Retirement',
      'promotion': 'Promotion',
      'memorial': 'Memorial',
      'funeral': 'Memorial',
      'birthday': 'Birthday',
      'bday': 'Birthday',
      'baptism': 'Baptism',
      'confirmation': 'Confirmation',
      'wedding': 'Wedding',
      'farewell': 'Farewell',
      'reunion': 'Reunion',
      'adoption': 'Adoption Day',
      'launch day': 'Launch Day',
      'moving day': 'Moving Day',
      'new baby': 'New Baby',
    };

    final sortedCues = keywordCues.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));

    for (final cue in sortedCues) {
      if (lower.contains(cue.key)) return cue.value;
    }

    for (final type in eventTypes) {
      if (lower.contains(type.toLowerCase())) return type;
    }

    return null;
  }

  /// Returns [Male], [Female], or null when gender should not be auto-set.
  static String? suggestedSexForRelationship(String relationship) {
    if (_masculineRelationships.contains(relationship)) return 'Male';
    if (_feminineRelationships.contains(relationship)) return 'Female';
    return null;
  }

  /// Keeps person/couple names separate from the celebration type field.
  ///
  /// Examples: "David's Birthday" + Birthday → "David";
  /// "David & Jessica" + Anniversary → "David & Jessica".
  static String normalizePersonName(String rawName, {String? eventType}) {
    var working = rawName.trim();
    if (working.isEmpty) return working;

    if (eventType != null && eventType.trim().isNotEmpty) {
      final stripped = _stripTrailingType(working, eventType.trim());
      if (stripped != null && stripped.isNotEmpty) {
        working = stripped;
      }
    }

    return working.isEmpty ? rawName.trim() : working;
  }

  static String? _stripTrailingType(String name, String type) {
    final escaped = RegExp.escape(type.trim());
    final patterns = [
      RegExp("^(.+?)'s?\\s+$escaped\\s*\$", caseSensitive: false),
      RegExp("^$escaped\\s*[-–—:of]+\\s*(.+)\$", caseSensitive: false),
      RegExp("^(.+)\\s+$escaped\\s*\$", caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(name.trim());
      if (match == null) continue;

      final extracted = (match.group(1) ?? match.group(2))?.trim();
      if (extracted != null &&
          extracted.isNotEmpty &&
          !_isCelebrationWord(extracted)) {
        return extracted;
      }
    }

    return null;
  }

  static bool _isCelebrationWord(String value) {
    final lower = value.toLowerCase();
    return lower == 'birthday' ||
        lower == 'bday' ||
        lower == 'anniversary' ||
        lower == 'wedding';
  }
}
