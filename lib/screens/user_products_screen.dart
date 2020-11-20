import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../widgets/user_product.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class UserProductsScreen extends StatelessWidget {
  Future<void> refrechData(BuildContext context) async {
    await Provider.of<ProductProvider>(context, listen: false)
        .getProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    // final productData = Provider.of<ProductProvider>(context);
    // List<Product> loadedProducts = productData.products;

    //
    Widget emptyContentBuilder() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_none,
            size: screenSize.width * .13 + screenSize.height * .13,
            color: Colors.black12,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No Products',
              style: TextStyle(
                fontSize: 25,
                fontFamily: 'Barlow',
                color: Colors.black26,
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('My Products'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.namedRoute);
              },
              splashColor: Colors.black54,
              highlightColor: Colors.black12,
              tooltip: 'Add Product',
            )
          ],
        ),
        body: FutureBuilder(
            future: refrechData(context),
            builder: (_, dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());
              else if (dataSnapshot.error != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.red,
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Error Fetching Data'),
                          Icon(Icons.warning),
                        ],
                      )));
                });
              }
              return RefreshIndicator(
                onRefresh: () => refrechData(context),
                child: Consumer<ProductProvider>(
                  builder: (_, productData, __) =>
                      productData.products.length > 0
                          ? ListView.builder(
                              itemCount: productData.products.length,
                              itemBuilder: (_, index) =>
                                  ChangeNotifierProvider.value(
                                    value: productData.products[index],
                                    child: Padding(
                                      padding: const EdgeInsets.all(0.0),
                                      child: UserItem(),
                                    ),
                                  ))
                          : Center(child: emptyContentBuilder()),
                ),
              );
            }));
  }
}
