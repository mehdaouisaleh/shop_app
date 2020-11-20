import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../widgets/badge.dart';
import './product_overview_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProductDetailScreen extends StatefulWidget {
  static String namedRoute = '/product_detail_screen';
  final String productId;

  ProductDetailScreen(this.productId);

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  var _buttonDisabled = false;
  void toggleButton() {
    setState(() {
      _buttonDisabled = !_buttonDisabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final productId = ModalRoute.of(context).settings.arguments as String;
    final cartData = Provider.of<CartProvider>(context);
    final authData = Provider.of<AuthProvider>(context);
    final loadedProduct = Provider.of<ProductProvider>(
      context,
    ).findById(widget.productId);
    final ordersData = Provider.of<OrdersProvider>(context, listen: false);
    //  final data = Provider.of<ProductProvider>(context);
    void buyNow(Product product) {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (ctx) {
            return AlertDialog(
              content: Container(
                height: 150,
                width: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
          });
      DateTime date = DateTime.now();
      ordersData
          .buyNow(CartItem(
              id: date.toString(),
              price: product.price,
              title: product.title,
              imageUrl: product.imageUrl,
              quantity: int.parse(cartData.getQuantity(widget.productId)) + 1))
          .then((value) => {
                cartData.removeItem(keyId: widget.productId),
                Navigator.of(context).pop(),
              })
          .catchError((onError) {
        Fluttertoast.cancel();
        Fluttertoast.showToast(
            msg: 'An error has accured',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey[600],
            textColor: Colors.white,
            fontSize: 16.0);
      }).whenComplete(
        () => Navigator.of(context).pop(),
      );
    }

    Widget buyButtonBuilder() => Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 12),
          child: FlatButton(
            padding: EdgeInsets.zero,
            onPressed: () => buyNow(loadedProduct),
            color: Theme.of(context).accentColor,
            child: Text('Buy Now'),
          ),
        );

    return Scaffold(
        body: Stack(
      children: [
        CustomScrollView(slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      child: Hero(
                        tag: loadedProduct.id,
                        child: Image.network(loadedProduct.imageUrl,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height),
                      ),
                    ),
                    Container(
                      height: 300,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          gradient: LinearGradient(
                              begin: FractionalOffset.bottomCenter,
                              end: FractionalOffset.topCenter,
                              colors: [
                                Colors.white.withOpacity(0.0),
                                Colors.white.withOpacity(.3),
                              ],
                              stops: [
                                0.0,
                                1.0
                              ])),
                    ),
                  ],
                )),
            actions: [
              Consumer<Product>(
                builder: (_, loadedProduct, ___) => IconButton(
                  splashColor: Colors.black54,
                  highlightColor: Colors.black12,
                  icon: loadedProduct.isFavorite
                      ? Icon(Icons.favorite)
                      : Icon(Icons.favorite_border),
                  onPressed: () => _buttonDisabled
                      ? null
                      : {
                          toggleButton(),
                          loadedProduct
                              .toggleFavorite(authData.token, authData.userId)
                              .then((value) => toggleButton()),
                        },
                ),
              ),
              Consumer<CartProvider>(
                builder: (_, cartProvider, __) => Badge(
                  onPressed: () {
                    cartData.addItem(widget.productId, loadedProduct.title,
                        loadedProduct.price, loadedProduct.imageUrl);
                  },
                  value: cartData.getQuantity(widget.productId),
                  child: IconButton(
                    padding: const EdgeInsets.all(16.0),
                    splashColor: Colors.black54,
                    highlightColor: Colors.black12,
                    icon: Icon(Icons.shopping_basket),
                    onPressed: () {
                      cartData.addItem(widget.productId, loadedProduct.title,
                          loadedProduct.price, loadedProduct.imageUrl);
                    },
                  ),
                ),
              )
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: 10, bottom: 16, right: 20, left: 20),
                      child: Container(
                        child: Text(
                          loadedProduct.title,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.fade,
                          softWrap: true,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      '\$ ${loadedProduct.price}',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                          fontFamily: 'Barlow'),
                    ),
                  ),
                ],
              ),

              Padding(
                padding:
                    EdgeInsets.only(top: 10, bottom: 16, right: 20, left: 20),
                child: Container(
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      Flexible(
                        child: Text(
                          loadedProduct.description,
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold),
                          overflow: TextOverflow.clip,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              //  buyButtonBuilder()
            ]),
          ),
        ]),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.black,
                gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.0),
                      Colors.white.withOpacity(0.6),
                    ],
                    stops: [
                      0.0,
                      1.0
                    ])),
          ),
        ),
        Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: buyButtonBuilder(),
            )),
      ],
    ));
  }
}
