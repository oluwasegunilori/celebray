import 'package:flutter/material.dart';

class AppExpansionTile extends StatelessWidget {
  final Widget title;
  final Widget child;
  final bool initiallyExpanded;
  final ExpansibleController? controller;

  const AppExpansionTile({
    super.key,
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        controller: controller,
        title: title,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        initiallyExpanded: initiallyExpanded,
        children: [child],
      ),
    );
  }
}
