class User {
  String? customerId;
  String? customerName;
  String? address;
  String? phoneNumber;
  String? email;
  String? dateOfBirth;
  String? sex;
  String? chuTk;
  String? stk;
  String? nganHang;
  String? chiNhanh;
  String? password;
  String? customerToken;
  String? fcm_token;

  User({
    this.customerId,
    this.customerName,
    this.address,
    this.phoneNumber,
    this.email,
    this.dateOfBirth,
    this.sex,
    this.chuTk,
    this.stk,
    this.nganHang,
    this.chiNhanh,
    this.password,
    this.customerToken,
    this.fcm_token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      address: json['address'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      dateOfBirth: json['date_of_birth'],
      sex: json['sex'],
      chuTk: json['chu_tk'],
      stk: json['stk'],
      nganHang: json['nganhang'],
      chiNhanh: json['chinhanh'],
      password: json['password'],
      customerToken: json['customer_token'],
      fcm_token: json['fcm_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_name': customerName,
      'address': address,
      'phone_number': phoneNumber,
      'email': email,
      'date_of_birth': dateOfBirth,
      'sex': sex,
      'chu_tk': chuTk,
      'stk': stk,
      'nganhang': nganHang,
      'chinhanh': chiNhanh,
      'password': password,
      'customer_token': customerToken,
      'fcm_token': fcm_token,
    };
  }
}
