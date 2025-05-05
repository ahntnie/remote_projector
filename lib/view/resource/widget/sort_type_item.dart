import 'package:flutter/material.dart';

import '../../../constants/app_color.dart';
import '../../../models/resource/sort_type.dart';

class SortTypeItem extends StatelessWidget {
  final SortType data;
  final bool isSelected;
  final Function(SortType)? onChanged;

  const SortTypeItem({
    super.key,
    required this.data,
    required this.isSelected,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged?.call(data),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    data.name,
                    style: const TextStyle(color: AppColor.black, fontSize: 14),
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColor.navSelected : AppColor.black,
                      width: 1.5,
                    ),
                  ),
                  padding: const EdgeInsets.all(2.5),
                  child: isSelected
                      ? Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.5),
                            color: AppColor.navSelected,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
