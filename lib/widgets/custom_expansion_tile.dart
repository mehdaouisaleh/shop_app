import 'package:flutter/material.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/orders_provider.dart';
import 'package:intl/intl.dart';

class CustomExpansionTile extends StatefulWidget {
  final List<OrderItem> list;
  final int index;
  CustomExpansionTile(this.list, this.index);
  @override
  _CustomExpansionTileState createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  Color color = Colors.green;
  void changed(bool changed) {
    setState(() {
      changed ? color = Colors.green.withOpacity(.6) : color = Colors.green;
    });
  }

  Widget CartItems(CartItem cartItem) => Padding(
        padding: const EdgeInsets.all(2.0),
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
      );
  @override
  Widget build(BuildContext context) {
    final item = widget.list[widget.index];
    final cartItems = item.cartItems;
    final theme = Theme.of(context);
    return Theme(
      data: ThemeData(
          dividerColor: Colors.transparent, accentColor: Colors.black45),
      child: ExpansionTile(
        onExpansionChanged: (c) => changed(c),
        title: Text(
            'Ordered on: ${DateFormat.yMMMMEEEEd().format(item.dateAdded)}'),
        subtitle: Text(
          '\$${item.amount.toStringAsFixed(2)}',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: color),
        ),
        children: [
          Container(
            height: cartItems.length > 1 ? 200 : 100,
            child: Theme(
              data: ThemeData(accentColor: theme.primaryColor),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: cartItems.length,
                itemBuilder: (BuildContext context, int i) {
                  return CartItems(cartItems[i]);
                },
                separatorBuilder: (BuildContext context, int i) =>
                    const Divider(),
              ),
            ),
          )
        ],
      ),
    );
  }
}
