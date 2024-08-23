import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  int? _idMitra;
  bool _isLoggedIn = false;
  int? _fieldId;

  int? get idMitra => _idMitra;
  bool get isLoggedIn => _isLoggedIn;
  int? get fieldId => _fieldId;

  void setIdMitra(int? id) {
    _idMitra = id;
    _isLoggedIn = true;
    notifyListeners();
  }

  void setFieldId(int? id) {
    _fieldId = id;
    notifyListeners();
  }

  void logout() {
    _idMitra = null;
    _isLoggedIn = false;
    _fieldId = null;
    notifyListeners();
  }
}
