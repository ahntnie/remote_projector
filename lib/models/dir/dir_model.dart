class Dir {
  int? dirId;
  String? dirName;
  int? customerId;
  String? dirType;
  String? createdBy;
  String? createdDate;
  String? lastModifyBy;
  String? lastModifyDate;
  String? deleted;
  bool? isOwner;
  bool? isShareOwner;
  String? turnonTime;
  String? turnoffTime;

  Dir({
    this.dirId,
    this.dirName,
    this.customerId,
    this.dirType,
    this.createdBy,
    this.createdDate,
    this.lastModifyBy,
    this.lastModifyDate,
    this.deleted,
    this.isOwner = false,
    this.isShareOwner = false,
    this.turnoffTime,
    this.turnonTime,
  });

  factory Dir.fromJson(Map<String, dynamic> json) {
    return Dir(
      dirId: int.parse(json['id_dir']),
      dirName: json['name_dir'],
      customerId: int.parse(json['customer_id']),
      dirType: json['type_dir'],
      createdBy: json['created_by'],
      createdDate: json['created_date'],
      lastModifyBy: json['last_MDF_by'],
      lastModifyDate: json['last_MDF_date'],
      deleted: json['deleted'],
      turnonTime: json['turnon_time'],
      turnoffTime: json['turnoff_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_dir': dirId,
      'name_dir': dirName,
      'customer_id': customerId,
      'type_dir': dirType,
      'created_by': createdBy,
      'created_date': createdDate,
      'last_MDF_by': lastModifyBy,
      'last_MDF_date': lastModifyDate,
      'deleted': deleted,
      'turnon_time': turnonTime,
      'turnoff_time': turnoffTime,
      'is_owner': isOwner,
    };
  }
}
