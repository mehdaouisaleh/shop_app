import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';

class TotalPriceCard extends StatelessWidget {
  const TotalPriceCard(
      {Key key, @required this.totalPrice, @required this.cartItems})
      : super(key: key);

  final double totalPrice;
  final List<CartItem> cartItems;

  @override
  Widget build(BuildContext context) {
    final ordersData = Provider.of<OrdersProvider>(context, listen: false);
    final cartData = Provider.of<CartProvider>(context, listen: false);

    void checkOut() {
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
      ordersData
          .addOrder(cartItems, totalPrice)
          .then((value) => {
                cartData.removeAllItems(),
                //  Navigator.of(_dialogContext).pop,
                Navigator.of(context).pop(),
              })
          .catchError((onError) {
        //handle error here
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

    return Card(
      elevation: 40,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0))),
      borderOnForeground: false,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(left: 10),
              child: Text(
                'Total',
                style: TextStyle(fontSize: 20),
              ),
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('\$${totalPrice}',
                  style: TextStyle(
                      fontFamily: 'Barlow',
                      color: Colors.green[300],
                      fontWeight: FontWeight.bold,
                      fontSize: 17)),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: FlatButton(
                child: Text(
                  'Check Out',
                  style: TextStyle(fontFamily: 'Barlow', fontSize: 16),
                ),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  checkOut();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
