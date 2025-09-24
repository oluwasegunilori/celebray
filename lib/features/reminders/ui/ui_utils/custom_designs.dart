import 'package:flutter/material.dart';

class CustomExpansionTile extends StatelessWidget {
  final Widget title;
  final Widget child;
  final bool initiallyExpanded;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent, // removes the bottom divider
      ),
      child: ExpansionTile(
        title: title,
        tilePadding: EdgeInsets.zero, // remove left/right padding
        childrenPadding: EdgeInsets.zero, // remove inner padding
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        initiallyExpanded: initiallyExpanded,
        children: [child],
      ),
    );
  }
}

class SheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;

  const SheetHeader({super.key, required this.title, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Drag handle
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
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
