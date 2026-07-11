import 'package:flutter/material.dart';
import 'package:reseller_app_tav/core/theme/negosiasi_theme.dart';
import 'package:reseller_app_tav/features/dashboard/providers/negosiasi_provider.dart';

class CollapsedFloatingAction extends StatefulWidget {
  final NegotiationProvider provider;
  final VoidCallback onOpenPanel;
  final VoidCallback onCreateTap;

  const CollapsedFloatingAction({
    super.key,
    required this.provider,
    required this.onOpenPanel,
    required this.onCreateTap,
  });

  @override
  State<CollapsedFloatingAction> createState() =>
      _CollapsedFloatingActionState();
}

class _CollapsedFloatingActionState extends State<CollapsedFloatingAction>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 8.0, end: -4.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 4.0, end: 0.0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );

    if (widget.provider.totalNewNegotiations > 0) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void didUpdateWidget(covariant CollapsedFloatingAction oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.provider.totalNewNegotiations >
            oldWidget.provider.totalNewNegotiations &&
        widget.provider.totalNewNegotiations > 0) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: "fab_create_negosiasi",
            backgroundColor: NegotiationTheme.colorRed,
            elevation: 4,
            onPressed: widget.onCreateTap,
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),

          Material(
            color: NegotiationTheme.colorCardBg,
            elevation: 4,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: widget.onOpenPanel,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: NegotiationTheme.colorBorder,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.forum_rounded,
                          color: NegotiationTheme.colorGold,
                          size: 20,
                        ),
                        if (widget.provider.totalNewNegotiations > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: NegotiationTheme.colorRed,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      "List Negosiasi",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
