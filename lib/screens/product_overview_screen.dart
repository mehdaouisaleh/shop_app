import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth_provider.dart';

import '../providers/cart_provider.dart';

import '../widgets/badge.dart';
import '../providers/product_provider.dart';
import '../widgets/gridview_builder.dart';
import '../screens/cart_screen.dart';

enum PopupItem {
  Favorites,
  All,
}

class ProductOverviewScreen extends StatefulWidget {
  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var onlyFav = false;
  String title = 'Home';
  var _init = true;
  var _isLoading = true;
  Widget cartIconBuilder() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Icon(Icons.shopping_cart),
    );
  }

  @override
  void didChangeDependencies() {
    if (_init)
      Provider.of<ProductProvider>(context).getProducts().then((value) {
        setState(() {
          _isLoading = false;
        });
      }).catchError((_) {
        setState(() {
          _isLoading = false;
        });
      });
    _init = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Shop App'),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).logout();
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(title),
        actions: <Widget>[
          PopupMenuButton(
              tooltip: 'Menu',
              onSelected: (value) {
                setState(() {
                  switch (value) {
                    case PopupItem.Favorites:
                      onlyFav = true;
                      title = 'Favorites';
                      break;
                    case PopupItem.All:
                      onlyFav = false;
                      title = 'Home';
                      break;
                  }
                });
              },
              itemBuilder: (_) => [
                    PopupMenuItem(
                      child: Text('Favorites'),
                      value: PopupItem.Favorites,
                    ),
                    PopupMenuItem(
                      child: Text('All'),
                      value: PopupItem.All,
                    ),
                  ]),
          Consumer<CartProvider>(
            builder: (_, cart, child) => Badge(
              child: child,
              value: cart.itemsCount().toString(),
              onPressed: () {
                if (cart.itemsCount() > 0) {
                  _scaffoldKey.currentState.hideCurrentSnackBar();
                  Navigator.of(context).pushNamed(CartScreen.namedRoute);
                }
              },
            ),
            child: cartIconBuilder(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GridViewBuilder(onlyFav, _scaffoldKey),
    );
  }
}
