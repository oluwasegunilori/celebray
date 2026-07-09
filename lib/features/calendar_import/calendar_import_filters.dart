/// Heuristics to keep civic/public holidays out of calendar import suggestions.
class CalendarImportFilters {
  CalendarImportFilters._();

  static bool isHolidayCalendar({
    String? name,
    String? accountName,
    String? accountType,
  }) {
    final haystack = [name, accountName, accountType]
        .whereType<String>()
        .map((value) => value.toLowerCase())
        .join(' ');

    if (haystack.isEmpty) return false;

    const calendarMarkers = [
      'public holiday',
      'public holidays',
      'national holiday',
      'national holidays',
      'bank holiday',
      'bank holidays',
      'federal holiday',
      'federal holidays',
      'holiday calendar',
      'holidays in',
      'subscribed holidays',
      'us holidays',
      'u.s. holidays',
      'uk holidays',
      'canadian holidays',
      'holiday group',
    ];

    return calendarMarkers.any(haystack.contains);
  }

  static bool isPublicHolidayTitle(String title) {
    final lower = title.toLowerCase().trim();
    if (lower.isEmpty) return false;

    if (RegExp(
      r'\b(public holiday|national holiday|bank holiday|federal holiday|holiday observance)\b',
    ).hasMatch(lower)) {
      return true;
    }

    const holidayTitles = [
      "new year's day",
      "new year's eve",
      'new year holiday',
      'independence day',
      'fourth of july',
      '4th of july',
      'juneteenth',
      'memorial day',
      'labor day',
      'labour day',
      'veterans day',
      'columbus day',
      'indigenous peoples day',
      'indigenous peoples\' day',
      'presidents day',
      "president's day",
      'presidents\' day',
      'martin luther king jr. day',
      'martin luther king day',
      'mlk day',
      'christmas day',
      'christmas eve',
      'boxing day',
      'good friday',
      'easter monday',
      'easter sunday',
      'thanksgiving',
      'thanksgiving day',
      'canada day',
      'victoria day',
      'civic holiday',
      'family day',
      'heritage day',
      'emancipation day',
      'dominion day',
      'australia day',
      'anzac day',
      'queen\'s birthday',
      'king\'s birthday',
      'st. patrick\'s day',
      'st patrick\'s day',
    ];

    for (final holiday in holidayTitles) {
      if (lower == holiday || lower.startsWith('$holiday ')) {
        return true;
      }
    }

    // Generic civic "Something Day" titles that are not personal celebrations.
    if (RegExp(r'\bday\b').hasMatch(lower) &&
        !_looksLikePersonalCelebrationTitle(lower)) {
      const civicDayPatterns = [
        ' independence ',
        ' memorial ',
        ' veterans ',
        ' presidents ',
        ' president ',
        ' labor ',
        ' labour ',
        ' columbus ',
        ' emancipation ',
        ' dominion ',
        ' australia ',
        ' thanksgiving ',
        ' christmas ',
        ' easter ',
        ' boxing ',
        ' juneteenth',
        ' mlk ',
        ' king jr',
      ];
      if (civicDayPatterns.any(lower.contains)) return true;
    }

    return false;
  }

  static bool _looksLikePersonalCelebrationTitle(String lowerTitle) {
    const personalMarkers = [
      'birthday',
      'bday',
      'b-day',
      'anniversary',
      'wedding',
      'graduation',
      'baby shower',
      'retirement',
      'reunion',
      'baptism',
      'bar mitzvah',
      'bat mitzvah',
      'celebration',
      ' shower',
    ];
    return personalMarkers.any(lowerTitle.contains);
  }
}
