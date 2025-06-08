import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/tutorial_repository.dart';

final tutorialRepositoryProvider = Provider<TutorialRepository>((ref) {
  return TutorialRepository();
});
