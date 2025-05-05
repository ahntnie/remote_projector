class SignUpRequestModel {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String fcm_token;

  SignUpRequestModel(
      {required this.name,
      required this.email,
      required this.phone,
      required this.password,
      required this.fcm_token});

  factory SignUpRequestModel.fromJson(Map<String, dynamic> json) {
    return SignUpRequestModel(
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        password: json['password'],
        fcm_token: json['fcm_token']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'fcm_token': fcm_token
    };
    return data;
  }
}
