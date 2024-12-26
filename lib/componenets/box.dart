import 'package:flutter/material.dart';

class Box extends StatelessWidget {
  final Widget? child;
  final Color? backgroundColor;
  const Box({super.key, this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: double.infinity,
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade500,
                blurRadius: 15,
                offset: Offset(-2, -2)),
          ]),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}
