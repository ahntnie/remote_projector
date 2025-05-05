class CampStatisticsModel {
  String? campaignId;
  String? campaignName;
  String? runDate;
  String? runTotal;

  CampStatisticsModel({
    this.campaignId,
    this.campaignName,
    this.runDate,
    this.runTotal,
  });

  factory CampStatisticsModel.fromJson(Map<String, dynamic> json) {
    return CampStatisticsModel(
      campaignId: json['campaign_id'],
      campaignName: json['campaign_name'],
      runDate: json['run_date'],
      runTotal: json['run_total'],
    );
  }
}