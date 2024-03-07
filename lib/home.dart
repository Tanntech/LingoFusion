import 'dart:io';

//import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:lingofusion/const/const.dart';
import 'package:lingofusion/youtubeplayer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:translator/translator.dart';
import 'package:path/path.dart' as path;
import 'package:just_audio/just_audio.dart';

class TranscriptionScreen extends StatefulWidget {
  @override
  _TranscriptionScreenState createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  TextEditingController _youtubeLinkController = TextEditingController();
  String _transcriptionResult = '';
  String textForTTS = '';
  String _selectedLanguage = 'Hindi';
  GoogleTranslator translator = GoogleTranslator();
  final FlutterTts flutterTts = FlutterTts();
  FlutterSound flutterSound = FlutterSound();

  final AudioPlayer audioPlayer = AudioPlayer();

  void transcribeVideo() async {
    final String youtubeLink = _youtubeLinkController.text;
    List<String> parts = youtubeLink.split('=');

    final response = await http.post(
      Uri.parse('$host/transcribe'),
      body: {'youtubeLink': parts[1]},
    );

    if (response.statusCode == 200) {
      setState(() {
        _transcriptionResult = response.body;
      });
    } else {
      // Handle error
      print('Error: ${response.statusCode}');
    }
  }

  void translateText(String targetLanguage) {
    if (_transcriptionResult.isNotEmpty) {
      translator
          .translate(_transcriptionResult, to: targetLanguage)
          .then((output) {
        setState(() {
          _transcriptionResult = output.toString();
        });
      });
    }
  }

  speak(String text) async {
    await flutterTts.setLanguage("hi");
    await flutterTts.speak(text);
    await flutterTts.setPitch(1.0);
  }

  // Future<void> generateAndSaveSpeech(String text, String fileName) async {
  //   final appDocumentDirectory = await getApplicationDocumentsDirectory();
  //   final voiceDirectory = Directory('${appDocumentDirectory.path}/voice');

  //   if (!await voiceDirectory.exists()) {
  //     await voiceDirectory.create(recursive: true);
  //   }

  //   final filePath = '${voiceDirectory.path}/$fileName.mp3';

  //   await flutterTts.setLanguage("hi");
  //   await flutterTts.setSpeechRate(1.0);
  //   await flutterTts.setVolume(1.0);

  //   final result = await flutterTts.synthesizeToFile(text, filePath);

  //   if (result == 1) {
  //     print("Speech saved to: $filePath");
  //     await audioPlayer.setFilePath(filePath);
  //     await audioPlayer.play();
  //   } else {
  //     print("Error while generating speech.");
  //   }
  // }

  // Future<List<File>> getMP3Files() async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final voiceDirectory = Directory('${directory.path}/voice');
  //   List<FileSystemEntity> files = voiceDirectory.listSync();

  //   List<File> mp3Files = [];
  //   for (var file in files) {
  //     if (file is File && file.path.endsWith('.mp3')) {
  //       mp3Files.add(file);
  //     }
  //   }

  //   return mp3Files;
  // }

  // String speech() {
  //   final lines = _transcriptionResult.split('\n');
  //   final textForTTS = StringBuffer();
  //   bool skipHeader = true;

  //   for (final line in lines) {
  //     if (skipHeader) {
  //       if (line.trim().isEmpty) {
  //         skipHeader = false;
  //       }
  //       continue;
  //     }
  //     if (line.contains('-->')) {
  //       continue;
  //     }
  //     if (line.trim().isNotEmpty) {
  //       textForTTS.write('$line ');
  //     }
  //   }

  //   return textForTTS.toString().trim();
  // }

  String speech() {
    if (_transcriptionResult.isNotEmpty) {
      String transcription = _transcriptionResult;
      List<String> lines = transcription.split('\n');
      List<String> textLines = lines
          .where((line) => !line.contains(
              RegExp(r'^\d{2}:\d{2}:\d{2}\.\d+ --> \d{2}:\d{2}:\d{2}\.\d+$')))
          .where((line) => line.isNotEmpty) // Remove empty lines
          .toList();
      textForTTS = textLines.join(' ');
    }
    return textForTTS;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'DubIndiVoice',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black87,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: _youtubeLinkController,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black87, width: 1.5),
                        borderRadius: BorderRadius.circular(12)),
                    focusedBorder: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: Colors.black87, width: 1.5),
                    ),
                    labelText: 'Enter YouTube Link'),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton.icon(
                      //Handle button press event
                      onPressed: () => transcribeVideo(),
                      //Contents of the button
                      style: ElevatedButton.styleFrom(
                        //Change font size
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.black87,
                        textStyle: const TextStyle(
                          fontSize: 12,
                        ),
                        //Set the padding on all sides to 30px
                        padding: const EdgeInsets.all(12.0),
                      ),
                      icon: const Icon(
                        Icons.send_rounded,
                        size: 20,
                      ), //Button icon
                      label: const Text(
                        "Transcribe",
                        style: TextStyle(fontSize: 20),
                      )),
                  SizedBox(
                    width: 50,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black54, width: 2.5)),
                    padding: EdgeInsets.only(right: 20, left: 20),
                    child: DropdownButton<String>(
                        underline: Container(),
                        value: _selectedLanguage,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedLanguage = newValue!;
                          });
                          if (newValue == 'Hindi') {
                            translateText('hi');
                          }
                          if (newValue == 'Marathi') {
                            translateText('mr');
                          }
                          if (newValue == 'Gujarati') {
                            translateText('gu');
                          }
                          if (newValue == 'Telugu') {
                            translateText('te');
                          }
                          if (newValue == 'Bengali') {
                            translateText('bn');
                          }
                        },
                        items: <String>[
                          'Hindi',
                          'Marathi',
                          'Gujarati',
                          'Telugu',
                          'Bengali'
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        icon: Icon(Icons.arrow_drop_down)),
                  ),
                ],
              ),
              SizedBox(height: 20),
              InkWell(
                // onTap: () async {
                //   generateAndSaveSpeech(_transcriptionResult, "test");
                //   List<File> mp3Files = await getMP3Files();
                //   print(mp3Files);
                // },
                child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.black54, width: 2.5)),
                    padding:
                        EdgeInsets.only(right: 20, left: 20, top: 5, bottom: 5),
                    child: Text(
                      "Generate",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )),
              ),
              SizedBox(height: 20),
              Text(
                'Transcription Result:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                child: Card(
                  margin: EdgeInsets.all(2),
                  color: Colors.white,
                  shadowColor: Colors.black,
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _transcriptionResult,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                  onPressed: () {
                    speak(_transcriptionResult);
                  },
                  child: Text("Play")),
              if (_transcriptionResult.isNotEmpty)
                YouTubeVideoPlayer("TzPS6ELoZ1I")
            ],
          ),
        ),
      ),
      drawer: SafeArea(
          child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1485290334039-a3c69043e517?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwxfDB8MXxyYW5kb218MHx8fHx8fHx8MTYyOTU3NDE0MQ&ixlib=rb-1.2.1&q=80&utm_campaign=api-credit&utm_medium=referral&utm_source=unsplash_source&w=300'),
              ),
              accountEmail: Text('jane.doe@example.com'),
              accountName: Text(
                'Uesrname',
                style: TextStyle(fontSize: 24.0),
              ),
              decoration: BoxDecoration(
                color: Colors.black87,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text(
                'Home',
                style: TextStyle(fontSize: 20.0),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(
                'Profile',
                style: TextStyle(fontSize: 20.0),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text(
                'Saved Items',
                style: TextStyle(fontSize: 20.0),
              ),
              onTap: () {},
            ),
            const Divider(
              height: 10,
              thickness: 1,
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text(
                'Settings',
                style: TextStyle(fontSize: 20.0),
              ),
              onTap: () {},
            ),
          ],
        ),
      )),
    );
  }
}
