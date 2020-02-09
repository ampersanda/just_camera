import 'package:flutter/widgets.dart';
import 'package:just_camera/colors.dart';

class SimpleButton extends StatefulWidget {
  const SimpleButton({
    this.child,
    @required this.onPressed,
    this.builder,
  });

  final Widget child;
  final Widget Function(Widget, bool) builder;
  final VoidCallback onPressed;

  @override
  _SimpleButtonState createState() => _SimpleButtonState();
}

class _SimpleButtonState extends State<SimpleButton> {
  bool isPressing = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 100),
      opacity: isPressing ? 0.4 : 1.0,
      child: GestureDetector(
        onTapDown: (TapDownDetails details) {
          if (widget.onPressed != null) {
            setState(() {
              isPressing = true;
            });
          }
        },
        onTapCancel: () {
          if (widget.onPressed != null) {
            setState(() {
              isPressing = false;
            });
          }
        },
        onTap: widget.onPressed != null
            ? () {
                setState(() {
                  isPressing = false;
                });
                widget.onPressed();
              }
            : null,
        child: IconTheme(
          data: IconThemeData(
            size: 48.0,
            color: Colors.white,
          ),
          child: widget.builder != null
              ? widget.builder(widget.child, isPressing)
              : widget.child ?? const SizedBox(),
        ),
      ),
    );
  }
}
