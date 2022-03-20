import 'dart:async';

import 'package:flutter/material.dart';
import 'boardpainter.dart';
import 'drawn_path.dart';

class Board extends StatefulWidget {
  const Board({Key? key}) : super(key: key);
@override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board>{

  List<DrawnPath> paths = List.empty(growable: true);
  bool straightLock = false;
  bool smooth = true;

  //Path Images
  ImageInfo? imageBackwards;

  final lineColor = Colors.black; 
  final strokeWidth = 3.0;


  Future<ImageInfo> getImageInfo(BuildContext context) async {
   const AssetImage assetImage = AssetImage("images/paths/backwards.png");
   ImageStream stream = assetImage.resolve(createLocalImageConfiguration(context));
   Completer<ImageInfo> completer = Completer();
   stream.addListener(ImageStreamListener((ImageInfo imageInfo, _) {
      imageBackwards = imageInfo;
      return completer.complete(imageInfo);
   }));
   return completer.future;
}

  @override
Widget build(BuildContext context) {
    return FutureBuilder<ImageInfo>(
          future: getImageInfo(context),
          builder: (context, AsyncSnapshot<ImageInfo> snapshot) {
            if (snapshot.hasData) {
              return Focus(
                      onKey: (FocusNode node, RawKeyEvent event) {
                          straightLock = event.isShiftPressed; 
                          smooth = !event.isControlPressed;
                          return KeyEventResult.handled; 
                      },
                autofocus: true,
                child: buildCurrentPath(context),
              );
            } else {
              return const CircularProgressIndicator();
            }
      });
}

  GestureDetector buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        child: Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: CustomPaint(painter: BoardPainter(paths: paths)),
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    if(mounted)
    {
      final box = context.findRenderObject() as RenderBox;
      final point = box.globalToLocal(details.globalPosition);
      paths.add( DrawnPath(lineColor,strokeWidth, imageBackwards!));
      setState(() => paths[paths.length-1].addPoint(point));
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if(mounted)
    {
      final box = context.findRenderObject() as RenderBox;
      final point = box.globalToLocal(details.globalPosition);
      final pathIndex = paths.length-1;
      final pointList = paths[pathIndex].pathPoints;
      final pointIndex = pointList.length -1;
      //If the user has locked to a straight line just add the point to the end
      if(straightLock && pointIndex > 0)
      {
        setState(() => paths[pathIndex].pathPoints[pointIndex] = point);
      }
      else
      {
          setState(() => paths[pathIndex].addPoint(point));
      }
      
    }
  }

  void onPanEnd(DragEndDetails details) {
    if(mounted)
    {
       final pathIndex = paths.length-1;
        setState(() => paths[pathIndex].finalize(smooth));
    }
  }
}
