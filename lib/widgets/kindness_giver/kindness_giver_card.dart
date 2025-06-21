// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/kindness_giver_model.dart';
import 'kindness_giver_avatar.dart';
import 'kindness_giver_info_chip.dart';

/// メンバーカード表示ウィジェット
class KindnessGiverCard extends StatefulWidget {
  final KindnessGiver kindnessGiver;
  final VoidCallback? onTap;

  const KindnessGiverCard({Key? key, required this.kindnessGiver, this.onTap})
    : super(key: key);

  @override
  State<KindnessGiverCard> createState() => _KindnessGiverCardState();
}

class _KindnessGiverCardState extends State<KindnessGiverCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: (_) {
                setState(() => _isPressed = true);
                _animationController.forward();
              },
              onTapUp: (_) {
                setState(() => _isPressed = false);
                _animationController.reverse();
              },
              onTapCancel: () {
                setState(() => _isPressed = false);
                _animationController.reverse();
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.03),
                      blurRadius: 16,
                      offset: const Offset(0, 3),
                      spreadRadius: 1,
                    ),
                  ],
                  border: Border.all(
                    color:
                        _isPressed
                            ? theme.colorScheme.primary.withOpacity(0.15)
                            : theme.colorScheme.secondary.withOpacity(0.6),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    // アバターセクション
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: KindnessGiverAvatar(
                        kindnessGiver: widget.kindnessGiver,
                        size: 44,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // メンバー情報セクション
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.kindnessGiver.giverName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: theme.colorScheme.onSurface,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary.withOpacity(
                                        0.08,
                                      ),
                                      theme.colorScheme.primary.withOpacity(
                                        0.05,
                                      ),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                  ),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 10,
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: KindnessGiverInfoChip(
                              kindnessGiver: widget.kindnessGiver,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
