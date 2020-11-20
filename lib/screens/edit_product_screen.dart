import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  static String namedRoute = '/edit_product_screen';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  FocusNode _priceFocusNode = FocusNode();
  FocusNode _descriptionFocusNode = FocusNode();
  FocusNode _imageFocusNode = FocusNode();
  TextEditingController _imageUrlController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  var _form = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Product product =
      Product(id: '', title: '', price: 0.0, description: '', imageUrl: '');

  var _isInit = true;
  var _editing = false;
  var _isLoading = false;

  @override
  void initState() {
    _imageFocusNode.addListener(_imageUpdateListner);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final editedProduct = ModalRoute.of(context).settings.arguments as Product;
    if (_isInit) if (editedProduct != null) {
      product = editedProduct;
      _imageUrlController.text = product.imageUrl;
      _priceController.text = product.price.toString();
      _titleController.text = product.title;
      _descriptionController.text = product.description;
    }
    _isInit = false;

    super.didChangeDependencies();
  }

  void _imageUpdateListner() {
    if (!_imageFocusNode.hasFocus) {
      if (_imageUrlController.text.isEmpty ||
          ((!_imageUrlController.text.startsWith('http') &&
                  !_imageUrlController.text.startsWith('https')) ||
              !_imageUrlController.text.endsWith('.jpg') &&
                  !_imageUrlController.text.endsWith('.png'))) return;

      setState(() {});
    }
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageFocusNode.removeListener(_imageUpdateListner);
    _imageFocusNode.dispose();

    super.dispose();
  }

  void editPorduct(Product p, ProductProvider productData) async {
    try {
      await productData.editProduct(p);
      _scaffoldKey.currentState.hideCurrentSnackBar();

      Navigator.of(context).pop();
    } catch (_) {
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Error Editing Product'),
              Icon(Icons.warning),
            ],
          )));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void addProduct(Product p, ProductProvider productData) async {
    try {
      await productData.addProduct(Product(
          id: null,
          title: p.title,
          description: p.description,
          price: p.price,
          imageUrl: p.imageUrl));

      _scaffoldKey.currentState.hideCurrentSnackBar();
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    } catch (_) {
      print(_);
      setState(() {
        _isLoading = false;
      });
      _scaffoldKey.currentState.hideCurrentSnackBar();
      _scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Error Adding Product'),
              Icon(Icons.warning),
            ],
          )));
    }
  }

  void submitForm() {
    final productData = Provider.of<ProductProvider>(context, listen: false);
    final isValid = _form.currentState.validate();
    if (isValid) {
      _form.currentState.save();
      setState(() {
        _isLoading = true; // show UI progress indicator
      });
      _editing // test if we are editing or adding a product
          ? editPorduct(product, productData)
          : addProduct(product, productData);
    }
  }

  @override
  Widget build(BuildContext context) {
    product.id.isNotEmpty ? _editing = true : _editing = false;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: _editing ? Text('Edit Product') : Text('Add Product'),
        actions: [
          IconButton(
              splashColor: Colors.black54,
              highlightColor: Colors.black12,
              tooltip: 'Save',
              icon: Icon(Icons.done),
              onPressed: () {
                submitForm();
              })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Form(
                key: _form,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _titleController,
                          onSaved: (value) {
                            product = Product(
                                id: product.id,
                                title: value,
                                imageUrl: product.imageUrl,
                                price: product.price,
                                description: product.description);
                          },
                          validator: (value) {
                            if (value.isEmpty) return 'Empty Title Field';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Title',
                            prefixIcon: Icon(Icons.crop_free),
                          ),
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_priceFocusNode);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _priceController,
                          onSaved: (value) {
                            product = Product(
                                id: product.id,
                                title: product.title,
                                imageUrl: product.imageUrl,
                                price: double.parse(value),
                                description: product.description);
                          },
                          validator: (value) {
                            if (value.isEmpty) return 'Empty Price Field';
                            if (double.tryParse(value) == null)
                              return 'Only Numbers Are Accepted';
                            if (double.parse(value) <= 0)
                              return 'Invalid Number';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Price',
                            prefixIcon: Icon(Icons.attach_money),
                          ),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          focusNode: _priceFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_descriptionFocusNode);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: _descriptionController,
                          onSaved: (value) {
                            product = Product(
                                id: product.id,
                                title: product.title,
                                imageUrl: product.imageUrl,
                                price: product.price,
                                description: value);
                          },
                          validator: (value) {
                            if (value.isEmpty) return 'Empty Description Field';
                            if (value.length < 10)
                              return 'Description Too Short';
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Icon(Icons.text_fields),
                          ),
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          focusNode: _descriptionFocusNode,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(width: 1, color: Colors.black38),
                            ),
                            child: _imageUrlController.text.isEmpty
                                ? Text('Enter image Url')
                                : FittedBox(
                                    child: Hero(
                                      tag: product.id,
                                      child: Image.network(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                onSaved: (value) {
                                  product = Product(
                                      id: product.id,
                                      title: product.title,
                                      imageUrl: value,
                                      price: product.price,
                                      description: product.description);
                                },
                                validator: (value) {
                                  if (value.isEmpty)
                                    return 'Empty ImageUrl Field';
                                  if ((!value.startsWith('http') &&
                                          !value.startsWith('https')) ||
                                      !value.endsWith('.jpg') &&
                                          !value.endsWith('.png'))
                                    return 'Invalid Url';

                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Image Url',
                                  prefixIcon: Icon(Icons.image),
                                ),
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.url,
                                controller: _imageUrlController,
                                focusNode: _imageFocusNode,
                                onEditingComplete: () {
                                  _imageUpdateListner();
                                  FocusScope.of(context).requestFocus(
                                      FocusNode()); //to close softKeyboard
                                },
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )),
      ),
    );
  }
}
