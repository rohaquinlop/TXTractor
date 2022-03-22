import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:txtractor/Screens/text_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  int selectedCamera = 0;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<File> capturedImages = [];

  initializeCamera(int camIdx) async {
    _controller = CameraController(
      widget.cameras[camIdx],
      ResolutionPreset.max,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void initState() {
    initializeCamera(selectedCamera);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ImagePicker _picker = ImagePicker();
    InputImage inputImage;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(31, 35, 41, 1),
      /*
      appBar: AppBar(
        title: const Text(
          'TXTractor',
          style: TextStyle(
            color: Color.fromRGBO(252, 70, 67, 1),
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color.fromRGBO(31, 35, 41, 1),
        elevation: 0,
      ),*/
      body: Stack(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(
              child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          )),
          Container(
            padding: const EdgeInsets.all(5.0),
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(31, 35, 41, 0.6),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                      onPressed: () {
                        if (widget.cameras.length > 1) {
                          setState(() {
                            selectedCamera =
                                (selectedCamera + 1) % widget.cameras.length;
                            initializeCamera(selectedCamera);
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('No other camera available'),
                                  duration: Duration(seconds: 2)));
                        }
                      },
                      icon: const Icon(Icons.cameraswitch_rounded,
                          color: Colors.white)),
                  GestureDetector(
                    //Take picture and send it to the extraction screen
                    onTap: () async {
                      await _initializeControllerFuture;
                      var xFile = await _controller.takePicture();
                      inputImage = InputImage.fromFilePath(xFile.path);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TextScreen(
                            inputImage: inputImage,
                          ),
                        ),
                      );
                    },
                    child: const Icon(Icons.camera_alt, color: Colors.white),
                  ),
                  IconButton(
                      //Open gallery, load image and send it to the extraction screen
                      onPressed: () async {
                        final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (image != null) {
                          inputImage = InputImage.fromFilePath(image.path);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TextScreen(
                                inputImage: inputImage,
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.photo_library_rounded,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
