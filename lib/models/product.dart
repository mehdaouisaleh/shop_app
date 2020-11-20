import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFavorite(String token, String userId) async {
    try {
      await http.put(
          'https://app11-85ed8.firebaseio.com/userFavorites/$userId/$id.json?auth=$token',
          body: json.encode(
            !isFavorite,
          ));
      isFavorite = !isFavorite;
      notifyListeners();
      Fluttertoast.showToast(
          msg: isFavorite ? 'Favorited' : ' Unfavorited',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey[600],
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (_) {
      print('favorite error : $_');
      throw 'error';
    }
  }
}
