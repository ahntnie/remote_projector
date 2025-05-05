import 'package:remote_projector_2024/models/packet/packet_model.dart';

class PacketListResponseModel {
  int status;
  String msg;
  List<PacketModel>? packetList;

  PacketListResponseModel({required this.status, required this.msg, this.packetList});

  factory PacketListResponseModel.fromJson(Map<String, dynamic> json) {
    var packets = json['Packet_list'] as List<dynamic>?;

    List<PacketModel>? packetList;
    if (packets != null) {
      packetList = packets.map((e) => PacketModel.fromJson(e)).toList();
    }

    return PacketListResponseModel(
      status: json['status'],
      msg: json['msg'],
      packetList: packetList,
    );
  }
}
