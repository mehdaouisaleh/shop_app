import 'package:flutter/material.dart';

class CartItem {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final String imageUrl;
  CartItem({
    @required this.id,
    @required this.price,
    @required this.title,
    @required this.quantity,
    this.imageUrl,
  });

  CartItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        price = json['price'],
        quantity = json['quantity'],
        imageUrl = json['imageUrl'];

  Map<String, dynamic> get getJson {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl
    };
  }
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _cartItems = {};

  Map<String, CartItem> get cartItems {
    return {..._cartItems};
  }

  double totalPrice() {
    double price = 0.0;
    _cartItems.forEach((key, value) {
      price = price + value.price * value.quantity;
    });
    return price;
  }

  int itemsCount() {
    int quantity = 0;
    _cartItems.forEach((key, value) {
      quantity = quantity + value.quantity;
    });
    return quantity;
  }

  String getQuantity(String id) {
    int quantity = 0;
    _cartItems.forEach((key, value) {
      if (key == id) quantity = value.quantity;
      return;
    });

    return quantity.toString();
  }

  void addItem(String productId, String title, double price, String imageUrl) {
    if (_cartItems.containsKey(productId)) {
      _cartItems.update(
        productId,
        (value) => CartItem(
            id: value.id,
            title: value.title,
            price: value.price,
            quantity: value.quantity + 1,
            imageUrl: imageUrl),
      );
    } else {
      _cartItems.putIfAbsent(
          productId,
          () => CartItem(
              id: productId,
              title: title,
              price: price,
              quantity: 1,
              imageUrl: imageUrl));
    }
    notifyListeners();
  }

  void removeItem({String productId, String keyId}) {
    //_cartItems.remove(productId);
    productId == null
        ? _cartItems.removeWhere((key, value) => key == keyId)
        : _cartItems.removeWhere((key, value) => value.id == productId);
    notifyListeners();
  }

  void removeAllItems() {
    _cartItems.clear();
    notifyListeners();
  }

  void updateQuantity(String id) {
    _cartItems.update(
        id,
        (value) => CartItem(
            id: value.id,
            price: value.price,
            title: value.title,
            imageUrl: value.imageUrl,
            quantity: value.quantity - 1));
    notifyListeners();
  }
}
