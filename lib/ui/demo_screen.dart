import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

class DemoScreen extends StatelessWidget {
  final String path;
  DemoScreen({this.path});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          decoration: BoxDecoration(
            color: Colors.black,
          ),
          child: PhotoView(
            imageProvider: FileImage(File(path)),
          )),
    );
  }
}
