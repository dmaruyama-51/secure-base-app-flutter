import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/kindness_giver_repository.dart';

/// やさしさをくれる人のRepositoryプロバイダー
final kindnessGiverRepositoryProvider = Provider<KindnessGiverRepository>((ref) {
  return KindnessGiverRepository();
}); 