import 'package:flutter/material.dart';

import '../../../constants/app_color.dart';

class MemoryBar extends StatelessWidget {
  // Tổng dung lượng bộ nhớ (byte)
  final double romMemoryTotal;

  // Dung lượng đã sử dụng (byte)
  final double romMemoryUsed;

  final double width;

  const MemoryBar({
    super.key,
    required this.romMemoryTotal,
    required this.romMemoryUsed,
    this.width = 200,
  });

  // Hàm định dạng dung lượng
  String formatMemory(double memoryInBytes) {
    double memoryMB = memoryInBytes / (1024 * 1024);
    if (memoryMB >= 1024) {
      double memoryGB = memoryMB / 1024;
      return '${memoryGB.toStringAsFixed(1)} GB';
    } else {
      return '${memoryMB.toStringAsFixed(1)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    double usageRatio =
        (romMemoryTotal > 0) ? (romMemoryUsed / romMemoryTotal) : 0.0;

    String usedMemoryFormatted = formatMemory(romMemoryUsed);
    String totalMemoryFormatted = formatMemory(romMemoryTotal);

    return SizedBox(
      width: width.clamp(125, 250),
      height: 17.5,
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColor.borderMemoryBar, width: 1),
                    color: AppColor.bgMemoryFree,
                  ),
                  alignment: AlignmentDirectional.centerStart,
                  child: FractionallySizedBox(
                    widthFactor: usageRatio.clamp(0, 1),
                    child: Container(
                      decoration:
                          const BoxDecoration(color: AppColor.bgMemoryUsed),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '$usedMemoryFormatted / $totalMemoryFormatted',
                    style: const TextStyle(color: Colors.black, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
