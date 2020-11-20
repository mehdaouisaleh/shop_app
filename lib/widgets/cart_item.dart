import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../providers/cart_provider.dart';

class CartItems extends StatelessWidget {
  final CartItem cartItem;
  CartItems(this.cartItem);
 
  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<CartProvider>(context, listen: false);
    return Dismissible(
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        cartData.removeItem(productId: cartItem.id);
        if (cartData.cartItems.length == 0) Navigator.of(context).pop();
      },
      confirmDismiss: (_) => showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('Confirm'),
                content: SingleChildScrollView(
                    child: Text('Do you want remove this Cart item ?')),
                actions: [
                  FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(false);
                      },
                      child: Text('No')),
                  FlatButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(true);
                      },
                      child: Text('Yes'))
                ],
              )),
      background: Container(
        color: Colors.redAccent,
        child: Align(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Icon(
              Icons.delete,
            ),
          ),
          alignment: Alignment.centerRight,
        ),
      ),
      key: Key(cartItem.id),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(
            cartItem.title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '\$ ${cartItem.price}',
            style: TextStyle(
              color: Colors.black45,
              fontFamily: 'Barlow',
              fontSize: 16,
            ),
          ),
          isThreeLine: true,
          trailing: Column(children: [
            Text('${cartItem.quantity} Items',
                style: TextStyle(fontSize: 16, fontFamily: 'Barlow'),
                textAlign: TextAlign.center),
            Text('\$${(cartItem.price * cartItem.quantity).toStringAsFixed(2)}',
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'Barlow',
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
                textAlign: TextAlign.center),
          ]),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(cartItem.imageUrl),

            // no matter how big it is, it won't overflow
          ),
        ),
      ),
    );
  }
}
