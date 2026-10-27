import 'package:flutter/material.dart';

class Fill extends StatelessWidget {
  final List<Widget> children;
  const Fill({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                child: Column(children: children),
              ),
            ),
          ),
        );
      },
    );
  }
}
