import 'package:flutter/material.dart';
import '../models/shame_app.dart';
import '../services/storage_service.dart';

class AddAppScreen extends StatefulWidget {
  const AddAppScreen({super.key});

  @override
  State<AddAppScreen> createState() => _AddAppScreenState();
}

class _AddAppScreenState extends State<AddAppScreen> {
  final _formKey = GlobalKey<FormState>();
  final _packageNameController = TextEditingController();
  final _appNameController = TextEditingController();
  final _shameMessageController = TextEditingController();

  @override
  void dispose() {
    _packageNameController.dispose();
    _appNameController.dispose();
    _shameMessageController.dispose();
    super.dispose();
  }

  Future<void> _saveApp() async {
    if (_formKey.currentState!.validate()) {
      final app = ShameApp(
        packageName: _packageNameController.text.trim(),
        appName: _appNameController.text.trim(),
        shameMessage: _shameMessageController.text.trim(),
      );

      await StorageService.addShameApp(app);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add App to Shame'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'App Details',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _packageNameController,
                        decoration: const InputDecoration(
                          labelText: 'Package Name',
                          hintText: 'com.example.app',
                          prefixIcon: Icon(Icons.apps),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a package name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _appNameController,
                        decoration: const InputDecoration(
                          labelText: 'App Name',
                          hintText: 'Example App',
                          prefixIcon: Icon(Icons.label),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an app name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _shameMessageController,
                        decoration: const InputDecoration(
                          labelText: 'Shame Message',
                          hintText: 'Stop wasting time!',
                          prefixIcon: Icon(Icons.message),
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a shame message';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'How to find package name',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1. Open the app in Google Play Store\n'
                        '2. Look at the URL: play.google.com/store/apps/details?id=PACKAGE_NAME\n'
                        '3. Copy the package name after "id="\n\n'
                        'Example: com.instagram.android',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveApp,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text('Add to Shame List'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
