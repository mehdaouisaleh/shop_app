import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart' show CartProvider;
import '../widgets/price_card.dart';
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static String namedRoute = '/cart_screen';

  @override
  Widget build(BuildContext context) {
  
    final cartData = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
        actions: [
          FlatButton(
            padding: EdgeInsets.zero,
            child: Text(
              'Clear',
              style: TextStyle(
                  fontFamily: 'Barlow',
                  fontSize: 18,
                  fontWeight: FontWeight.normal),
            ),
            onPressed: () {
              cartData.removeAllItems();
              Navigator.of(context).pop();
            },
          )
        ],
      ),
      body: Stack(children: [
        ListView.builder(
          itemBuilder: (_, index) =>
              CartItems(cartData.cartItems.values.toList()[index]),
          itemCount: cartData.cartItems.length,
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: TotalPriceCard(
            totalPrice: cartData.totalPrice(),
            cartItems: cartData.cartItems.values.toList(),
          ),
        ),
      ]),
    );
  }
}
