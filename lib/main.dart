import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Image Labeler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Image Labeler'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  File image;
  var isImageLoaded = false;
  final picker = ImagePicker();
  List<ImageLabel> cloudLabels = List<ImageLabel>();

  Future getImage() async {
      cloudLabels.clear();
      final pickedFile = await picker.getImage(source: ImageSource.gallery);

      setState(() {
      image = File(pickedFile.path);
      isImageLoaded = true;
      });

      FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(image);

      final ImageLabeler cloudLabeler = FirebaseVision.instance.cloudImageLabeler();
      cloudLabels = await cloudLabeler.processImage(visionImage);

      setState(() {
        cloudLabels = cloudLabels;
      });
      cloudLabeler.close();
  }
  
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
          children: <Widget>[
        SizedBox(height: 20.0),
        isImageLoaded ? Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
              height: 300,
              width: 250,
              child: Image.file(
                image,
                fit: BoxFit.cover,
              ),
            ))
            : Padding(padding: const EdgeInsets.all(75.0), child: Text("Please select Image",style: TextStyle(fontSize: 25))),
            SizedBox(height: 10.0),
            SizedBox(height: 10.0),
            Expanded(
             child: SizedBox(
              height: 200.0,
               child: new ListView.builder(
                  shrinkWrap: true,
                  itemCount: cloudLabels.length,
                  itemBuilder: (context, index) {
                   return ListTile(
                    title: Text('${cloudLabels[index].text}'),
                     trailing: Text('${cloudLabels[index].confidence.toStringAsFixed(2)}'),
                );
              },
            )))
    ]),
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
      );
  }
}




