import 'package:flutter/material.dart';

class HomeNavigationBar extends StatefulWidget {
  final int currentIndex;
  final void Function(int) onTabSelected;

  const HomeNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  State<HomeNavigationBar> createState() => _HomeNavigationBarState();
}

class _HomeNavigationBarState extends State<HomeNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currentIndex,
      fixedColor: const Color(0xffEB6E2C),
      unselectedItemColor: const Color(0xff797979),
      onTap: (index) => widget.onTabSelected(index),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
          icon: ColorFiltered(
            colorFilter: ColorFilter.mode(
                widget.currentIndex == 0
                    ? const Color(0xffEB6E2C)
                    : const Color(0xff797979),
                BlendMode.srcIn),
            child: Image.asset(
              'assets/images/ic_device.png',
              width: 24,
              height: 24,
            ),
          ),
          backgroundColor: Colors.grey.shade100,
          label: 'Hệ thống',
        ),
        BottomNavigationBarItem(
          icon: ColorFiltered(
            colorFilter: ColorFilter.mode(
                widget.currentIndex == 1
                    ? const Color(0xffEB6E2C)
                    : const Color(0xff797979),
                BlendMode.srcIn),
            child: Image.asset(
              'assets/images/ic_packData.png',
              width: 24,
              height: 24,
            ),
          ),
          backgroundColor: Colors.grey.shade100,
          label: 'Gói cước',
        ),
        BottomNavigationBarItem(
          icon: ColorFiltered(
            colorFilter: ColorFilter.mode(
                widget.currentIndex == 2
                    ? const Color(0xffEB6E2C)
                    : const Color(0xff797979),
                BlendMode.srcIn),
            child: Image.asset(
              'assets/images/ic_camp.png',
              width: 24,
              height: 24,
            ),
          ),
          backgroundColor: Colors.grey.shade100,
          label: 'Video',
        ),
        BottomNavigationBarItem(
          icon: ColorFiltered(
            colorFilter: ColorFilter.mode(
                widget.currentIndex == 3
                    ? const Color(0xffEB6E2C)
                    : const Color(0xff797979),
                BlendMode.srcIn),
            child: Image.asset(
              'assets/images/ic_statistics.png',
              width: 24,
              height: 24,
            ),
          ),
          backgroundColor: Colors.grey.shade100,
          label: 'Thống kê',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.account_box_rounded,
            color: widget.currentIndex == 4
                ? Colors.orange
                : const Color(0xff797979),
          ),
          backgroundColor: Colors.grey.shade100,
          label: 'Tài khoản',
        ),
      ],
    );
  }
}
