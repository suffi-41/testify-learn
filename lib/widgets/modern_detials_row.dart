import 'package:flutter/material.dart';

class ModernDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const ModernDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label, style: Theme.of(context).textTheme.labelLarge),
        subtitle: Text(value, style: Theme.of(context).textTheme.labelLarge),
      ),
    );
  }
}
