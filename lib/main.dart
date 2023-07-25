// original code is here, this is upadated version for the new Flutter
// https://gist.github.com/guptahitesh121/ca7fa34d73b8b024823c85dd0c7f687d

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swipe Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SwipeDemo(),
    );
  }
}

class SwipeDemo extends StatefulWidget {
  const SwipeDemo({Key? key}) : super(key: key);

  @override
  SwipeDemoState createState() => SwipeDemoState();
}

class SwipeDemoState extends State<SwipeDemo> {
  Offset offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: TwoFingerPointerWidget(
        onUpdate: (details) {
          setState(() {
            offset += details.delta;
          });
        },
        child: Container(
          alignment: Alignment.center,
          color: Colors.white,
          child: Transform.translate(
            //offset controlls how much "moves" the element
            offset: offset,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}

class TwoFingerPointerWidget extends StatelessWidget {
  final Widget child;
  final OnUpdate onUpdate;

  const TwoFingerPointerWidget({
    Key? key,
    required this.child,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        CustomVerticalMultiDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<
                CustomVerticalMultiDragGestureRecognizer>(
          () => CustomVerticalMultiDragGestureRecognizer(debugOwner: null),
          (CustomVerticalMultiDragGestureRecognizer instance) {
            instance.onStart = (Offset position) {
              return CustomDrag(
                events: instance.events,
                onUpdate: onUpdate,
              );
            };
          },
        ),
      },
      child: child,
    );
  }
}

typedef OnUpdate = Function(DragUpdateDetails details);

class CustomDrag extends Drag {
  final List<PointerDownEvent> events;

  final OnUpdate onUpdate;

  CustomDrag({required this.events, required this.onUpdate});

  @override
  void update(DragUpdateDetails details) {
    super.update(details);
    final delta = details.delta;
    //with event.length we determinate the number of imputs ( in this case
    //could be interpreted as the number of fingers on the screen)
    if (delta.dy.abs() > 0 && (events.length == 2 || events.length == 1)) {
      onUpdate.call(DragUpdateDetails(
        sourceTimeStamp: details.sourceTimeStamp,
        delta: Offset(0, delta.dy),
        primaryDelta: details.primaryDelta,
        globalPosition: details.globalPosition,
        localPosition: details.localPosition,
      ));
    }
  }
}

class CustomVerticalMultiDragGestureRecognizer
    extends MultiDragGestureRecognizer {
  final List<PointerDownEvent> events = [];

  CustomVerticalMultiDragGestureRecognizer({required Object? debugOwner})
      : super(debugOwner: debugOwner);

  @override
  createNewPointerState(PointerDownEvent event) {
    events.add(event);
    return _CustomVerticalPointerState(event.position, onDisposeState: () {
      events.remove(event);
    });
  }

  @override
  String get debugDescription => 'custom vertical multi drag';
}

typedef OnDisposeState = Function();

class _CustomVerticalPointerState extends MultiDragPointerState {
  final OnDisposeState onDisposeState;

  _CustomVerticalPointerState(Offset initialPosition,
      {required this.onDisposeState})
      : super(initialPosition, PointerDeviceKind.touch, null);

  @override
  void checkForResolutionAfterMove() {
    //review about kTouchSlop
    if (pendingDelta!.dy.abs() > kTouchSlop) {
      resolve(GestureDisposition.accepted);
    }
  }

  @override
  void accepted(GestureMultiDragStartCallback starter) {
    starter(initialPosition);
  }

  @override
  void dispose() {
    onDisposeState.call();
    super.dispose();
  }
}
