class ConfigModel {
  final String? companyName;
  final String? companyAddress;
  final String? hotline;
  final String? representative;
  final String? email;
  final String? taxCode;
  final String? apiServer;
  final String? guideLink;
  final String? statementDate;
  final int? activeCode;
  final String? appUserAndroidVersion;
  final String? appUserAndroidBuildDate;
  final String? appUserAndroidUpdateUrl;
  final String? appUserIosVersion;
  final String? appUserIosBuildDate;
  final String? appUserIosUpdateUrl;

  const ConfigModel({
    this.companyName,
    this.companyAddress,
    this.hotline,
    this.representative,
    this.email,
    this.taxCode,
    this.apiServer,
    this.guideLink,
    this.statementDate,
    this.activeCode,
    this.appUserAndroidVersion,
    this.appUserAndroidBuildDate,
    this.appUserAndroidUpdateUrl,
    this.appUserIosVersion,
    this.appUserIosBuildDate,
    this.appUserIosUpdateUrl,
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      companyName: json['COMPANY_NAME'],
      companyAddress: json['COMPANY_ADDRESS'],
      hotline: json['HOTLINE'],
      representative: json['REPRESENTATIVE'],
      email: json['EMAIL'],
      taxCode: json['TAX_CODE'],
      apiServer: json['API_SERVER'],
      guideLink: json['GUIDE_LINK'],
      statementDate: json['statement_date'],
      activeCode: json['ACTIVE_FLAG'],
      appUserAndroidVersion: json['APPUSERANDROID_VERSION'],
      appUserAndroidBuildDate: json['APPUSERANDROID_BUILD_DATE'],
      appUserAndroidUpdateUrl: json['APPUSERANDROID_UPDATE_URL'],
      appUserIosVersion: json['APPUSERIOS_VERSION'],
      appUserIosBuildDate: json['APPUSERIOS_BUILD_DATE'],
      appUserIosUpdateUrl: json['APPUSERIOS_UPDATE_URL'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'COMPANY_NAME': companyName,
      'COMPANY_ADDRESS': companyAddress,
      'HOTLINE': hotline,
      'REPRESENTATIVE': representative,
      'EMAIL': email,
      'TAX_CODE': taxCode,
      'API_SERVER': apiServer,
      'GUIDE_LINK': guideLink,
      'statement_date': statementDate,
      'ACTIVE_FLAG': activeCode,
      'APPUSERANDROID_VERSION': appUserAndroidVersion,
      'APPUSERANDROID_BUILD_DATE': appUserAndroidBuildDate,
      'APPUSERANDROID_UPDATE_URL': appUserAndroidUpdateUrl,
      'APPUSERIOS_VERSION': appUserIosVersion,
      'APPUSERIOS_BUILD_DATE': appUserIosBuildDate,
      'APPUSERIOS_UPDATE_URL': appUserIosUpdateUrl,
    };
  }
}
