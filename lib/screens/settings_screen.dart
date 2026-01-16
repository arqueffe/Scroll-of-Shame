import 'package:flutter/material.dart';
import '../models/shame_app.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ShameFreeSettings _settings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await StorageService.getShameFreeSettings();
    setState(() {
      _settings = settings;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await StorageService.saveShameFreeSettings(_settings);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initialTime = TimeOfDay(
      hour: isStart ? _settings.startHour : _settings.endHour,
      minute: isStart ? _settings.startMinute : _settings.endMinute,
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _settings = _settings.copyWith(
            startHour: picked.hour,
            startMinute: picked.minute,
          );
        } else {
          _settings = _settings.copyWith(
            endHour: picked.hour,
            endMinute: picked.minute,
          );
        }
      });
      await _saveSettings();
    }
  }

  String _formatTime(int hour, int minute) {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bedtime,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shame-Free Hours',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              'No shaming during these hours',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _settings.enabled,
                        onChanged: (value) async {
                          setState(() {
                            _settings = _settings.copyWith(enabled: value);
                          });
                          await _saveSettings();
                        },
                      ),
                    ],
                  ),
                  if (_settings.enabled) ...[
                    const Divider(height: 32),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text('Start Time'),
                      subtitle: Text(
                        _formatTime(_settings.startHour, _settings.startMinute),
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _selectTime(context, true),
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.access_time_filled),
                      title: const Text('End Time'),
                      subtitle: Text(
                        _formatTime(_settings.endHour, _settings.endMinute),
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: () => _selectTime(context, false),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You won\'t receive shame notifications during these hours',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              subtitle: const Text('Scroll of Shame v1.0.0'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Scroll of Shame',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(Icons.warning_amber, size: 48),
                  children: [
                    const Text(
                      'An app to help you stay productive by shaming you '
                      'for using time-wasting applications.',
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
