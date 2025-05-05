import 'package:flutter/material.dart';

import '../../../constants/app_color.dart';
import '../../../models/user/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final ValueChanged<User>? onCancelSharedTap;

  const UserCard({
    super.key,
    required this.user,
    this.onCancelSharedTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tên: ${user.customerName}',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Email: ${user.email}',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'SĐT: ${user.phoneNumber}',
                    style: const TextStyle(fontSize: 14.0),
                  ),
                  const SizedBox(height: 3),
                ],
              ),
            ),
            Container(
              width: 40,
              decoration: const BoxDecoration(
                color: AppColor.bgDir,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onCancelSharedTap?.call(user),
                  borderRadius: const BorderRadius.all(Radius.circular(5)),
                  child: const Padding(
                    padding: EdgeInsets.all(5),
                    child: Center(
                      child: Text(
                        'Hủy',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
