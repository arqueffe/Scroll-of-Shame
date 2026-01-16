import 'package:flutter/material.dart';
import '../models/shame_app.dart';
import '../services/storage_service.dart';
import '../services/accessibility_service.dart';
import 'add_app_screen.dart';
import 'settings_screen.dart';
import '../widgets/shame_app_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<IntendApp> _intendApps = [];
  bool _isMonitoring = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _checkPermission();
  }

  @override
  void dispose() {
    if (_isMonitoring) {
      AccessibilityService.stopMonitoring();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    final apps = await StorageService.getIntendApps();
    setState(() {
      _intendApps = apps;
    });
  }

  Future<void> _checkPermission() async {
    final hasPermission = await AccessibilityService.hasPermission();
    setState(() {
      _hasPermission = hasPermission;
    });
  }

  Future<void> _toggleMonitoring() async {
    if (!_hasPermission) {
      await AccessibilityService.requestPermission();
      await Future.delayed(const Duration(seconds: 1));
      await _checkPermission();
      return;
    }

    setState(() {
      _isMonitoring = !_isMonitoring;
    });

    if (_isMonitoring) {
      AccessibilityService.startMonitoring();
    } else {
      AccessibilityService.stopMonitoring();
    }
  }

  Future<void> _toggleAppEnabled(IntendApp app) async {
    final updatedApp = app.copyWith(isEnabled: !app.isEnabled);
    await StorageService.updateIntendApp(updatedApp);
    await _loadData();
  }

  Future<void> _deleteApp(IntendApp app) async {
    await StorageService.removeIntendApp(app.packageName);
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Intend'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isMonitoring ? Icons.visibility : Icons.visibility_off,
                                size: 32,
                                color: _isMonitoring ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isMonitoring ? 'Monitoring Active' : 'Monitoring Paused',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      _hasPermission
                                          ? 'We\'re watching your scroll habits'
                                          : 'Permission needed to monitor apps',
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isMonitoring,
                                onChanged: (_) => _toggleMonitoring(),
                              ),
                            ],
                          ),
                          if (!_hasPermission)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await AccessibilityService.requestPermission();
                                  await Future.delayed(const Duration(seconds: 1));
                                  await _checkPermission();
                                },
                                icon: const Icon(Icons.security),
                                label: const Text('Grant Permission'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Intentional Use Apps',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${_intendApps.where((app) => app.isEnabled).length}/${_intendApps.length}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_intendApps.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list_alt,
                      size: 64,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No apps in your intention list yet',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add apps to use them more intentionally',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[500],
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final app = _intendApps[index];
                    return ShameAppCard(
                      app: app,
                      onToggle: () => _toggleAppEnabled(app),
                      onDelete: () => _deleteApp(app),
                    );
                  },
                  childCount: _intendApps.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAppScreen(),
            ),
          );
          await _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add App'),
      ),
    );
  }
}
