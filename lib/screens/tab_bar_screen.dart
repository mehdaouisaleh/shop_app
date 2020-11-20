import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/orders_screen.dart';
import '../screens/product_overview_screen.dart';
import '../screens/user_products_screen.dart';

class TabBarScreen extends StatefulWidget {
  @override
  _TabBarScreenState createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarScreen> {
  List<Widget> screens = [
    ProductOverviewScreen(),
    OrderScreen(),
    UserProductsScreen()
  ];
  var _screenIndex = 0;
  void _changeScreen(int index) {
    setState(() {
      _screenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_screenIndex],
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        iconSize: 24,
        selectedFontSize: 18,
        unselectedFontSize: 16,
        selectedIconTheme: IconThemeData(size: 24),
        currentIndex: _screenIndex,
        onTap: (index) => _changeScreen(index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.check_mark_circled_solid),
              title: Text('Orders')),
          BottomNavigationBarItem(
              icon: Icon(Icons.featured_play_list), title: Text('User')),
        ],
      ),
    );
  }
}
