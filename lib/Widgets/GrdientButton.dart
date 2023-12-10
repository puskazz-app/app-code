import 'package:flutter/material.dart';

class GradientButton extends StatefulWidget {
  double height;
  double width;

  var onPressed;

  String title;
  String content;
  String price;

  GradientButton(
      {super.key,
      required this.onPressed,
      required this.title,
      required this.content,
      required this.price,
      required this.width,
      required this.height});

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: widget.width,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor == Colors.black
                    ? Color(0xFF343434)
                    : Color(0xFfdedede),
                borderRadius: BorderRadius.circular(25)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: widget.width / 2,
                  child: GradientText(
                    widget.title,
                    style: TextStyle(
                        fontSize: 26,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF70d6ff),
                          Color(0xFFff70a6),
                          Color(0xFFff9770),
                          Color.fromARGB(255, 255, 189, 22),
                        ]),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  widget.content,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor, fontSize: 18),
                ),
                SizedBox(
                  height: 10,
                ),
                GradientText(
                  widget.price,
                  style: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF70d6ff),
                        Color(0xFFff70a6),
                        Color(0xFFff9770),
                        Color.fromARGB(255, 255, 189, 22),
                      ]),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    required this.gradient,
    this.style,
  });

  final String text;
  final TextStyle? style;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(text, textAlign: TextAlign.center, style: style),
    );
  }
}
