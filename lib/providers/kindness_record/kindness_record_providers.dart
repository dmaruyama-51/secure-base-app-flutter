import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../repositories/kindness_record_repository.dart';

/// やさしさ記録のRepositoryプロバイダー
final kindnessRecordRepositoryProvider = Provider<KindnessRecordRepository>((ref) {
  return KindnessRecordRepository();
}); 