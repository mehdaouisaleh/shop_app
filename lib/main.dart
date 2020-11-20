import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/splash_screen.dart';

import './screens/product_overview_screen.dart';
import './screens/auth_screen.dart';
import './providers/orders_provider.dart';
import './providers/cart_provider.dart';
import './providers/product_provider.dart';
import './providers/scafold_key_provider.dart';
import './screens/cart_screen.dart';
import './screens/tab_bar_screen.dart';
import './screens/edit_product_screen.dart';
import './providers/auth_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider(),
          ),
          ChangeNotifierProxyProvider<AuthProvider, ProductProvider>(
            update: (_, authData, oldProvider) => ProductProvider(
                oldProvider == null ? [] : oldProvider.products,
                authData.token,
                authData.userId),
            create: (_) => null,
          ),
          ChangeNotifierProvider(
            create: (_) => CartProvider(),
          ),
          ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
            update: (_, authData, oldProvider) => OrdersProvider(
                oldProvider == null ? [] : oldProvider.orderItems,
                authData.token,
                authData.userId),
            create: (_) => null,
          ),
          ChangeNotifierProvider(
            create: (_) => ScafoldKeyProvider(),
          )
        ],
        child: Consumer<AuthProvider>(
          builder: (_, authData, __) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Shop App',
            theme: ThemeData(
              buttonTheme: ButtonThemeData(
                splashColor: Colors.black54,
                highlightColor: Colors.black12,
              ),
              iconTheme: IconThemeData(color: Color(0xffffbcaa)),
              primaryColor: Color(0xffffbcaa),
              accentColor: Colors.red[100],
              fontFamily: 'Barlow',
            ),
            home: authData.isAuth
                ? TabBarScreen()
                : FutureBuilder(
                    future: authData.tryAutoLogin(),
                    builder: (_, authResultSanpshot) =>
                        authResultSanpshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()), // TabBarScreen(),
            routes: {
              //   ProductDetailScreen.namedRoute: (_) => ProductDetailScreen(),
              CartScreen.namedRoute: (_) => CartScreen(),
              EditProductScreen.namedRoute: (_) => EditProductScreen(),
            },
          ),
        ));
  }
}
