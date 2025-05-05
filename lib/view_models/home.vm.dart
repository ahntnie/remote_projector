import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

import '../app/app_sp.dart';
import '../app/app_sp_key.dart';
import '../app/utils.dart';
import '../constants/app_info.dart';
import '../models/config/config_model.dart';
import '../models/user/user.dart';
import '../plugin/install_plugin.dart';
import '../view/account/account_page.dart';
import '../view/camp/camp_page.dart';
import '../view/dir/dir_page.dart';
import '../view/packet/packet_page.dart';
import '../view/statistics/statistics_page.dart';
import '../widget/pop_up.dart';
import 'resource_manager.vm.dart';

class HomeViewModel extends BaseViewModel {
  HomeViewModel({required this.context});

  BuildContext context;
  late ResourceMangerViewModel resourceMangerViewModel;

  final List<Widget> _pages = [];
  List<Widget> get pages => _pages;

  final List<String> _title = [
    'Quản lý hệ thống',
    'Gói cước',
    'Quản lý video',
    'Thống kê',
    'Thông tin tài khoản',
  ];
  List<String> get title => _title;

  CancelToken? _cancelToken;

  bool _permissionGranted = false;
  bool get permissionGranted => _permissionGranted;

  bool _isUpdate = false;
  bool get isUpdate => _isUpdate;

  bool _updateAvailable = false;
  bool get updateAvailable => _updateAvailable;

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  double _progress = 0;
  double get progress => _progress;

  String? _tempPath;
  String? get tempPath => _tempPath;

  User? _currentUser;
  User? get currentUser => _currentUser;

  ConfigModel? _configModel;

  void initialise() {
    _pages.clear();
    _pages.addAll([
      const DirPage(),
      const PacketPage(),
      const CampPage(),
      const StatisticsPage(),
      const AccountPage(),
    ]);

    _getInfoUser();
    //_checkVersionApp();
  }

  void changeIndexPage(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void cancelDownloadTaped() {
    if (_tempPath != null) {
      _installApp();
    } else if (_isUpdate) {
      _cancelToken?.cancel();
      _cancelToken = null;
      _isUpdate = false;
      _progress = 0;

      notifyListeners();
    } else {
      if (Platform.isAndroid) {
        _updateAndroidApp(_configModel?.appUserAndroidUpdateUrl);
      }
    }
  }

  Future<void> _checkVersionApp() async {
    String configString = AppSP.get(AppSPKey.config) ?? '';

    if (configString.isNotBlank) {
      _configModel = ConfigModel.fromJson(jsonDecode(configString));
      await Future.delayed(const Duration(milliseconds: 500));

      if (Platform.isAndroid) {
        String buildDate = _configModel?.appUserAndroidBuildDate ??
            AppInfo.userAndroidAppInfo.buildDate;

        if (AppInfo.userAndroidAppInfo.buildDate.isBeforeBuildDate(buildDate)) {
          showPopupSingleButton(
            title:
                'Để tiếp tục sử dụng ứng dụng, vui lòng cập nhật ứng dụng lên phiên bản mới nhất.\nPhiên bản: ${_configModel?.appUserAndroidVersion ?? ''}\nNgày phát hành: ${_configModel?.appUserAndroidBuildDate ?? ''}',
            barrierDismissible: false,
            context: context,
            onButtonTap: () =>
                _updateAndroidApp(_configModel?.appUserAndroidUpdateUrl),
          );
        }
      } else if (Platform.isIOS) {
        String buildDate = _configModel?.appUserIosBuildDate ??
            AppInfo.userIOSAppInfo.buildDate;

        if (AppInfo.userIOSAppInfo.buildDate.isBeforeBuildDate(buildDate)) {
          showPopupSingleButton(
            title:
                'Để tiếp tục sử dụng ứng dụng, vui lòng cập nhật ứng dụng lên phiên bản mới nhất.\nPhiên bản: ${_configModel?.appUserIosVersion ?? ''}\nNgày phát hành: ${_configModel?.appUserIosBuildDate ?? ''}',
            barrierDismissible: false,
            context: context,
            onButtonTap: () =>
                launchUrl(Uri.parse(_configModel?.appUserIosUpdateUrl ?? '')),
          );
        }
      } else if (Platform.isWindows) {
        String buildDate = _configModel?.appUserIosBuildDate ??
            AppInfo.userIOSAppInfo.buildDate;
      }
    }
  }

  Future<void> _updateAndroidApp(String? url) async {
    if (url == null || _isUpdate == true) return;

    if (!_permissionGranted) {
      _permissionGranted = await InstallPlugin.requestPermission() ?? false;
    }
    _updateAvailable = true;
    notifyListeners();

    if (_permissionGranted) {
      _isUpdate = true;
      _progress = 0;
      _permissionGranted = true;
      _cancelToken = CancelToken();

      notifyListeners();

      var appDocDir = await getTemporaryDirectory();
      String savePath = "${appDocDir.path}/${url.split('/').last}";

      var response = await Dio().download(
        url,
        savePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (count, total) {
          final value = count / total;
          if (_progress != value) {
            _progress = value;
            notifyListeners();
          }
        },
      );

      if (response.statusCode == 200) {
        _tempPath = savePath;
        _installApp();
      }
    } else {
      showPopupSingleButton(
        title:
            'Để tiếp tục việc cập nhật ứng dụng, bạn cần cấp quyền cài đặt ứng dụng từ bên ngoài.\nMở cài đặt?',
        context: context,
        onButtonTap: () async {
          _permissionGranted =
              await InstallPlugin.requestPermission(openSetting: true) ?? false;
        },
      );
    }
  }

  Future<void> _installApp() async {
    if (_tempPath == null) return;

    final res = await InstallPlugin.install(_tempPath!);

    if (!res['isSuccess'] == true) {
      _isUpdate = false;
      _cancelToken = null;
      _progress = 0;
      notifyListeners();
    }
  }

  void _getInfoUser() {
    String? userString = AppSP.get(AppSPKey.userInfo);

    if (userString.isNotEmptyAndNotNull) {
      _currentUser = User.fromJson(jsonDecode(userString!));
    }

    notifyListeners();
  }
}
