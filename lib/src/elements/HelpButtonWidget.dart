import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter/cupertino.dart';

class HelpButtonWidget extends StatefulWidget {
  const HelpButtonWidget({Key? key, required this.color, required this.showHelpDialog})
      : super(key: key);

  final Color color;
  final Function showHelpDialog;

  @override
  _HelpButtonWidgetState createState() => _HelpButtonWidgetState();
}

class _HelpButtonWidgetState extends StateMVC<HelpButtonWidget> {
  @override
  Widget build(BuildContext context) {

/*
    return IconButton(
      icon: Icon(Icons.help, color: widget.color),
      iconSize: 70,
      onPressed: () => widget.showHelpDialog(),
    );
*/
    return InkWell(
      child: Icon(
        Icons.help,
        size: 70,
        color: Theme.of(context).accentColor,
      ),
      onTap: () => widget.showHelpDialog(),
    );



  }
}
