import 'package:scoped_model/scoped_model.dart';

import '../models/userdef.dart';

class UserModel extends Model {
  User _authenticatedUser;

  void login(String email, String password) {
    _authenticatedUser = User(id: 'sha', email: email, password: password);
  }
}
