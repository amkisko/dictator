import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TextReaderWidget extends StatefulWidget {
  const TextReaderWidget({super.key});

  @override
  TextReaderWidgetState createState() => TextReaderWidgetState();
}

class TextReaderWidgetState extends State<TextReaderWidget> {
  FlutterTts tts = FlutterTts();
  String text = '';
  List<String> sentences = [];
  int currentSentenceIndex = 0;
  List<String> languageCodes = ["en", "ru", "fi"];
  String selectedLanguage = "en";

  // Function to speak the sentence
  void _speakSentence(int sentenceIndex) {
    setState(() {
      currentSentenceIndex = sentenceIndex;
      tts.stop();
      tts.setLanguage(selectedLanguage);
      tts.speak(sentences[currentSentenceIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Text Reader"),
        ),
        body: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  text = value;
                  sentences = text.split('. ');
                });
              },
            ),
            Text(sentences.isEmpty ? "-" : sentences[currentSentenceIndex]),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: const Text('Previous'),
                  onPressed: () {
                    if (currentSentenceIndex > 0) {
                      _speakSentence(currentSentenceIndex - 1);
                    }
                  },
                ),
                ElevatedButton(
                  child: const Text('Pause'),
                  onPressed: () {
                    tts.stop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Next'),
                  onPressed: () {
                    if (currentSentenceIndex < sentences.length - 1) {
                      _speakSentence(currentSentenceIndex + 1);
                    } else {
                      _speakSentence(0);
                    }
                  },
                ),
              ],
            ),
            DropdownButton<String>(
              value: selectedLanguage,
              items: languageCodes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  if (newValue != null) {
                    selectedLanguage = newValue;
                  }
                });
              },
            ),
          ],
        ));
  }
}
