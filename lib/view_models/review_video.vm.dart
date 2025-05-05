import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win.dart';

import '../app/app.locator.dart';
import '../app/utils.dart';
import '../widget/pop_up.dart';

class ReviewVideoViewModel extends BaseViewModel {
  ReviewVideoViewModel({required this.urlFile, required this.videoType});

  final _navigationService = appLocator<NavigationService>();
  late BuildContext _context;

  VideoPlayerController? mobileVideoController;
  WinVideoPlayerController? windowsVideoController;

  final String urlFile;
  final int videoType;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _isChangeSlider = false;
  bool get isChangeSlider => _isChangeSlider;

  double _currentPosition = 0.0;
  double get currentPosition => _currentPosition;

  Future<void> initialise() async {
    if (!kIsWeb) {
      if (Platform.isWindows) {
        await initialiseWindows();
      } else if (Platform.isAndroid || Platform.isIOS) {
        await initialiseMobile();
      }
    }

    notifyListeners();
  }

  Future<void> initialiseWindows() async {
    if (videoType == 1) {
      windowsVideoController = WinVideoPlayerController.file(File(urlFile));
    } else {
      if (await isVideoUrlValid(urlFile)) {
        windowsVideoController = WinVideoPlayerController.network(urlFile);
      } else {
        _errorUrl();
      }
    }
    windowsVideoController!
      ..initialize().then((_) {
        windowsVideoController!.play();
        _isPlaying = true;
        windowsVideoController!.addListener(() {
          _currentPosition =
              windowsVideoController!.value.position.inSeconds.toDouble();
          notifyListeners();
        });
      })
      ..setLooping(true);
  }

  Future<void> initialiseMobile() async {
    if (videoType == 1) {
      mobileVideoController = VideoPlayerController.file(File(urlFile));
    } else {
      if (await isVideoUrlValid(urlFile)) {
        mobileVideoController =
            VideoPlayerController.networkUrl(Uri.parse(urlFile));
      } else {
        _errorUrl();
      }
    }
    mobileVideoController!
      ..initialize().then((_) {
        mobileVideoController!.play();
        _isPlaying = true;
        mobileVideoController!.addListener(() {
          _currentPosition =
              mobileVideoController!.value.position.inSeconds.toDouble();
          notifyListeners();
        });
      })
      ..setLooping(true);
  }

  @override
  void dispose() {
    mobileVideoController?.dispose();
    windowsVideoController?.dispose();

    super.dispose();
  }

  void updateContext(BuildContext context) {
    _context = context;
  }

  bool isControllerAlready() {
    if (!kIsWeb) {
      if (Platform.isWindows) {
        return windowsVideoController != null &&
            windowsVideoController!.value.isInitialized;
      } else if (Platform.isIOS || Platform.isAndroid) {
        return mobileVideoController != null &&
            mobileVideoController!.value.isInitialized;
      }
    }

    return false;
  }

  double getAspectRatio() {
    double? aspectRatio;

    if (!kIsWeb) {
      if (Platform.isWindows) {
        aspectRatio = windowsVideoController?.value.aspectRatio;
      } else if (Platform.isAndroid || Platform.isIOS) {
        aspectRatio = mobileVideoController?.value.aspectRatio;
      }
    }

    return aspectRatio ?? (16 / 9);
  }

  double getMaxDurationInVideo() {
    double? max;

    if (!kIsWeb) {
      if (Platform.isWindows) {
        max = windowsVideoController?.value.duration.inSeconds.toDouble();
      } else if (Platform.isAndroid || Platform.isIOS) {
        max = mobileVideoController?.value.duration.inSeconds.toDouble();
      }
    }

    return max ?? 1;
  }

  String getTextCurrentPosition() {
    String? text;
    Duration? maxDuration;

    if (!kIsWeb) {
      if (Platform.isWindows) {
        maxDuration = windowsVideoController?.value.duration;
      } else if (Platform.isAndroid || Platform.isIOS) {
        maxDuration = mobileVideoController?.value.duration;
      }
    }

    if (maxDuration != null) {
      text = '${formatDuration(Duration(seconds: _currentPosition.toInt()))} / '
          '${formatDuration(maxDuration)}';
    }

    return text ?? '';
  }

  void onChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      windowsVideoController?.pause();
      mobileVideoController?.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (_isPlaying) {
        windowsVideoController?.play();
        mobileVideoController?.play();
      }
    }
  }

  void changePlayState() {
    if (!kIsWeb) {
      if (Platform.isWindows) {
        _changePlayStateWindows();
      } else if (Platform.isAndroid || Platform.isIOS) {
        _changePlayStateMobile();
      }
    }
  }

  void updateChangeSlider(bool value) {
    _isChangeSlider = value;
    if (!_isChangeSlider && _isPlaying) {
      if (!kIsWeb) {
        if (Platform.isWindows) {
          windowsVideoController!.play();
        } else if (Platform.isAndroid || Platform.isIOS) {
          mobileVideoController!.play();
        }
      }
    }
  }

  void seekTo(double seconds) {
    if (!kIsWeb) {
      if (Platform.isWindows) {
        windowsVideoController!.seekTo(Duration(seconds: seconds.toInt()));
        if (_isChangeSlider) {
          windowsVideoController!.pause();
        }
      } else if (Platform.isAndroid || Platform.isIOS) {
        mobileVideoController!.seekTo(Duration(seconds: seconds.toInt()));
        if (_isChangeSlider) {
          mobileVideoController!.pause();
        }
      }
    }
  }

  void _errorUrl() {
    showPopupSingleButton(
      title:
          'Liên kết đã hỏng hoặc chưa đúng, vui lòng thử lại với liên kết khác\nQuay lại trang trước?',
      barrierDismissible: false,
      isError: true,
      context: _context,
      onButtonTap: _navigationService.back,
    );
  }

  void _changePlayStateMobile() {
    if (mobileVideoController?.value.isPlaying == true) {
      mobileVideoController!.pause();
      _isPlaying = false;
    } else {
      mobileVideoController!.play();
      _isPlaying = true;
    }
  }

  void _changePlayStateWindows() {
    if (windowsVideoController?.value.isPlaying == true) {
      windowsVideoController!.pause();
      _isPlaying = false;
    } else {
      windowsVideoController!.play();
      _isPlaying = true;
    }
  }
}
