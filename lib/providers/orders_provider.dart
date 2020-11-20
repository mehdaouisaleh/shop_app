import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/cart_provider.dart';

class OrderItem {
  final String id;
  final DateTime dateAdded;
  final double amount;
  final List<CartItem> cartItems;
  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.cartItems,
      @required this.dateAdded});
}

class OrdersProvider with ChangeNotifier {
  List<OrderItem> _orderItems = [];

  List<OrderItem> get orderItems => [..._orderItems];
  final orders_url = 'https://app11-85ed8.firebaseio.com/orders';
  final String _token;
  final String _userId;

  OrdersProvider(this._orderItems, this._token, this._userId);

  Future<void> getOrders() async {
    try {
      final response = await http.get('$orders_url/$_userId.json?auth=$_token');
      final object = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> _loadedOrders = [];
      if (object != null) {
        object.forEach((key, value) {
          final list = (value['cartItems'] as List<dynamic>)
              .map((e) => CartItem(
                  id: e['id'],
                  price: e['price'],
                  quantity: e['quantity'],
                  title: e['title'],
                  imageUrl: e['imageUrl']))
              .toList();

          _loadedOrders.add(OrderItem(
              id: key,
              amount: value['amount'],
              cartItems: list,
              dateAdded: DateTime.parse(value['dateAdded'])));
        });
      }
      _orderItems = _loadedOrders.reversed.toList();
      notifyListeners();
    } catch (_) {
      throw _;
    }
  }

  Future<void> addOrder(List<CartItem> cartItems, double amount) async {
    try {
      final timeStamp = DateTime.now();
      await http
          .post('$orders_url/$_userId.json?auth=$_token',
              body: json.encode({
                'amount': amount,
                'cartItems': cartItems.map((e) => e.getJson).toList(),
                'dateAdded': timeStamp.toIso8601String(),
              }))
          .then((response) {
        _orderItems.insert(
            0,
            OrderItem(
                id: json.decode(response.body)['name'],
                amount: amount,
                cartItems: cartItems,
                dateAdded: timeStamp));
        notifyListeners();
      });
    } catch (_) {
      throw _;
    }
  }

  Future<void> buyNow(
    CartItem product,
  ) async {
    try {
      final timeStamp = DateTime.now();
      await http
          .post('$orders_url/$_userId.json?auth=$_token',
              body: json.encode({
                'amount': product.price * product.quantity,
                'cartItems': [product.getJson],
                'dateAdded': timeStamp.toIso8601String(),
              }))
          .then((response) {
        _orderItems.insert(
            0,
            OrderItem(
                id: json.decode(response.body)['name'],
                amount: product.price * product.quantity,
                cartItems: [product],
                dateAdded: timeStamp));
        notifyListeners();
      });
    } catch (_) {
      throw _;
    }
  }
}
