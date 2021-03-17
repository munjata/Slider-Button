import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

import 'shimmer.dart';

class SliderButton extends StatefulWidget {
  ///To make button more customizable add your child widget
  final Widget child;

  ///Sets the radius of corners of a button.
  final double radius;

  ///Use it to define a height and width of widget.
  final double height;
  final double width;
  final double buttonSize;

  ///Use it to define a color of widget.
  final Color backgroundColor;
  final Color baseColor;
  final Color highlightedColor;
  final Color buttonColor;

  ///Change it to gave a label on a widget of your choice.
  final Text label;

  ///Gives a alignment to a slidder icon.
  final Alignment alignLabel;
  final BoxShadow boxShadow;
  final Widget icon;
  final Function action;

  ///Make it false if you want to deactivate the shimmer effect.
  final bool shimmer;

  ///Make it false if you want maintain the widget in the tree.
  final bool dismissible;

  final bool vibrationFlag;

  /// If the app direction is Right To Left like in Nko, Arabic.
  final bool isRtl;

  ///The offset threshold the item has to be dragged in order to be considered
  ///dismissed e.g. if it is 0.4, then the item has to be dragged
  /// at least 40% towards one direction to be considered dismissed
  final double dismissThresholds;

  final bool disable;
  SliderButton({
    @required this.action,
    this.radius = 100,
    this.boxShadow = const BoxShadow(
      color: Colors.black,
      blurRadius: 4,
    ),
    this.child,
    this.vibrationFlag = true,
    this.shimmer = true,
    this.height = 70,
    this.buttonSize = 60,
    this.width = 250,
    this.alignLabel = const Alignment(0.4, 0),
    this.backgroundColor = const Color(0xffe0e0e0),
    this.baseColor = Colors.black87,
    this.buttonColor = Colors.white,
    this.highlightedColor = Colors.white,
    this.label = const Text(
      "Slide to cancel !",
      style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
    ),
    this.icon = const Icon(
      Icons.power_settings_new,
      color: Colors.red,
      size: 30.0,
      semanticLabel: 'Text to announce in accessibility modes',
    ),
    this.dismissible = true,
    this.dismissThresholds = 1.0,
    this.disable = false,
    this.isRtl = false,
  }) : assert(buttonSize <= height);

  @override
  _SliderButtonState createState() => _SliderButtonState(isRtl);
}

class _SliderButtonState extends State<SliderButton> {
  final bool isRtl;
  bool flag;

  _SliderButtonState(this.isRtl);

  @override
  void initState() {
    super.initState();
    flag = true;
  }

  @override
  Widget build(BuildContext context) {
    return flag == true
        ? _control()
        : widget.dismissible == true
            ? Container()
            : Container(
                child: _control(),
              );
  }

  Widget _control() => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: widget.disable ? Colors.grey.shade700 : widget.backgroundColor,
          borderRadius: BorderRadius.circular(widget.radius),
        ),
        alignment: Alignment.centerLeft,
        child: Stack(
          alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
          children: <Widget>[
            _buildColorContainer(),
            Container(
              child: SizedBox.expand(),
            ),
            widget.disable ? _buildTooltip() : _buildDismissible(),
          ],
        ),
      );

  Container _buildColorContainer() => Container(
        alignment: isRtl ? Alignment.centerLeft : Alignment.centerRight,
        child: widget.shimmer && !widget.disable
            ? Shimmer.fromColors(
                baseColor: widget.disable ? Colors.grey : widget.baseColor,
                highlightColor: widget.highlightedColor,
                child: widget.label,
              )
            : widget.label,
      );
  Tooltip _buildTooltip() => Tooltip(
        verticalOffset: 50,
        message: 'Button is disabled',
        child: Container(
          width: widget.width - (widget.height),
          height: widget.height,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(
            left: (widget.height - widget.buttonSize) / 2,
          ),
          child: widget.child ??
              Container(
                height: widget.buttonSize,
                width: widget.buttonSize,
                decoration: BoxDecoration(boxShadow: [
                  widget.boxShadow,
                ], color: Colors.grey, borderRadius: BorderRadius.circular(widget.radius)),
                child: Center(child: widget.icon),
              ),
        ),
      );

  Dismissible _buildDismissible() => Dismissible(
        key: Key("cancel"),
        direction: widget.isRtl ? DismissDirection.endToStart : DismissDirection.startToEnd,
        dismissThresholds: {DismissDirection.startToEnd: widget.dismissThresholds},

        ///gives direction of swipping in argument.
        onDismissed: (dir) async {
          setState(() {
            if (widget.dismissible) {
              flag = false;
            } else {
              flag = !flag;
            }
          });

          widget.action();
          if (widget.vibrationFlag && await Vibration.hasVibrator()) {
            try {
              Vibration.vibrate(duration: 200);
            } catch (e) {
              print(e);
            }
          }
        },
        child: Container(
          width: widget.width - (widget.height),
          height: widget.height,
          alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
          padding: EdgeInsets.only(
            left: (widget.height - widget.buttonSize) / 2,
          ),
          child: widget.child ??
              Container(
                height: widget.buttonSize,
                width: widget.buttonSize,
                decoration: BoxDecoration(
                  boxShadow: [widget.boxShadow],
                  color: widget.buttonColor,
                  borderRadius: BorderRadius.circular(widget.radius),
                ),
                child: Center(child: widget.icon),
              ),
        ),
      );
}
