import 'package:flutter/material.dart';
import '../models/shame_app.dart';

class ShameAppCard extends StatelessWidget {
  final ShameApp app;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const ShameAppCard({
    super.key,
    required this.app,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: app.isEnabled
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            Icons.apps,
            color: app.isEnabled
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        title: Text(
          app.appName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: app.isEnabled ? null : Colors.grey,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              app.shameMessage,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: app.isEnabled ? null : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              app.packageName,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: app.isEnabled,
              onChanged: (_) => onToggle(),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Theme.of(context).colorScheme.error,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete App'),
                    content: Text('Remove ${app.appName} from the shame list?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
