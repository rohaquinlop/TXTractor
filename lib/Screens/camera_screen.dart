import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

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
    return Scaffold(
      backgroundColor: const Color.fromRGBO(19, 13, 112, 1),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Center(
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
                    setState(() {
                      capturedImages.add(File(xFile.path));
                    });
                  },
                  child: const Icon(Icons.camera_alt, color: Colors.white),
                ),
                IconButton(
                    //Open gallery, load image and send it to the extraction screen
                    onPressed: () {},
                    icon: const Icon(Icons.photo_library_rounded,
                        color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
