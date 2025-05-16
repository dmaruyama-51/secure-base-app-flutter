import 'dart:async';
import 'package:flutter/material.dart';
import '../models/member.dart';
import '../repositories/member_repository.dart';

class MemberListViewModel extends ChangeNotifier {
  final MemberRepository _repository = MemberRepository();

  List<Member> _members = [];
  bool _isLoading = false; // データ読み込み中フラグ
  String? _error;

  List<Member> get members => _members;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // メンバー一覧の読み込み
  Future<void> loadMembers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _members = await _repository.fetchMembers();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
