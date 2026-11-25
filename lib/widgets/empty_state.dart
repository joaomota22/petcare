import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Estado visual para listas vazias, com ação opcional.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Space.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: p.raised,
                  borderRadius: BorderRadius.circular(Radii.card),
                  border: Border.all(color: p.border),
                ),
                child: Icon(icon, size: 24, color: p.muted),
              ),
              const SizedBox(height: Space.m),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: p.ink,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: Space.xs),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.muted, height: 1.45),
              ),
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: Space.l),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
