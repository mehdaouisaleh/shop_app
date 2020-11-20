import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final products_url = 'https://app11-85ed8.firebaseio.com/products.json';
  List<Product> _products = [];
  final String _token;
  final String _userId;

  ProductProvider(this._products, this._token, this._userId);

  Product findById(String id) {
    return _products.firstWhere((prod) => prod.id == id);
  }

  List<Product> get favorites {
    return _products.where((element) => element.isFavorite).toList();
  }

  List<Product> get products {
    return [..._products];
  }

  // void removeFav(id) {
  //   http.patch('https://app11-85ed8.firebaseio.com/products/$id.json',
  //       body: json.encode({
  //         'isFavorite': false,
  //       }));
  //   _products.firstWhere((element) => element.id == id).isFavorite = false;
  //   notifyListeners();
  // }

  // void addFav(id) {
  //   http.patch('https://app11-85ed8.firebaseio.com/products/$id.json',
  //       body: json.encode({
  //         'isFavorite': true,
  //       }));
  //   _products.firstWhere((element) => element.id == id).isFavorite = true;
  //   notifyListeners();
  // }

// first methode using Future then() methode.

  // Future<void> addProduct(Product p)  {
  //   final url = 'https://app11-85ed8.firebaseio.com/products.json';
  //   http.post(url,
  //           body: json.encode({
  //             'title': p.title,
  //             'description': p.description,
  //             'price': p.price,
  //             'imageUrl': p.imageUrl,
  //             'isFavorite': p.isFavorite,
  //           }))
  //       .then((value) {
  //     final product = Product(
  //         id: json.decode(value.body)['name'],
  //         title: p.title,
  //         description: p.description,
  //         price: p.price,
  //         imageUrl: p.imageUrl);
  //     _products.add(product);
  //     notifyListeners();
  //   });
  // }

  //second method using Async Await

  Future<void> getProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? '&orderBy="creatorId"&equalTo="$_userId"' : '';

    try {
      final response =
          await http.get('$products_url?auth=$_token$filterString');

      final favoriteResponse = await http.get(
          'https://app11-85ed8.firebaseio.com/userFavorites/$_userId/.json?auth=$_token');

      final object = json.decode(response.body) as Map<String, dynamic>;
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> _loadedProducts = [];

      if (object != null) {
        object.length == 0
            ? _products = _loadedProducts
            : object.forEach((key, value) {
                _loadedProducts.add(Product(
                    id: key,
                    isFavorite: favoriteData == null
                        ? false
                        : favoriteData[key] ?? false,
                    title: value['title'],
                    description: value['description'],
                    price: value['price'],
                    imageUrl: value['imageUrl']));

                _products = _loadedProducts;
                notifyListeners();
              });
      }
    } catch (err) {
      throw err;
    }
  }

  Future<void> addProduct(Product p) async {
    try {
      final response = await http.post('$products_url?auth=$_token',
          body: json.encode({
            'title': p.title,
            'description': p.description,
            'price': p.price,
            'imageUrl': p.imageUrl,
            'isFavorite': p.isFavorite,
            'creatorId': _userId,
          }));
      final product = Product(
          id: json.decode(response.body)['name'],
          title: p.title,
          description: p.description,
          price: p.price,
          imageUrl: p.imageUrl);
      _products.add(product);
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> editProduct(Product p) async {
    try {
      await http.patch(
          '${products_url.replaceFirst(new RegExp(r'.json'), '')}/${p.id}.json?auth=$_token',
          body: json.encode({
            'title': p.title,
            'description': p.description,
            'price': p.price,
            'imageUrl': p.imageUrl,
          }));

      var index = _products.indexOf(findById(p.id));
      _products.replaceRange(index, index + 1, [
        Product(
            id: p.id,
            title: p.title,
            description: p.description,
            price: p.price,
            imageUrl: p.imageUrl),
      ]);
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> removeProduct(String id) {
    var index = _products.indexOf(findById(id));
    Product product = _products[index];
    _products.removeAt(index);

    return http
        .delete(
            '${products_url.replaceFirst(new RegExp(r'.json'), '')}/$id.json?auth=$_token')
        .then((value) => value.statusCode >= 400 // error status code
            ? {
                _products.insert(index, product),
                throw 'error',
              }
            : {
                http
                    .delete(
                        'https://app11-85ed8.firebaseio.com/userFavorites/$_userId/$id.json?auth=$_token')
                    .then((value) => {
                          product = null,
                          index = null,
                          notifyListeners(),
                        }),
              })
        .catchError((_) {
      _products.insert(index, product);
      throw 'error';
    });
  }

  //   Product(
  //     id: 'p1',
  //     title: 'Red Shirt',
  //     description: 'A red shirt - it is pretty red!',
  //     price: 29.99,
  //     imageUrl:
  //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  //   ),
  //   Product(
  //     id: 'p2',
  //     title: 'Trousers',
  //     description: 'A nice pair of trousers.',
  //     price: 59.99,
  //     imageUrl:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
  //   ),
  //   Product(
  //     id: 'p3',
  //     title: 'Yellow Scarf Yellow Scarf Yellow Scarf Yellow Scarf Yellow Scarf',
  //     description:
  //         'Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.Warm and cozy - exactly what you need for the winter.\nWarm and cozy - exactly what you need for the winter.',
  //     price: 19.99,
  //     imageUrl:
  //         'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
  //   ),
  //   Product(
  //     id: 'p4',
  //     title: 'A Pan',
  //     description: 'Prepare any meal you want.',
  //     price: 49.99,
  //     imageUrl:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
  //   ),
  // ];
}
