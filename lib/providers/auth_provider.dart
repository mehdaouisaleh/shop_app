import 'dart:async';

import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/http_request_execption.dart';

class AuthProvider with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _autoTimer;
  bool get isAuth {
    return _token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    try {
      final response = await http.post(
          'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyB0Ky0ikM8A8JTGp7KQ1X-Er9iN5d_I0ts',
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseBody = json.decode(response.body);
      if (responseBody['error'] != null)
        throw HttpExecption(responseBody['error']['message']);

      // response is correctly handled
      _token = responseBody['idToken'];
      _userId = responseBody['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseBody['expiresIn'])));
      autoLogout();
      //
      notifyListeners();
      //
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      prefs.setString('userData', userData);
    } catch (_) {
      throw _;
    }
  }

  Future<bool> tryAutoLogin() async {
 
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
     
      return false;
    }

    final extractedData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
  
      return false;
    }
  
    _token = extractedData['token'];
    _userId = extractedData['userId'];
    _expiryDate = DateTime.parse(extractedData['expiryDate']);
    autoLogout();
    notifyListeners();
    return true;
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  void logout() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_autoTimer != null) {
      _autoTimer.cancel();
      _autoTimer = null;
    }

    notifyListeners();
  }

  void autoLogout() {
    if (_autoTimer != null) {
      _autoTimer.cancel();
    }
    final expiryTime = _expiryDate.difference(DateTime.now()).inSeconds;
    _autoTimer = Timer(Duration(seconds: expiryTime), logout);
  }
}
