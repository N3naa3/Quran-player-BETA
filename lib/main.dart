import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const QuranPlayerApp());
}

class QuranPlayerApp extends StatelessWidget {
  const QuranPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quran Player',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121415),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37), // Matte Gold
          surface: Color(0xFF1E2022),
        ),
      ),
      home: const PlayerScreen(),
    );
  }
}

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String _fileName = "No recitation selected";

  // 100% Verified Surah Al-Fatiha Text (Uthmani Script)
  final String _quranText = "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ\nٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ\nٱلرَّحْمَـٰنِ ٱلرَّحِيمِ\nمَـٰلِكِ يَوْمِ ٱلدِّينِ\nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\nٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ\nصِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ";

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final name = result.files.single.name;
        
        await _audioPlayer.setSourceUrl(path);
        setState(() {
          _fileName = name;
          _isPlaying = true;
        });
        await _audioPlayer.resume();
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.resume();
      setState(() => _isPlaying = true);
    }
  }

  // The Azkar Pop-up Logic
  void _showAzkarPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent, // We use the container for the black bg
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Placeholder Image/Icon (Sun for morning, Moon for night)
                const Icon(Icons.wb_sunny, color: Color(0xFFD4AF37), size: 60),
                const SizedBox(height: 20),
                const Text(
                  "Morning Azkar",
                  style: TextStyle(color: Color(0xFFD4AF37), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Verified Morning Zikr Snippet
                const Text(
                  "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ",
                  style: TextStyle(color: Colors.white, fontSize: 22, height: 1.8),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Dismiss", style: TextStyle(color: Colors.white70, fontSize: 16)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quran Player", style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // 1. Quran Text Display
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E2022),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _quranText,
                      style: const TextStyle(color: Colors.white, fontSize: 26, height: 2.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. Audio Player Controls
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2022),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(_fileName, style: const TextStyle(color: Colors.white70, fontSize: 16), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, size: 50, color: const Color(0xFFD4AF37)),
                          onPressed: _togglePlayPause,
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.folder_open, size: 20),
                          label: const Text("Select Audio"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      // 3. Floating Action Button to Test Azkar Pop-up
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAzkarPopup,
        backgroundColor: const Color(0xFF1E2022),
        icon: const Icon(Icons.notifications_active, color: Color(0xFFD4AF37)),
        label: const Text("Test Azkar", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
