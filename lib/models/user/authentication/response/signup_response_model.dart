class SignUpResponseModel {
  String status;
  String? msg;
  String? id;

  SignUpResponseModel({
    required this.status,
    this.msg,
    this.id,
  });

  factory SignUpResponseModel.fromJson(Map<String, dynamic> json) {
    return SignUpResponseModel(
      status: json['status'].toString(),
      msg: json['msg'],
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'msg': msg,
      'id': id,
    };
  }
}