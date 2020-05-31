class User {
  int id;
  String name;

  String pasword;
  String mobile;
  User(this.name, this.pasword, this.mobile);
  Map<String, dynamic> toUserMap() {
    return {
      'name': name,
      'password': pasword,
      'mobile': mobile,
    };
  }

  static fromMap(Map<String, dynamic> c) {
    return User(c['name'], c['passowrd'], c['mobile']);
  }
}
