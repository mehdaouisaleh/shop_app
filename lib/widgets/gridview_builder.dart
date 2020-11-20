import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../providers/product_provider.dart';
import '../models/product.dart';
import '../widgets/product_item.dart';

class GridViewBuilder extends StatelessWidget {
  final bool onlyFav;
  final GlobalKey<ScaffoldState> _scaffoldKey;
  GridViewBuilder(this.onlyFav, this._scaffoldKey);

  @override
  Widget build(BuildContext context) {
    final productData = Provider.of<ProductProvider>(context);
    Size screenSize = MediaQuery.of(context).size;
    Orientation deviceOrientation = MediaQuery.of(context).orientation;
    
    List<Product> loadedProducts =
        onlyFav ? productData.favorites : productData.products;

    Widget emptyContentBuilder() => Column(
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
                'No Items',
                style: TextStyle(
                  fontSize: 25,
                  fontFamily: 'Barlow',
                  color: Colors.black26,
                ),
              ),
            ),
          ],
        );
    return loadedProducts.isEmpty
        ? Center(child: emptyContentBuilder())
        : GridView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: loadedProducts.length,
            itemBuilder: (_, index) => ChangeNotifierProvider.value(
              value:
                  loadedProducts[index], // alternative to the 'Create' function
              child: ProductItem(_scaffoldKey),
            ),
            gridDelegate: deviceOrientation == Orientation.portrait
                ? SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10)
                : SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20),
          );
  }
}
