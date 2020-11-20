import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/custom_expansion_tile.dart';
import '../providers/orders_provider.dart';

class OrderScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    //final ordersData = Provider.of<OrdersProvider>(context);

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
              'No Orders',
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
          title: Text('Orders'),
        ),
        body: FutureBuilder(
            future:
                Provider.of<OrdersProvider>(context, listen: false).getOrders(),
            builder: (ctx, dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());

              return Consumer<OrdersProvider>(
                  builder: (context, ordersData, child) => ordersData
                              .orderItems.length >
                          0
                      ? ListView.builder(
                          itemCount: ordersData.orderItems.length,
                          itemBuilder: (_, index) =>
                              CustomExpansionTile(ordersData.orderItems, index))
                      : Center(child: emptyContentBuilder()));
            }));
  }
}
