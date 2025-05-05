class Device {
  String? computerId;
  String? computerName;
  String? serialComputer;
  String? ipAddress;
  String? status;
  String? provinces;
  String? district;
  String? wards;
  String? centerId;
  String? location;
  String? activedDate;
  String? createdDate;
  String? ultraviewPW;
  String? ultraviewID;
  String? customerId;
  String? customerName;
  String? type;
  String? idDir;
  String? nameDir;
  String? timeEnd;
  int? turnOn;
  int? turnOff;
  String? createdBy;
  String? lastMDFBy;
  String? lastMDFDate;
  String? user;
  String? pass;
  String? deleted;
  int? isCheckOnProjector;
  int? isCheckOffProjector;
  String? lastedAliveTime;
  String? computerToken;
  bool? isOwner;
  bool? isShareOwner;
  String? romMemoryTotal;
  String? romMemoryUsed;

  Device({
    this.computerId,
    this.computerName,
    this.serialComputer,
    this.ipAddress,
    this.status,
    this.provinces,
    this.district,
    this.wards,
    this.centerId,
    this.location,
    this.activedDate,
    this.createdDate,
    this.ultraviewPW,
    this.ultraviewID,
    this.customerId,
    this.customerName,
    this.type,
    this.idDir,
    this.nameDir,
    this.timeEnd,
    this.turnOn,
    this.turnOff,
    this.createdBy,
    this.lastMDFBy,
    this.lastMDFDate,
    this.user,
    this.pass,
    this.deleted,
    this.isCheckOnProjector,
    this.isCheckOffProjector,
    this.lastedAliveTime,
    this.computerToken,
    this.isOwner = false,
    this.isShareOwner = false,
    this.romMemoryTotal,
    this.romMemoryUsed,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      computerId: json['computer_id'],
      computerName: json['computer_name'],
      serialComputer: json['seri_computer'],
      ipAddress: json['ip_address'],
      status: json['status'] == '' ? '0' : json['status'],
      provinces: json['provinces'],
      district: json['district'],
      wards: json['wards'],
      centerId: json['center_id'],
      location: json['location'],
      activedDate: json['actived_date'],
      createdDate: json['created_date'],
      ultraviewPW: json['ultraviewPW'],
      ultraviewID: json['ultraviewID'],
      customerId: json['customer_id'],
      customerName: json['customer_name'],
      type: json['type'],
      idDir: json['id_dir'],
      nameDir: json['name_dir'],
      timeEnd: json['time_end'],
      turnOn: int.parse(json['turn_on']),
      turnOff: int.parse(json['turn_off']),
      createdBy: json['created_by'],
      lastMDFBy: json['last_MDF_by'],
      lastMDFDate: json['last_MDF_date'],
      user: json['user'],
      pass: json['pass'],
      deleted: json['deleted'],
      isCheckOnProjector: int.parse(json['isCheckOnProjector']),
      isCheckOffProjector: int.parse(json['isCheckOffProjector']),
      lastedAliveTime: json['lasted_alive_time'],
      computerToken: json['computer_token'],
      romMemoryTotal: json['rom_memory_total'],
      romMemoryUsed: json['rom_memory_used'],
    );
  }
}
