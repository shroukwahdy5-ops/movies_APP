class UserModel {
  final String name;
  final String email;
  final String password;
  final String phone;
  final int avatar;

  UserModel({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.avatar,
  });

  UserModel copyWith({String? name, String? password, String? phone, int? avatar}) =>
      UserModel(
        name: name ?? this.name,
        email: email,
        password: password ?? this.password,
        phone: phone ?? this.phone,
        avatar: avatar ?? this.avatar,
      );

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        name: j['name'],
        email: j['email'],
        password: j['password'],
        phone: j['phone'],
        avatar: j['avatar'],
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'avatar': avatar,
      };
}
