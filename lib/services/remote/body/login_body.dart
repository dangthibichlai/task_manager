class LoginBody {
  String? email;
  String? password;

  LoginBody();

  factory LoginBody.fromJson(Map<String, dynamic> json) => LoginBody()
    ..email = json['email'] as String?
    ..password = json['password'] as String?;

  // LoginBody.fromJson(Map<String, dynamic> map) {
  //   email = map['email'];
  //   password = map['password'];
  // }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class Test {
  void method1() {
    Map<String, dynamic> map = {
      'email': 'a@a.b',
      'password': '123456',
    };

    LoginBody obj = LoginBody.fromJson(map);
    // tu map tra ve mot doi tuong
    // va gan gia tri tu map vao cac field cua doi tuong

    obj.email; // => a@a.b
    obj.password; // => 123456

    Map map2 = obj.toJson(); // tu doi tuong goi method va tra ve mot map

    // obj.toJson() => tra ve mot map

    print(map2);

    // {
    //   'email': 'a@a.b',
    //   'password': '123456',
    // }
  }
}
