import 'package:flutter/material.dart';

import '../../../constants/app_color.dart';

class LineCampDropDown extends StatelessWidget {
  final String label;
  final String itemShow;
  final List<String> items;
  final ValueChanged<String?>? onItemChanged;

  const LineCampDropDown({
    super.key,
    required this.label,
    required this.items,
    required this.onItemChanged,
    required this.itemShow,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColor.navUnSelect,
              ),
            ),
          ),
          DropdownButton(
            value: itemShow,
            alignment: Alignment.centerRight,
            focusColor: Colors.grey.withOpacity(0.3),
            underline: const SizedBox(height: 0),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColor.navUnSelect,
            ),
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onItemChanged,
          ),
        ],
      ),
    );
  }
}
