import 'package:draggable_widget/draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
void main() {

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: DraggableWidget(
          effectHeight: 100,
        effectWidth: 100,
        leftPadding: 10,
        topPadding: 10,
        child: Container(color: Colors.green,),),
      ),
    );
  }
}