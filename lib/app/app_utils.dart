import 'package:dio/dio.dart';

import '../constants/app_api.dart';

class AppUtils {
  static String createUrl(String toMerge) {
    return '${Api.hostApi}$toMerge';
  }

  static Options createOptionsNoCookie() {
    return Options(
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    );
  }
}
