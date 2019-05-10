import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;

import '../models/productdef.dart';
import '../models/userdef.dart';

class ConnectedProductsModel extends Model {
  List<Product> _products = [];
  int _selProductIndex;
  User _authenticatedUser;
  bool _isLoading = false;
  Future<Null> addProduct(
      String title, String discription, String image, double price) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> productData = {
      'title': title,
      'discription': discription,
      'image':
          'http://tes77.com/wp-content/uploads/2017/10/dark-chocolate-bar-squares.jpg',
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
    };
    return http
        .post("https://flutter-products-c81d2.firebaseio.com/products.json",
            body: json.encode(productData))
        .then(
      (http.Response response) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final Product newProduct = Product(
            id: responseData['name'],
            title: title,
            description: discription,
            image: image,
            price: price,
            userEmail: _authenticatedUser.email,
            userId: _authenticatedUser.id);
        _products.add(newProduct);
        _selProductIndex = null;
        _isLoading = false;
        notifyListeners();
      },
    );
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

  Future<Null> updateProduct(
      String title, String discription, String image, double price) {
    _isLoading = true;
    notifyListeners();
    final Map<String, dynamic> updateData = {
      'title': title,
      'discription': discription,
      'image':
          'http://tes77.com/wp-content/uploads/2017/10/dark-chocolate-bar-squares.jpg',
      'price': price,
      'userEmail': selectedProduct.userEmail,
      'userId': selectedProduct.userId,
    };
    return http
        .put(
            "https://flutter-products-c81d2.firebaseio.com/products/${selectedProduct.id}.json",
            body: jsonEncode(updateData))
        .then((http.Response response) {
      _isLoading = false;
      final Product updatedProduct = Product(
          id: selectedProduct.id,
          title: title,
          description: discription,
          image: image,
          price: price,
          userEmail: selectedProduct.userEmail,
          userId: selectedProduct.userId);
      _products[selectedProductIndex] = updatedProduct;

      notifyListeners();
    });
  }

  void deleteProduct() {
    _isLoading = true;
    final deletedProductId = selectedProduct.id;
    _products.removeAt(selectedProductIndex);
    _selProductIndex = null;
    notifyListeners();
    http
        .delete(
            "https://flutter-products-c81d2.firebaseio.com/products/${deletedProductId}.json")
        .then((http.Response response) {
      _isLoading = false;

      notifyListeners();
    });
  }

  Future<Null> fetchProducts() {
    _isLoading = true;
    notifyListeners();
    return http
        .get("https://flutter-products-c81d2.firebaseio.com/products.json")
        .then(
      (http.Response response) {
        // print(jsonDecode(response.body));
        final List<Product> fetchedProductList = [];
        final Map<String, dynamic> productListData = jsonDecode(response.body);
        if (productListData == null) {
          _isLoading = false;
          notifyListeners();
          return;
        }
        productListData.forEach((String productId, dynamic productData) {
          final Product product = Product(
            id: productId,
            title: productData['title'],
            description: productData['discription'],
            image: productData['image'],
            price: productData['price'],
            userEmail: productData['userEmail'],
            userId: productData['userId'],
          );
          fetchedProductList.add(product);
        });
        _products = fetchedProductList;
        _isLoading = false;
        notifyListeners();
      },
    );
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

class UtilityModel extends ConnectedProductsModel {
  bool get isLoading {
    return _isLoading;
  }
}
