import 'package:flutter/material.dart';

class SheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;

  const SheetHeader({super.key, required this.title, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
