import 'dart:ffi';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter/services.dart';
import 'package:txtractor/main.dart';

class TextScreen extends StatefulWidget {
  var inputImage;

  TextScreen({Key? key, required this.inputImage}) : super(key: key);

  @override
  State<TextScreen> createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  final textDetector = GoogleMlKit.vision.textDetector();
  final TextEditingController _TextController = TextEditingController();
  late List<String> texts;

  Future getTextFromImage() async {
    List<String> ans = [];

    final RecognisedText recognisedText =
        await textDetector.processImage(widget.inputImage);

    for (TextBlock block in recognisedText.blocks) {
      ans.add(block.text);
    }

    return ans;
  }

  String concatenateText(List<String> texts) {
    String ans = "";

    for (String text in texts) {
      ans += text + "\n";
    }

    return ans;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    textDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(31, 35, 41, 1),
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
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text('Results of the TXTraction',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 20),
          FutureBuilder(
            future: getTextFromImage(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                texts = snapshot.data;
                var finalText = concatenateText(texts);
                _TextController.text = finalText;
                //Show the finalText on a text box and let the user copy it
                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Scrollbar(
                      child: TextField(
                    controller: _TextController,
                    textInputAction: TextInputAction.newline,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: const TextStyle(
                      color: Color.fromRGBO(31, 35, 41, 1),
                      fontSize: 20,
                    ),
                    decoration: const InputDecoration(
                        fillColor: Colors.white, filled: true),
                  )),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromRGBO(252, 70, 67, 1),
        child: const Icon(Icons.content_copy),
        onPressed: () =>
            {Clipboard.setData(ClipboardData(text: _TextController.text))},
      ),
    );
  }
}
