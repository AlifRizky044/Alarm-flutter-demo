import 'package:flutter/material.dart';


class Wheel extends StatefulWidget {

  @override
  _WheelState createState() => _WheelState();
}

class _WheelState extends State<Wheel> {
  final double radius = 150;
  String _color = "nothing";
  double _movement = 0;


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(_movement > 0 ? 'Clockwise' : 'Counter-Clockwise', style: Theme.of(context).textTheme.subtitle1,),
          Text('$_movement'),
          Text(_color),
          Stack(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(

                  color: Colors.red,
                ),
              ),
              GestureDetector(
                  onPanUpdate: _panHandler,
                  child: Container(
                    height: radius * 2,
                    width: radius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  )
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _panHandler(DragUpdateDetails d) {
    if(d.localPosition.dy>=250 && d.localPosition.dy <= 280){
      setState(() {
        _color = "red";
      });
    }else{
      setState(() {
        _color = "nothing";
      });
    }
    /// Pan location on the wheel
    bool onTop = d.localPosition.dy <= radius;
    bool onLeftSide = d.localPosition.dx <= radius;
    bool onRightSide = !onLeftSide;
    bool onBottom = !onTop;

    /// Pan movements
    bool panUp = d.delta.dy <= 0.0;
    bool panLeft = d.delta.dx <= 0.0;
    bool panRight = !panLeft;
    bool panDown = !panUp;

    /// Absoulte change on axis
    double yChange = d.delta.dy.abs();
    double xChange = d.delta.dx.abs();

    /// Directional change on wheel
    double vert = (onRightSide && panUp) || (onLeftSide && panDown)
        ? yChange * -1
        : yChange;

    double horz = (onTop && panLeft) || (onBottom && panRight)
        ? xChange * -1
        : xChange;

    // Total computed change
    double rotationalChange = vert + horz;

    bool movingClockwise = rotationalChange > 0;
    bool movingCounterClockwise = rotationalChange < 0;

    setState(() {
      _movement = vert;
    });

    // Now do something interesting with these computations!
  }
}