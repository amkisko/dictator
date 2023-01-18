/*
chatgpt

generate flutter widget that uses flutter_tts for reading text from large text area
by parts, text splitted by dot, exclamation and question marks and length not longer than 50 characters,
user can click Start to start reading, user can click Next to start reading next sentence,
user can click Previous in order to go to previous sentence and also can press Pause to pause reading,
current sentence should be visible to the user in separate text node, add language selector for tts,
add voice selector from available system voices, show amount of loops and overall progress,
add speed, pitch and voice controllers,
add main, Scaffold and AppBar so that it can be run as Flutter app

update previous example to have sentences, voice and currentSentence initialised
and progress and loop counts shown, move languages for selection under variable
*/

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSWidget extends StatefulWidget {
  const TTSWidget({super.key});

  @override
  _TTSWidgetState createState() => _TTSWidgetState();
}

class _TTSWidgetState extends State<TTSWidget> {
  final FlutterTts _flutterTts = FlutterTts();
  List<String> _sentences = [];
  int _currentIndex = 0;
  String _currentSentence = "";
  String _language = 'en-US';
  List<String> _languages = [];
  String _voice = "Siiri";
  double _progress = 0.0;
  double _loopCount = 0.0;
  double _speed = 1.0;
  double _pitch = 1.0;
  List<String> _voices = [];
  double _characterLimit = 50;
  bool _playing = false;
  int _positionStart = 0;
  int _positionEnd = 0;
  String _positionWord = "";
  String _text = "";

  @override
  void initState() {
    super.initState();
    print("INIT STATE");
    _flutterTts.getVoices.then((voices) {
      if (voices != null) {
        print(voices);
        setState(() {
          _languages = (voices as List)
              .map((v) => v["locale"].toString())
              .toSet()
              .toList();
          _language = _languages[0];
          _flutterTts.setLanguage(_language);
          _voices = voices
              .where((v) => v["locale"] == _language)
              .map((v) => v["name"].toString())
              .toSet()
              .toList();
          _voice = _voices[0];
          _flutterTts.setVoice({"name": _voice, "locale": _language});
        });
      }
    });
    _flutterTts.setPitch(_pitch);
    _flutterTts.setSpeechRate(_speed);
    _flutterTts.setStartHandler(() {
      setState(() {
        _playing = true;
      });
    });
    _flutterTts.setPauseHandler(() {
      setState(() {
        _playing = false;
      });
    });
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _playing = false;
      });
    });
    _flutterTts.setContinueHandler(() {
      setState(() {
        _playing = true;
      });
    });
    _flutterTts.setProgressHandler((text, start, end, word) {
      setState(() {
        _positionStart = start;
        _positionEnd = end;
        _positionWord = word;
        _playing = true;
      });
    });
  }

  void _splitSentences(String text) {
    if (text.isNotEmpty) {
      _sentences =
          RegExp(r".{0," + _characterLimit.toInt().toString() + r"}(?=[\s.!?])")
              .allMatches(text)
              .map((v) => v[0]!)
              .toList();
      _currentSentence = _sentences[_currentIndex];
    }
  }

  void _startReading() {
    _flutterTts.speak(_currentSentence);
  }

  void _nextSentence() {
    if (_currentIndex < _sentences.length - 1) {
      setState(() {
        _currentIndex++;
        _currentSentence = _sentences[_currentIndex];
        _flutterTts.speak(_currentSentence);
      });
    }
  }

  void _previousSentence() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentSentence = _sentences[_currentIndex];
        _flutterTts.speak(_currentSentence);
      });
    }
  }

  void _pauseReading() {
    _flutterTts.stop();
  }

  void _changeLanguage(String language) {
    setState(() {
      _language = language;
      _flutterTts.setLanguage(_language);
      _flutterTts.getVoices.then((voices) {
        if (voices != null) {
          setState(() {
            _voices = (voices as List)
                .where((v) => v["locale"] == _language)
                .map((v) => v["name"].toString())
                .toSet()
                .toList();
            _voice = _voices[0];
            _flutterTts.setVoice({"name": _voice, "locale": _language});
          });
        }
      });
    });
  }

  void _changeVoice(String voice) {
    setState(() {
      _voice = voice;
      _flutterTts.setVoice({"name": _voice, "locale": _language});
    });
  }

  void _changeSpeed(double speed) {
    setState(() {
      _speed = speed;
      _flutterTts.setSpeechRate(_speed);
    });
  }

  void _changePitch(double pitch) {
    setState(() {
      _pitch = pitch;
      _flutterTts.setPitch(_pitch);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictator'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                maxLines: null,
                decoration:
                    const InputDecoration(hintText: 'Enter text to read'),
                onChanged: (text) {
                  _text = text;
                  _splitSentences(text);
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(_currentSentence),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                DropdownButton(
                  value: _language,
                  items: _buildLanguageMenuItems(),
                  onChanged: (value) {
                    _changeLanguage(value!);
                  },
                ),
                DropdownButton(
                  value: _voice,
                  items: _buildVoiceMenuItems(),
                  onChanged: (value) {
                    _changeVoice(value as String);
                  },
                ),
                SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                        disabledThumbColor:
                            Theme.of(context).colorScheme.secondary,
                        disabledActiveTrackColor:
                            Theme.of(context).colorScheme.secondary),
                    child: Slider(
                      value: _speed,
                      min: 0.3,
                      max: 2.0,
                      label: _speed.toString(),
                      onChanged: (value) {
                        _changeSpeed(value);
                      },
                    )),
                Slider(
                  value: _pitch,
                  min: 0.5,
                  max: 2.0,
                  label: _pitch.toString(),
                  onChanged: (value) {
                    _changePitch(value);
                  },
                ),
                Slider(
                  value: _characterLimit,
                  min: 30,
                  max: 130,
                  divisions: 10,
                  label: _characterLimit.toString(),
                  onChanged: (value) {
                    setState(() {
                      _characterLimit = value;
                      _splitSentences(_text);
                    });
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('Progress: $_progress'),
                Text('Loops: $_loopCount'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: _startReading,
                  child: const Text('Start'),
                ),
                ElevatedButton(
                  onPressed: _pauseReading,
                  child: const Text('Pause'),
                ),
                ElevatedButton(
                  onPressed: _previousSentence,
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: _nextSentence,
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildVoiceMenuItems() {
    return _voices.map((voice) {
      return DropdownMenuItem(
        value: voice,
        child: Text(voice),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _buildLanguageMenuItems() {
    return _languages.map((lang) {
      return DropdownMenuItem(
        value: lang,
        child: Text(lang),
      );
    }).toList();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TTSWidget(),
    );
  }
}

void main() {
  runApp(const MyApp());
}
