import 'package:flutter/material.dart';

/// Estado "a carregar": cartões de esqueleto a pulsar.
class SkeletonList extends StatefulWidget {
  const SkeletonList({super.key, this.itemCount = 4, this.itemHeight = 92});

  final int itemCount;
  final double itemHeight;

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Container(
              height: widget.itemHeight,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Color.lerp(
                  const Color(0xFFEDEBF5),
                  const Color(0xFFF9F8FD),
                  _controller.value,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            );
          },
        );
      },
    );
  }
}
