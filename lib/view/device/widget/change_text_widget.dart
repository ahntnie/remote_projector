import 'package:flutter/material.dart';

class ChangeTextWidget extends StatefulWidget {
  const ChangeTextWidget({super.key, this.text, this.onChanged});

  final String? text;
  final Function(String?)? onChanged;

  @override
  State<ChangeTextWidget> createState() => _ChangeTextWidgetState();
}

class _ChangeTextWidgetState extends State<ChangeTextWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEB6E2C), Color(0xFFFABD1D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: const BoxConstraints(maxWidth: 450),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                onSubmitted: (text) {
                  widget.onChanged?.call(text);
                  Navigator.of(context).pop();
                },
                decoration: const InputDecoration(
                  hintText: 'Nhập thông tin',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: UnderlineInputBorder(),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: Navigator.of(context).pop,
                      child: const Text(
                        'Hủy',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onChanged?.call(_controller.text);
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Thay đổi',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
