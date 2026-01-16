class ShameApp {
  final String packageName;
  final String appName;
  final String shameMessage;
  final bool isEnabled;

  ShameApp({
    required this.packageName,
    required this.appName,
    required this.shameMessage,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'appName': appName,
        'shameMessage': shameMessage,
        'isEnabled': isEnabled,
      };

  factory ShameApp.fromJson(Map<String, dynamic> json) => ShameApp(
        packageName: json['packageName'] as String,
        appName: json['appName'] as String,
        shameMessage: json['shameMessage'] as String,
        isEnabled: json['isEnabled'] as bool? ?? true,
      );

  ShameApp copyWith({
    String? packageName,
    String? appName,
    String? shameMessage,
    bool? isEnabled,
  }) {
    return ShameApp(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      shameMessage: shameMessage ?? this.shameMessage,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class ShameFreeSettings {
  final bool enabled;
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  ShameFreeSettings({
    this.enabled = false,
    this.startHour = 22,
    this.startMinute = 0,
    this.endHour = 8,
    this.endMinute = 0,
  });

  bool isInShameFreeHours(DateTime now) {
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

  factory ShameFreeSettings.fromJson(Map<String, dynamic> json) =>
      ShameFreeSettings(
        enabled: json['enabled'] as bool? ?? false,
        startHour: json['startHour'] as int? ?? 22,
        startMinute: json['startMinute'] as int? ?? 0,
        endHour: json['endHour'] as int? ?? 8,
        endMinute: json['endMinute'] as int? ?? 0,
      );

  ShameFreeSettings copyWith({
    bool? enabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return ShameFreeSettings(
      enabled: enabled ?? this.enabled,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }
}
