class IntendApp {
  final String packageName;
  final String appName;
  final String intentionPrompt;
  final bool isEnabled;

  IntendApp({
    required this.packageName,
    required this.appName,
    required this.intentionPrompt,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'appName': appName,
        'intentionPrompt': intentionPrompt,
        'isEnabled': isEnabled,
      };

  factory IntendApp.fromJson(Map<String, dynamic> json) => IntendApp(
        packageName: json['packageName'] as String,
        appName: json['appName'] as String,
        intentionPrompt: json['intentionPrompt'] as String? ?? 
                         json['shameMessage'] as String? ?? 
                         'Are you opening this with intention?',
        isEnabled: json['isEnabled'] as bool? ?? true,
      );

  IntendApp copyWith({
    String? packageName,
    String? appName,
    String? intentionPrompt,
    bool? isEnabled,
  }) {
    return IntendApp(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      intentionPrompt: intentionPrompt ?? this.intentionPrompt,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class FocusTimeSettings {
  final bool enabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  FocusTimeSettings({
    this.enabled = false,
    this.startHour = 22,
    this.startMinute = 0,
    this.endHour = 8,
    this.endMinute = 0,
  });

  bool isInFocusTime(DateTime now) {
    if (!enabled) return false;

    final currentMinutes = now.hour * 60 + now.minute;
    final startMinutes = startHour * 60 + startMinute;
    final endMinutes = endHour * 60 + endMinute;

    if (startMinutes < endMinutes) {
      // Same day range (e.g., 8:00 AM to 10:00 PM)
      return currentMinutes >= startMinutes && currentMinutes < endMinutes;
    } else {
      // Overnight range (e.g., 10:00 PM to 8:00 AM)
      return currentMinutes >= startMinutes || currentMinutes < endMinutes;
    }
  }

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'startHour': startHour,
        'startMinute': startMinute,
        'endHour': endHour,
        'endMinute': endMinute,
      };

  factory FocusTimeSettings.fromJson(Map<String, dynamic> json) =>
      FocusTimeSettings(
        enabled: json['enabled'] as bool? ?? false,
        startHour: json['startHour'] as int? ?? 22,
        startMinute: json['startMinute'] as int? ?? 0,
        endHour: json['endHour'] as int? ?? 8,
        endMinute: json['endMinute'] as int? ?? 0,
      );

  FocusTimeSettings copyWith({
    bool? enabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return FocusTimeSettings(
      enabled: enabled ?? this.enabled,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }
}
