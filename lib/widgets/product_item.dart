import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../screens/product_detail_screen.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transparent_image/transparent_image.dart';

class ProductItem extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey;
  ProductItem(this._scaffoldKey);

  String id;

  String title;

  String description;

  double price;

  String imageUrl;

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    //final data = Provider.of<ProductProvider>(context, listen: false);
    final cartData = Provider.of<CartProvider>(context, listen: false);
    final authData = Provider.of<AuthProvider>(context);

    var screenSize = MediaQuery.of(context).size;

    id = product.id;
    title = product.title;
    description = product.description;
    price = product.price;
    imageUrl = product.imageUrl;

    return screenSize.height > 800 && screenSize.width > 800
        ? Card(
            elevation: .2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell(
              onTap: () {
                _scaffoldKey.currentState.hideCurrentSnackBar();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                          value: product,
                          builder: (___, child) => ProductDetailScreen(id),
                        )));
                // .pushNamed(ProductDetailScreen.namedRoute, arguments: id);
              },
              borderRadius: BorderRadius.circular(10.0),
              splashColor: Theme.of(context).accentColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0)),
                    child: Container(
                      child: FadeInImage.memoryNetwork(
                        placeholder: kTransparentImage,
                        image: imageUrl,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                      ),
                      height: 330,
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Colors.black),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        description,
                        style: TextStyle(color: Colors.black87, fontSize: 20),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '$price \$',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Consumer<Product>(
                                // to not rebuild the whole Widget
                                builder: (_, product, child) {
                              return IconButton(
                                iconSize: 30.0,
                                color: Theme.of(context).iconTheme.color,
                                icon: product.isFavorite
                                    ? Icon(Icons.favorite)
                                    : Icon(Icons.favorite_border),
                                onPressed: () {
                                  product.toggleFavorite(
                                      authData.token, authData.userId);
                                },
                                splashColor: Theme.of(context).accentColor,
                              );
                            }),
                            IconButton(
                                iconSize: 30.0,
                                color: Theme.of(context).iconTheme.color,
                                icon: Icon(Icons.add_shopping_cart),
                                onPressed: () {
                                  cartData.addItem(id, title, price, imageUrl);
                                  _scaffoldKey.currentState
                                      .hideCurrentSnackBar();

                                  _scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text('Product Added To Cart!'),
                                    action: SnackBarAction(
                                        label: 'UNDO',
                                        onPressed: () {
                                          if (int.parse(
                                                  cartData.getQuantity(id)) >
                                              1) {
                                            cartData.updateQuantity(id);
                                          } else
                                            cartData.removeItem(keyId: id);
                                        }),
                                  ));
                                },
                                splashColor: Theme.of(context).accentColor),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : Card(
            elevation: .2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell(
              onTap: () {
                _scaffoldKey.currentState.hideCurrentSnackBar();
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                          value: product,
                          builder: (___, child) => ProductDetailScreen(id),
                        )));
                // .pushNamed(ProductDetailScreen.namedRoute, arguments: id);
              },
              borderRadius: BorderRadius.circular(10.0),
              splashColor: Theme.of(context).accentColor,
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10.0),
                        topRight: Radius.circular(10.0)),
                    child: Container(
                      child: Hero(
                        tag: product.id,
                        child: FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: imageUrl,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                        ),
                      ),
                      height: 130,
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        description,
                        style: TextStyle(color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: FittedBox(
                            child: Text(
                              '$price \$',
                              overflow: TextOverflow.fade,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Consumer<Product>(

                                // to not rebuild the whole Widget
                                builder: (_, product, child) {
                              return FavoriteButton(
                                  product, authData.token, authData.userId);
                            }),
                            IconButton(
                                color: Theme.of(context).iconTheme.color,
                                icon: Icon(Icons.add_shopping_cart),
                                onPressed: () {
                                  cartData.addItem(id, title, price, imageUrl);
                                  _scaffoldKey.currentState
                                      .hideCurrentSnackBar();

                                  _scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text('Product Added To Cart!'),
                                    action: SnackBarAction(
                                        label: 'UNDO',
                                        onPressed: () {
                                          if (int.parse(
                                                  cartData.getQuantity(id)) >
                                              1) {
                                            cartData.updateQuantity(id);
                                          } else
                                            cartData.removeItem(keyId: id);
                                        }),
                                  ));
                                },
                                splashColor: Theme.of(context).accentColor),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

class FavoriteButton extends StatefulWidget {
  final Product product;
  final String token;
  final String userId;
  FavoriteButton(this.product, this.token, this.userId);

  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  var _buttonDisabled = false;

  void toggleButton() {
    setState(() {
      _buttonDisabled = !_buttonDisabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      color: Theme.of(context).iconTheme.color,
      icon: widget.product.isFavorite
          ? Icon(Icons.favorite)
          : Icon(Icons.favorite_border),
      onPressed: () => _buttonDisabled
          ? null
          : {
              toggleButton(),
              widget.product
                  .toggleFavorite(widget.token, widget.userId)
                  .then((value) => toggleButton()),
            },
      splashColor: Theme.of(context).accentColor,
    );
  }
}
