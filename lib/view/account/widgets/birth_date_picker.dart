import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../constants/app_color.dart';
import '../../../models/user/user.dart';
import 'account_list_title.dart';

class BirthDatePicker extends StatelessWidget {
  final Function(DateTime?) onDatePicked;
  final User? currentUser;

  const BirthDatePicker({
    super.key,
    required this.onDatePicked,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return AccountListTile(
      leadingIcon: Image.asset(
        'assets/images/ic_calendar.png',
        width: 24,
        height: 24,
      ),
      onTap: () => _showDatePicker(context),
      customTitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ngày sinh',
            style: TextStyle(fontSize: 12, color: Color(0xff797979)),
          ),
          Text(
            currentUser != null &&
                    currentUser!.dateOfBirth != null &&
                    currentUser!.dateOfBirth!.isNotEmpty &&
                    currentUser!.dateOfBirth! != '0000-00-00'
                ? DateFormat('dd-MM-yyyy')
                    .format(DateTime.parse(currentUser!.dateOfBirth!))
                : 'Thêm ngày, tháng, năm sinh',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    var results = await showCalendarDatePicker2Dialog(
      context: context,
      dialogBackgroundColor: Colors.grey.shade100,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.single,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        cancelButton: const Text(
          'Hủy',
          style: TextStyle(
            color: AppColor.navSelected,
            fontWeight: FontWeight.bold,
          ),
        ),
        okButton: const Text(
          'Xác nhận',
          style: TextStyle(
            color: AppColor.navSelected,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      value: [DateTime.now()],
      dialogSize: const Size(450, 400),
      borderRadius: BorderRadius.circular(15),
    );

    if (results != null && results.isNotEmpty) {
      onDatePicked(results[0]);
    }
  }
}
