import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ConvertAudioScreen extends StatefulWidget {
  final String text;
  final String title;

  const ConvertAudioScreen({Key? key, required this.text, required this.title})
    : super(key: key);

  @override
  State<ConvertAudioScreen> createState() => _ConvertAudioScreenState();
}

class _ConvertAudioScreenState extends State<ConvertAudioScreen> {
  late FlutterTts flutterTts;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    initTTS();
  }

  Future<void> initTTS() async {
    flutterTts = FlutterTts();

    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    await flutterTts.setEngine("com.google.android.tts");

    flutterTts.setCompletionHandler(() {
      setState(() => isPlaying = false);
    });

    flutterTts.setCancelHandler(() {
      setState(() => isPlaying = false);
    });
  }

  Future<void> playText() async {
    if (!isPlaying) {
      setState(() => isPlaying = true);
      await flutterTts.speak(widget.text);
    }
  }

  Future<void> pauseText() async {
    await flutterTts.pause(); // NOTE: Pause is only supported on Android
    setState(() => isPlaying = false);
  }

  Future<void> stopText() async {
    await flutterTts.stop();
    setState(() => isPlaying = false);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "AudioBook: ${widget.title}",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Text(widget.text, style: TextStyle(fontSize: 16)),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  iconSize: 40,
                  color: Colors.blue,
                  onPressed: isPlaying ? pauseText : playText,
                ),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.stop),
                  iconSize: 40,
                  color: Colors.red,
                  onPressed: stopText,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isPlaying ? "Reading..." : "Paused / Stopped",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
