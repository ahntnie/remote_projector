class CommandModel {
  String? cmdId;
  String? cmdCode;
  DateTime? commitTime;
  String? content;
  bool? isImme;
  DateTime? returnTime;
  String? returnValue;
  String? sn;
  dynamic sync;
  dynamic done;
  int? secondWait;

  CommandModel({
    this.cmdId,
    this.cmdCode,
    this.commitTime,
    this.content,
    this.isImme,
    this.returnTime,
    this.returnValue,
    this.sn,
    this.sync,
    this.done,
    this.secondWait,
  });

  factory CommandModel.fromJson(Map<String, dynamic> json) {
    return CommandModel(
      cmdId: json['cmd_id'] ?? '',
      cmdCode: json['cmd_code'] ?? '',
      commitTime: DateTime.parse(json['commit_time'] as String),
      content: json['content'] ?? '',
      isImme: json['is_imme'] == '1',
      returnTime: DateTime.parse(json['return_time'] as String),
      returnValue: json['return_value'],
      sn: json['sn'] ?? '',
      sync: json['sync'] ?? '',
      done: json['done'] ?? '',
      secondWait: int.parse(json['second_wait'] as String),
    );
  }
}
