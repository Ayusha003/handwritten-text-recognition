import 'dart:convert';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_placeholder_textlines/flutter_placeholder_textlines.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:translator_project/core/styles/app_colors.dart';
import 'package:translator_project/core/styles/app_text_styles.dart';
import 'package:translator_project/screens/chat_page.dart';
import 'package:translator_project/screens/history_page.dart';
import 'package:translator_project/services/serviceRoutes.dart';

import '../core/EditableTextWidget.dart';
import '../services/pythonService.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Uint8List? imageBytes;
  bool isLoading = false;
  bool isGeneratingText = false;
  bool isSpeaking = false;
  String generatedText = "Your generated text will appear here.";
  late FlutterTts flutterTts;
  String pickedImagePath = "";
  bool saving = false;
  late TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;
      });
    });
  }

  Future<void> pickImageDesktop() async {
    final picker = ImagePicker();
    setState(() {
      isLoading = true;
    });

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();

      setState(() {
        imageBytes = bytes;
        isLoading = false;
        pickedImagePath = pickedFile.path;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print('No image selected');
    }
  }

  void deleteImage() {
    setState(() {
      imageBytes = null;
      generatedText = "Your generated text will appear here.";
    });
  }

  void generateText() async {
    if (imageBytes == null) return;

    setState(() {
      isGeneratingText = true;
      generatedText = "";
    });

    // Simulating text generation delay
    // await Future.delayed(Duration(seconds: 3));
    PythonService pService = PythonService();
    if(pickedImagePath != "" || pickedImagePath.isNotEmpty){
      await pService.post(System.FETCH_TEXT, {"imgPath": pickedImagePath}).then((rsp) async {
        debugPrint("Rsp FETCH_TEXT: ${rsp.toString()}");
        Map<String,dynamic> responseJSON = json.decode(json.encode(rsp));
        if(responseJSON['success']){
          setState(() {
            generatedText = responseJSON['data'];
            _controller.text = generatedText;
            isGeneratingText = false;
          });
        }
        else{
          setState(() {
            isGeneratingText = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Unable to get image text , check backend")),
          );
        }
      });

    }

  }

  void saveText()async {
    setState(() {
      saving =true;
    });
    await Future.delayed(Duration(seconds: 2));
    PythonService pService = PythonService();
    if (pickedImagePath != "" || pickedImagePath.isNotEmpty) {
      await pService.post(
          System.SAVE_TEXT, {"imgPath": pickedImagePath, "text": _controller.text.trim()})
          .then((rsp) async {
        debugPrint("Rsp SAVE_TEXT: ${rsp.toString()}");
        Map<String, dynamic> responseJSON = json.decode(json.encode(rsp));
        if (responseJSON['success']) {
          deleteImage();
          setState(() {
            _controller.clear();
            generatedText = "";
            isGeneratingText = false;
            saving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Note Saved")),
          );
        }
        else {
          setState(() {
            isGeneratingText = false;
            saving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Unable to save text , check backend")),
          );
        }
      });
    }
  }

  void speakText() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      isSpeaking = true;
    });

    await flutterTts.speak(_controller.text.trim());
  }

  void stopSpeaking() async {
    await flutterTts.stop();
    setState(() {
      isSpeaking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Pen2Pixel",
          style: AppTextStyles.textStyleSFProText.copyWith(
            color: Colors.black,           // Set text color to black
            fontWeight: FontWeight.w900,   // Extra bold
            fontSize: 22,                  // Increase font size
          ),
        ),
        backgroundColor: AppColors.colorBlue,
        actions: [
          Row(
            children: [
              Icon(Icons.home),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => HomePage(),
                    ),
                  );
                },
                child: Text(
                  "Home",
                  style: AppTextStyles.textStyleSFProText,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.history),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => HistoryPage(),
                    ),
                  );
                },
                child: Text(
                  "History",
                  style: AppTextStyles.textStyleSFProText,
                ),
              ),
              SizedBox(width: 10),
              Icon(Icons.account_circle_outlined),
              SizedBox(width: 30),
            ],
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 450,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: pickImageDesktop,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                DottedBorder(
                                  dashPattern: [8, 4],
                                  strokeWidth: 1,
                                  borderType: BorderType.RRect,
                                  radius: Radius.circular(12),
                                  child: Container(
                                    height: 300,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                    ),
                                    child: isLoading
                                        ? Center(child: CircularProgressIndicator())
                                        : imageBytes == null
                                            ? Center(
                                                child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.upload),
                                                  SizedBox(width: 10),
                                                  Text("Tap to select image"),
                                                ],
                                              ))
                                            : Image.memory(
                                                imageBytes!,
                                                width: 200,
                                                height: 200,
                                              ),
                                  ),
                                ),
                                if (imageBytes != null)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: deleteImage,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: EdgeInsets.all(8),
                                        child: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.textColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: generateText,
                              child: Text(
                                "Generate Text",
                                style: AppTextStyles.textStyleSFProText.copyWith(
                                  color: AppColors.colorWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                            SizedBox(width: 15),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.textColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: (){
                                saveText();
                              },
                              child: Text(
                                "Save",
                                style: AppTextStyles.textStyleSFProText.copyWith(
                                  color: AppColors.colorWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 15),
                        if (isLoading || imageBytes != null)
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isLoading
                                  ? Colors.blue.shade50
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isLoading ? Colors.blue : Colors.green,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              isLoading
                                  ? "Uploading image, please wait..."
                                  : "Image uploaded successfully!",
                              textAlign: TextAlign.center,
                              style: AppTextStyles.textStyleSFProText.copyWith(
                                color: isLoading ? Colors.blue : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 450,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.colorWhite,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Summary",
                          style: AppTextStyles.textStyleSFProText,
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: isGeneratingText
                                ? Center(
                                    child: PlaceholderLines(
                                      count: 9,
                                      animate: true,
                                      lineHeight: 12,
                                    ),
                                  )
                                :TextField(
                              controller: _controller,
                              onEditingComplete: (){
                                setState(() {
                                  generatedText = _controller.text;
                                });
                              },
                              maxLines: null,
                              style: AppTextStyles.textStyleSFProText,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Edit text here',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        if (imageBytes != null)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.textColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: isSpeaking ? stopSpeaking : speakText,
                            icon: Icon(
                              isSpeaking ? Icons.cancel : Icons.volume_up,
                              color: AppColors.colorWhite,
                            ),
                            label: Text(
                              isSpeaking ? "Cancel" : "Listen",
                              style: AppTextStyles.textStyleSFProText.copyWith(
                                color: AppColors.colorWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            saving?Expanded(
              child: Container(
                color: Colors.black38,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 250,
                          height: 250,
                          decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(12))),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(strokeWidth: 2,valueColor: AlwaysStoppedAnimation<Color>(Colors.blue))),
                              SizedBox(height:10),
                              Text("Saving ....",style: TextStyle(color: Colors.blue,fontWeight: FontWeight.w300,fontSize: 15),)

                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ):Container(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.colorWhite,
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (builder) => ChatPage(),
            ),
          );
        },
        child: Icon(
          Icons.chat_bubble_outline,
          color: AppColors.textColor,
        ),
      ),
    );
  }
}
