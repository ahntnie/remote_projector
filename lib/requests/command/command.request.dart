import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../app/app_utils.dart';
import '../../constants/app_api.dart';
import '../../models/command/command_model.dart';
import '../../models/device/device_model.dart';

class CommandRequest {
  final Dio _dio = Dio();

  static const String projectId = 'remote-projector-fc831';
  static const String fcmUri =
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send';
  static const String messagingScope =
      'https://www.googleapis.com/auth/firebase.messaging';

  AccessCredentials? _credentials;

  Future<String?> createNewCommand({
    required Device device,
    required String command,
    required String content,
    required String isImme,
    required int secondWait,
  }) async {
    try {
      final formData = FormData.fromMap({
        'sn': device.serialComputer,
        'cmd_code': command.toString(),
        'content': '',
        'is_imme': isImme,
        'second_wait': secondWait,
      });
      final response = await _dio.post(
        '${Api.hostApi}${Api.createCommand}',
        data: formData,
        options: AppUtils.createOptionsNoCookie(),
      );

      final responseData = jsonDecode(response.data);
      String? commandId = responseData['cmd_id'];

      if (commandId.isNotEmptyAndNotNull &&
          device.computerToken.isNotEmptyAndNotNull) {
        Map<String, dynamic> jsonData = {
          'message': {
            'token': device.computerToken,
            'data': {'cmd_id': commandId, 'cmd_code': command}
          }
        };
        _postMessage(jsonData);
      }

      return commandId;
    } catch (_) {}

    return null;
  }

  Future<CommandModel> getInfoCommandById(String commandId) async {
    final response = await _dio.get(
      '${Api.hostApi}${Api.getInfoCommandByID}/$commandId',
    );

    final responseData = jsonDecode(response.data);

    List<dynamic> commands = responseData['cmd_list'];
    CommandModel command = CommandModel.fromJson(commands.first);

    return command;
  }

  /// Posts the message
  Future<void> _postMessage(Map<String, dynamic> body) async {
    Map<String, String> headers = await _buildHeaders();
    await _dio.post(
      fcmUri,
      options: Options(headers: headers),
      data: body,
    );
  }

  /// Builds default header
  Future<Map<String, String>> _buildHeaders() async {
    if (_credentials == null) {
      await _autoRefreshCredentialsInitialize();
    }
    String? token = _credentials?.accessToken.data;
    Map<String, String> headers = {};
    headers['Authorization'] = 'Bearer $token';
    headers['Content-Type'] = 'application/json';
    return headers;
  }

  Future<void> _autoRefreshCredentialsInitialize() async {
    String source = await rootBundle
        .loadString('assets/remote-projector-fc831-0b940e3fbf0a.json');
    final serviceAccount = jsonDecode(source);
    var accountCredentials = ServiceAccountCredentials.fromJson(serviceAccount);

    try {
      AutoRefreshingAuthClient autoRefreshingAuthClient =
          await clientViaServiceAccount(
        accountCredentials,
        [messagingScope],
      );

      /// initialization
      _credentials = autoRefreshingAuthClient.credentials;

      autoRefreshingAuthClient.credentialUpdates.listen((credentials) {
        _credentials = credentials;
      });
    } catch (_) {}
  }
}
