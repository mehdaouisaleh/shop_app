import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';

class UserItem extends StatelessWidget {
  String id;
  String title;
  String description;
  double price;
  String imageUrl;
  BuildContext _dialogContext;
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final data = Provider.of<ProductProvider>(context, listen: false);
    final cartData = Provider.of<CartProvider>(context, listen: false);
    id = product.id;
    title = product.title;
    description = product.description;
    price = product.price;
    imageUrl = product.imageUrl;
    // Size screenSize = MediaQuery.of(context).size;
    return ListTile(
      onTap: () {},
      contentPadding: const EdgeInsets.all(12.0),
      title: Text(title),
      leading: Hero(
          tag: id,
          child: CircleAvatar(backgroundImage: NetworkImage(imageUrl))),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
                icon: Icon(
                  Icons.mode_edit,
                  color: Colors.blue,
                ),
                onPressed: () {
                  Navigator.of(context).pushNamed(EditProductScreen.namedRoute,
                      arguments: Product(
                          id: id,
                          title: title,
                          description: description,
                          price: price,
                          imageUrl: imageUrl));
                }),
            IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                            title: Text('Confirm'),
                            content: SingleChildScrollView(
                                child: Text(
                                    'Are you sure you want to remove this product ?')),
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
                          )).then((value) => value
                      ? {
                          showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (ctx) {
                                _dialogContext = ctx;
                                return AlertDialog(
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                    ],
                                  ),
                                );
                              }),
                          data.removeProduct(id).then((_) {
                            cartData.removeItem(productId: id);
                            Navigator.of(_dialogContext).pop();
                          }).catchError((_) {
                            Scaffold.of(context).hideCurrentSnackBar();
                            Scaffold.of(context).showSnackBar(SnackBar(
                                backgroundColor: Colors.red,
                                content: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Error Deleting Product'),
                                    Icon(Icons.warning),
                                  ],
                                )));

                            Navigator.of(_dialogContext).pop();
                          })
                        }
                      : null);
                }),
          ],
        ),
      ),
    );
  }
}
