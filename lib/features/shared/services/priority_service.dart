import '../models/app_priority.dart';

class PriorityService {
  static const List<String> _highKeywords = [
    'gas leakage',
    'fire risk',
    'chemical',
    'explosion',
    'blocked exit',
    'hospital',
    'icu',
    'emergency',
    'flammable',
    'hazard',
    'evacuation',
  ];

  static const List<String> _mediumKeywords = [
    'commercial inspection',
    'restaurant',
    'school',
    'factory',
    'moderate risk',
    'warehouse',
    'office',
  ];

  static const List<String> _lowKeywords = [
    'renewal',
    'routine inspection',
    'small office',
    'basic check',
    'maintenance',
  ];

  static AppPriority derivePriority({
    required String title,
    required String category,
    required String description,
    required String location,
  }) {
    final text = [title, category, description, location]
        .join(' ')
        .toLowerCase();

    if (_highKeywords.any(text.contains)) {
      return AppPriority.high;
    }

    if (_mediumKeywords.any(text.contains)) {
      return AppPriority.medium;
    }

    if (_lowKeywords.any(text.contains)) {
      return AppPriority.low;
    }

    return AppPriority.medium;
  }
}
