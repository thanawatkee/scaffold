import 'package:tflite_v2/tflite_v2.dart';

////////////////////////

  bool isModelLoaded = false;
  List<dynamic>? recognitions;
  int imageHeight = 0;
  int imageWidth = 0;

////////////////////////

  Future<void> runModelOnImagePath() async {
    if (!isModelLoaded) return;

    // อ่านขนาดภาพจริง เพื่อสเกล Bounding Box ให้ถูกต้อง
    final bytes = await File(_imagePath!).readAsBytes();
    final codecImg = await decodeImageFromList(bytes); // จาก dart:ui
    imageWidth = codecImg.width;
    imageHeight = codecImg.height;

    final recs = await Tflite.detectObjectOnImage(
      path: _imagePath!,
      model: 'yolov8',
      imageMean: 127.5,
      imageStd: 127.5,
      numResultsPerClass: 1,
      threshold: 0.4,
    );

    setState(() {
      recognitions = recs;
    });
  }

  Future<void> loadModel() async {
    String? res = await Tflite.loadModel(
      model: 'assets/yolov8n.tflite',
      labels: 'assets/labels.txt',
    );
    setState(() {
      isModelLoaded = res != null;
    });
  }
