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

  /// Returns [Male], [Female], or null when gender should not be auto-set.
  static String? suggestedSexForRelationship(String relationship) {
    if (_masculineRelationships.contains(relationship)) return 'Male';
    if (_feminineRelationships.contains(relationship)) return 'Female';
    return null;
  }
}
