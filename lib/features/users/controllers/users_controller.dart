// ✅ V2

import 'package:flutter/foundation.dart';
import 'package:ventro_app/features/auth/models/auth_model.dart';
import 'package:ventro_app/features/users/services/user_service.dart';

enum UsersStatus { idle, loading, success, error }

class UsersController extends ChangeNotifier {
  final UserService _service;
  UsersController(this._service);

  List<UserModel> _users = [];
  UsersStatus _status = UsersStatus.idle;
  String? _error;

  List<UserModel> get users => _users;
  UsersStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == UsersStatus.loading;

  // ── Filtro local por nombre/número ──────────────────────────────────────
  String _query = '';
  String get query => _query;

  List<UserModel> get filtered {
    if (_query.isEmpty) return _users;
    final q = _query.toLowerCase();
    return _users.where((u) {
      return u.name.toLowerCase().contains(q) ||
          (u.employeeNumber?.toLowerCase().contains(q) ?? false) ||
          u.email.toLowerCase().contains(q);
    }).toList();
  }

  void setQuery(String v) {
    _query = v;
    notifyListeners();
  }

  // ── CRUD ────────────────────────────────────────────────────────────────
  Future<void> load() async {
    _status = UsersStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _users = await _service.getAll();
      _status = UsersStatus.success;
    } catch (e) {
      _error = e.toString();
      _status = UsersStatus.error;
    }
    notifyListeners();
  }

  Future<UserModel?> create(Map<String, dynamic> data) async {
    _status = UsersStatus.loading; // ← agregar
    _error = null; // ← agregar
    notifyListeners(); // ← agregar
    try {
      final user = await _service.create(data);
      _users = [user, ..._users];
      _status = UsersStatus.success; // ← agregar
      notifyListeners();
      return user;
    } catch (e) {
      _error = e.toString();
      _status = UsersStatus.error; // ← agregar
      notifyListeners();
      return null;
    }
  }

  Future<UserModel?> update(int id, Map<String, dynamic> data) async {
    _status = UsersStatus.loading; // ← agregar
    _error = null; // ← agregar
    notifyListeners(); // ← agregar
    try {
      final updated = await _service.update(id, data);
      _users = _users.map((u) => u.id == id ? updated : u).toList();
      _status = UsersStatus.success; // ← agregar
      notifyListeners();
      return updated;
    } catch (e) {
      _error = e.toString();
      _status = UsersStatus.error; // ← agregar
      notifyListeners();
      return null;
    }
  }

  Future<bool> delete(int id) async {
    try {
      await _service.delete(id);
      _users = _users.where((u) => u.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleActivo(int id) async {
    try {
      final updated = await _service.toggleActivo(id);
      _users = _users.map((u) => u.id == id ? updated : u).toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
