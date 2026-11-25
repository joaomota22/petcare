import 'package:flutter/material.dart';

import '../app_theme.dart';

/// Estado "a carregar": cartões vazios com a forma do conteúdo, sem animação.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 4, this.itemHeight = 82});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(Space.m, Space.xs, Space.m, 96),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          height: itemHeight,
          margin: const EdgeInsets.only(bottom: Space.xs),
          decoration: BoxDecoration(
            color: p.raised,
            borderRadius: BorderRadius.circular(Radii.card),
          ),
        );
      },
    );
  }
}
