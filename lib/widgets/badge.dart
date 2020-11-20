import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  const Badge({
    Key key,
    @required this.child,
    @required this.value,
    @required this.onPressed,
  }) : super(key: key);

  final Widget child;
  final String value;
  final Function onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onPressed();
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          child,
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.white),
              constraints: BoxConstraints(minWidth: 20, minHeight: 20),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  value,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Barlow'),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
