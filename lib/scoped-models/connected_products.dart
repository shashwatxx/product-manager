import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

import '../models/productdef.dart';
import '../models/userdef.dart';

class ConnectedProductsModel extends Model {
  List<Product> _products = [];
  int _selProductIndex;
  User _authenticatedUser;

  void addProduct(
      String title, String discription, String image, double price) {
    final Map<String, dynamic> productData = {
      'title': title,
      'discription': discription,
      'image':
          'http://tes77.com/wp-content/uploads/2017/10/dark-chocolate-bar-squares.jpg',
      'price': price,
    };
    http.post("https://flutter-products-c81d2.firebaseio.com/products.json",
        body: json.encode(productData));
    final Product newProduct = Product(
        title: title,
        description: discription,
        image: image,
        price: price,
        userEmail: _authenticatedUser.email,
        userId: _authenticatedUser.id);
    _products.add(newProduct);
    _selProductIndex = null;
    notifyListeners();
  }
}

// ########################################################################################################################################################################
class ProductsModel extends ConnectedProductsModel {
  bool _showFavorites = false;

  List<Product> get allproducts {
    return List.from(_products);
  }

  List<Product> get displayedProducts {
    if (_showFavorites) {
      return _products.where((Product product) => product.isFavorite).toList();
    }
    return List.from(_products);
  }

  int get selectedProductIndex {
    return _selProductIndex;
  }

  Product get selectedProduct {
    if (selectedProductIndex == null) {
      return null;
    }
    return _products[selectedProductIndex];
  }

  bool get displayFavoritesOnly {
    return _showFavorites;
  }

  void updateProduct(
      String title, String discription, String image, double price) {
    final Product updatedProduct = Product(
        title: title,
        description: discription,
        image: image,
        price: price,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId);
    _products[selectedProductIndex] = updatedProduct;

    notifyListeners();
  }

  void deleteProduct() {
    _products.removeAt(selectedProductIndex);

    notifyListeners();
  }

  void toggleProductFavoriteStatus() {
    final bool isCurrentlyFavorite = selectedProduct.isFavorite;
    final bool newFavoriteStatus = !isCurrentlyFavorite;
    final Product updatedProduct = Product(
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        userEmail: selectedProduct.userEmail,
        userId: selectedProduct.userId,
        isFavorite: newFavoriteStatus);
    _products[selectedProductIndex] = updatedProduct;

    notifyListeners();
  }

  void selectProduct(int index) {
    //  _selProductId = productId;
    //   if (productId != null) {
    //     notifyListeners();

    _selProductIndex = index;
    if (_selProductIndex != null) {
      notifyListeners();
    }
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    notifyListeners();
  }
}

// ########################################################################################################################################################################
class UserModel extends ConnectedProductsModel {
  void login(String email, String password) {
    _authenticatedUser = User(id: 'sha', email: email, password: password);
  }
}
