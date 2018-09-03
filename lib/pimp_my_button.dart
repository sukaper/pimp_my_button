library pimp_my_button;

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

// The bounding box for context in global coordinates.
Rect _globalBoundingBoxFor(BuildContext context) {
  final RenderBox box = context.findRenderObject();
  assert(box != null && box.hasSize);
  return MatrixUtils.transformRect(box.getTransformTo(null), Offset.zero & box.size);
}

class PimpedButton extends StatefulWidget {
  final WidgetBuilder widgetBuilder;

  const PimpedButton({Key key, this.widgetBuilder}) : super(key: key);

  @override
  PimpedButtonState createState() => new PimpedButtonState();
}

class PimpedButtonState extends State<PimpedButton> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext childContext) {
        return widget.widgetBuilder(childContext);
      },
    );
  }

  static Future playAnimation(BuildContext context, TickerProvider vsync) {
    PimpedButtonState state = context.ancestorStateOfType(const TypeMatcher<PimpedButtonState>());

    Rect bounds = _globalBoundingBoxFor(state.context);

    AnimationController controller = AnimationController(vsync: vsync, duration: Duration(milliseconds: 800));

    double progress = 0.0;
    OverlayEntry entry = OverlayEntry(
      builder: (context) {
        return Positioned.fromRect(
            rect: bounds.inflate(bounds.width),
            child: IgnorePointer(
              child: CustomPaint(
                painter: PimpPainter(progress: progress),
              ),
            ));
      },
    );

    Overlay.of(context).insert(entry);

    controller.addListener(() {
      progress = controller.value;
      entry.markNeedsBuild();
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed || status == AnimationStatus.completed) {
        entry.remove();
      }
    });

    controller.forward();
  }
}


abstract class AnimatableCustomPainter extends CustomPainter{

}

class PimpPainter extends CustomPainter {
  final double progress;

  PimpPainter({@required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    PoppingCircle(Offset(40.0, 100.0)).paint(canvas, size, progress);
    paintFlyingRect(canvas, Offset(10.0, 50.0), calcRotation(Offset(0.0,0.0), Offset(10.0, 50.0)));
    for(int i = 0; i < 4; i++) {
      paintSection(canvas, Size(size.width / 2, size.height / 2));
      canvas.rotate(pi / 2);
    }
  }

  double calcRotation(Offset middle, Offset point) {
    return atan2(point.dy - middle.dy, point.dx - middle.dx);
  }

  void paintSection(Canvas canvas, Size size) {
    canvas.drawCircle(
        Offset(size.width / 2 + (size.width / 4) * progress, size.height / 2 + (size.height / 4) * progress),
        4.0,
        Paint()..color = Colors.red
    );
  }

  void paintFlyingRect(Canvas canvas, Offset start, double rotation) {
    canvas.save();
    canvas.rotate(rotation);
    canvas.drawRect(Rect.fromLTWH(start.dx, start.dy + (progress * 30.0), 5.0, 10.0), Paint()..color = Colors.black);
    canvas.restore();
  }


  @override
  bool shouldRepaint(PimpPainter oldDelegate) => oldDelegate.progress != progress;
}


abstract class Particle {
  void paint(Canvas canvas, Size size, double progress);
}


class PoppingCircle extends Particle {

  final Offset position;

  PoppingCircle(this.position);


  @override
  void paint(Canvas canvas, Size size, double progress) {
    canvas.drawCircle(position, 3.0 + (progress * 8), Paint()..color = Colors.yellow);
  }

}




