import 'package:flutter/material.dart';
import '../../models/kindness_giver.dart';

/// KindnessGiverのアバター表示ウィジェット
class KindnessGiverAvatar extends StatelessWidget {
  final KindnessGiver? kindnessGiver;
  final String? gender;
  final double size;
  final double? iconSize;
  final bool showCameraButton;

  const KindnessGiverAvatar({
    Key? key,
    this.kindnessGiver,
    this.gender,
    this.size = 60,
    this.iconSize,
    this.showCameraButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final genderValue = kindnessGiver?.gender ?? gender ?? '';
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
            child: _buildAvatarImage(avatarUrl, genderValue, theme),
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

  Widget _buildAvatarImage(String? avatarUrl, String gender, ThemeData theme) {
    // 1. ネットワーク画像がある場合
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // ネットワーク画像の読み込み失敗時はデフォルト画像を表示
          return _buildDefaultAvatar(gender, theme);
        },
      );
    }

    // 2. デフォルトアバター画像を表示
    return _buildDefaultAvatar(gender, theme);
  }

  Widget _buildDefaultAvatar(String gender, ThemeData theme) {
    final String assetPath = _getDefaultAvatarPath(gender);

    print('🖼️ Loading avatar: $assetPath for gender: $gender'); // デバッグログ

    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('❌ Asset load error: $error'); // エラーログ
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
            _getGenderIcon(gender),
            size: iconSize ?? size * 0.45,
            color: theme.colorScheme.primary.withOpacity(0.6),
          ),
        );
      },
    );
  }

  String _getDefaultAvatarPath(String gender) {
    switch (gender) {
      case '女性':
        return 'assets/images/default_female.png';
      case '男性':
        return 'assets/images/default_male.png';
      case 'ペット':
        return 'assets/images/default_pet.png';
      default:
        return 'assets/images/default_female.png'; // デフォルトとして女性画像を使用
    }
  }

  IconData _getGenderIcon(String gender) {
    switch (gender) {
      case '女性':
        return Icons.female;
      case '男性':
        return Icons.male;
      case 'ペット':
        return Icons.pets;
      default:
        return Icons.person;
    }
  }
}
