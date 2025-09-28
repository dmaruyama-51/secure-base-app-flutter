// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../models/kindness_giver.dart';

/// KindnessGiverのアバター表示ウィジェット
class KindnessGiverAvatar extends StatelessWidget {
  final KindnessGiver? kindnessGiver;
  final String? gender;
  final String? relationship;
  final double size;
  final double? iconSize;
  final bool showCameraButton;

  const KindnessGiverAvatar({
    Key? key,
    this.kindnessGiver,
    this.gender,
    this.relationship,
    this.size = 60,
    this.iconSize,
    this.showCameraButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final genderValue = kindnessGiver?.genderName ?? gender ?? '';
    final relationshipValue =
        kindnessGiver?.relationshipName ?? relationship ?? '';
    final avatarUrl = kindnessGiver?.avatarUrl;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(size / 2)),
      child: Stack(
        children: [
          // メインのアバター画像
          ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: _buildAvatarImage(
              avatarUrl,
              genderValue,
              relationshipValue,
              theme,
            ),
          ),

          // カメラボタン（将来機能）
          if (showCameraButton)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(size * 0.16),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: size * 0.16,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(
    String? avatarUrl,
    String gender,
    String relationship,
    ThemeData theme,
  ) {
    // 1. ネットワーク画像がある場合
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // ネットワーク画像の読み込み失敗時はデフォルト画像を表示
          return _buildDefaultAvatar(gender, relationship, theme);
        },
      );
    }

    // 2. デフォルトアバター画像を表示
    return _buildDefaultAvatar(gender, relationship, theme);
  }

  Widget _buildDefaultAvatar(
    String gender,
    String relationship,
    ThemeData theme,
  ) {
    final String assetPath = _getDefaultAvatarPath(gender, relationship);

    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // アセット画像も読み込めない場合はアイコンで代替
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.3),
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Icon(
            _getAvatarIcon(gender, relationship),
            size: iconSize ?? size * 0.45,
            color: theme.colorScheme.primary.withOpacity(0.6),
          ),
        );
      },
    );
  }

  String _getDefaultAvatarPath(String gender, String relationship) {
    // ペットの場合は関係性で判定
    if (relationship == 'ペット' ||
        relationship == 'pet' ||
        relationship.toLowerCase() == 'pet') {
      return 'assets/images/default_pet.png';
    }

    // それ以外は性別で判定（様々な形式に対応）
    final genderLower = gender.toLowerCase();
    switch (genderLower) {
      case '男性':
      case 'male':
      case 'man':
      case 'm':
        return 'assets/images/default_male.png';
      case '女性':
      case 'female':
      case 'woman':
      case 'f':
        return 'assets/images/default_female.png';
      default:
        return 'assets/images/default_female.png'; // デフォルトとして女性画像を使用
    }
  }

  IconData _getAvatarIcon(String gender, String relationship) {
    // ペットの場合は関係性で判定
    if (relationship == 'ペット' ||
        relationship == 'pet' ||
        relationship.toLowerCase() == 'pet') {
      return Icons.pets;
    }

    // それ以外は性別で判定（様々な形式に対応）
    final genderLower = gender.toLowerCase();
    switch (genderLower) {
      case '男性':
      case 'male':
      case 'man':
      case 'm':
        return Icons.male;
      case '女性':
      case 'female':
      case 'woman':
      case 'f':
        return Icons.female;
      default:
        return Icons.person;
    }
  }
}
