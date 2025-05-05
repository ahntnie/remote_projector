class CampProfileModel {
  String? id;
  String? campaignId;
  String? campaignName;
  String? url;
  String? computerId;
  String? seriComputer;
  String? computerName;
  String? runTime;
  String? runTimeServer;

  CampProfileModel({
    this.id,
    this.campaignId,
    this.campaignName,
    this.url,
    this.computerId,
    this.seriComputer,
    this.computerName,
    this.runTime,
    this.runTimeServer,
  });

  factory CampProfileModel.fromJson(Map<String, dynamic> json) {
    return CampProfileModel(
      id: json['id'],
      campaignId: json['campaign_id'],
      campaignName: json['campaign_name'],
      url: json['url'],
      computerId: json['computer_id'],
      seriComputer: json['seri_computer'],
      computerName: json['computer_name'],
      runTime: json['run_time'],
      runTimeServer: json['run_time_server'],
    );
  }
}