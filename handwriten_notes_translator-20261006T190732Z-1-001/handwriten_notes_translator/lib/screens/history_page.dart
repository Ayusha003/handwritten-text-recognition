// Full working code for HistoryPage with deletion functionality
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:translator_project/core/styles/app_colors.dart';
import 'package:translator_project/core/styles/app_text_styles.dart';
import 'package:translator_project/models/NotesDataModel.dart';
import 'package:translator_project/screens/home_page.dart';
import 'package:path/path.dart' as p;

import '../services/pythonService.dart';
import '../services/serviceRoutes.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<NotesDataModel> savedNotes = [];

  Future<void> readDbJsonFile(BuildContext c) async {
    final String filePath = r'C:\ProgramData\HandWritenNotesDb\db.json';
    final File file = File(filePath);

    try {
      if (!await file.exists()) {
        print('Error: File not found at \$filePath');
        return;
      }

      String contents = await file.readAsString();
      List<dynamic> jsonList = json.decode(contents);
      savedNotes.clear();

      for (var item in jsonList) {
        if (item is Map<String, dynamic>) {
          setState(() {
            savedNotes.add(NotesDataModel.fromJson(item));
          });
        }
      }
    } catch (e) {
      print('Error reading or parsing db.json: \$e');
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => readDbJsonFile(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(
          "Pen2Pixel",
          style: AppTextStyles.textStyleSFProText.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 22,
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
                    MaterialPageRoute(builder: (builder) => HomePage()),
                  );
                },
                child: Text("Home", style: AppTextStyles.textStyleSFProText),
              ),
              SizedBox(width: 10),
              Icon(Icons.history),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (builder) => HistoryPage()),
                  );
                },
                child: Text("History", style: AppTextStyles.textStyleSFProText),
              ),
              SizedBox(width: 10),
              Icon(Icons.account_circle_outlined),
              SizedBox(width: 30),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemCount: savedNotes.length,
              itemBuilder: (context, index) {
                final item = savedNotes[index];
                return Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: FileImage(File(item.imagePath)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 10.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.text,
                                textAlign: TextAlign.center,
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text('${item.timeStamp}',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete_outline, color: Colors.black),
                              onPressed: () async {
                                final String filePath = r'C:\ProgramData\HandWritenNotesDb\db.json';
                                final File file = File(filePath);

                                try {
                                  if (await file.exists()) {
                                    String contents = await file.readAsString();
                                    List<dynamic> jsonList = json.decode(contents);

                                    jsonList.removeWhere((note) =>
                                    note['timeStamp'] == item.timeStamp &&
                                        note['text'] == item.text &&
                                        note['imagePath'] == item.imagePath);

                                    await file.writeAsString(json.encode(jsonList));

                                    setState(() {
                                      savedNotes.removeAt(index);
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Note deleted successfully")),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("db.json file not found.")),
                                    );
                                  }
                                } catch (e) {
                                  print('Error deleting note: \$e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error deleting note")),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.download, color: Colors.black),
                              onPressed: () {
                                String fileNameWithoutExtension =
                                p.basenameWithoutExtension(item.imagePath);
                                downloadText("\$fileNameWithoutExtension.txt", item.text);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void downloadText(String fileName, String text) async {
    PythonService pService = PythonService();
    await pService.post(System.DOWNLOAD_TEXT, {
      "fileName": fileName,
      "text": text,
    }).then((rsp) async {
      debugPrint("Rsp DOWNLOAD_TEXT: \${rsp.toString()}");
      Map<String, dynamic> responseJSON = json.decode(json.encode(rsp));
      if (responseJSON['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Text Downloaded in Downloads section")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Unable to download text, check backend")),
        );
      }
    });
  }
}
