import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:stacked/stacked.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_win/video_player_win.dart';

import '../../constants/app_color.dart';
import '../../view_models/review_video.vm.dart';

class ReviewVideoPage extends StatefulWidget {
  final String urlFile;
  final int videoType;

  const ReviewVideoPage({
    super.key,
    required this.urlFile,
    required this.videoType,
  });

  @override
  State<ReviewVideoPage> createState() => _ReviewVideoPageState();
}

class _ReviewVideoPageState extends State<ReviewVideoPage>
    with WidgetsBindingObserver {
  late ReviewVideoViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = ReviewVideoViewModel(
      urlFile: widget.urlFile,
      videoType: widget.videoType,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    viewModel.onChangeAppLifecycleState(state);
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReviewVideoViewModel>.reactive(
      viewModelBuilder: () => viewModel,
      onViewModelReady: (viewModel) {
        viewModel.updateContext(context);
        viewModel.initialise();
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    viewModel.isControllerAlready()
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 55),
                                child: Text(
                                  'Đang phát: ${basenameWithoutExtension(widget.urlFile)}',
                                  maxLines: 2,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height - 150,
                                ),
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: viewModel.getAspectRatio(),
                                    child: Stack(
                                      children: [
                                        viewModel.mobileVideoController != null
                                            ? VideoPlayer(viewModel
                                                .mobileVideoController!)
                                            : viewModel.windowsVideoController !=
                                                    null
                                                ? WinVideoPlayer(viewModel
                                                    .windowsVideoController!)
                                                : const SizedBox(),
                                        InkWell(
                                          onTap: viewModel.changePlayState,
                                          child: const SizedBox(
                                            height: double.infinity,
                                            width: double.infinity,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: [
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: viewModel.changePlayState,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(17.5)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5),
                                          child: Icon(
                                            viewModel.isPlaying
                                                ? Icons.pause_circle_rounded
                                                : Icons.play_circle_rounded,
                                            size: 25,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Slider(
                                        value: viewModel.currentPosition,
                                        min: 0,
                                        max: viewModel.getMaxDurationInVideo(),
                                        activeColor: AppColor.navSelected,
                                        onChanged: viewModel.seekTo,
                                        onChangeStart: (_) =>
                                            viewModel.updateChangeSlider(true),
                                        onChangeEnd: (_) =>
                                            viewModel.updateChangeSlider(false),
                                      ),
                                    ),
                                    Text(
                                      viewModel.getTextCurrentPosition(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : const CircularProgressIndicator(),
                  ],
                ),
              ),
              Positioned(
                right: 10,
                top: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColor.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    color: Colors.white,
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 35),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
