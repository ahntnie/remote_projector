class NotificationModel {
  String? idNotify;
  String? title;
  String? createdDate;
  String? description;
  String? detail;
  String? picture;
  String? seen;

  NotificationModel({
    this.idNotify,
    this.title,
    this.createdDate,
    this.description,
    this.detail,
    this.picture,
    this.seen,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      idNotify: json['id_notify'],
      title: json['title'],
      createdDate: json['created_date'],
      description: json['descript'],
      detail: json['detail'],
      picture: json['picture'],
      seen: json['seen'],
    );
  }
}