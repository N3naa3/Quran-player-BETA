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
      // THE WELCOMING PARCHMENT THEME
      theme: ThemeData(
        brightness: Brightness.light, 
        scaffoldBackgroundColor: const Color(0xFF2A2522), // Deep warm dark beige
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF8C6A4F), // Warm bronze
          surface: Color(0xFFEAE0D5), // Soft parchment beige
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
  String _filePath = "";

  // 100% Verified Surah Al-Fatiha Text
  final String _quranText = "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ\nٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَـٰلَمِينَ\nٱلرَّحْمَـٰنِ ٱلرَّحِيمِ\nمَـٰلِكِ يَوْمِ ٱلدِّينِ\nإِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ\nٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ\nصِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ";

  // FIX: Properly play local audio files from device storage
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        final name = result.files.single.name;
        
        await _audioPlayer.stop();
        await _audioPlayer.play(DeviceFileSource(path));
        
        setState(() {
          _fileName = name;
          _filePath = path;
          _isPlaying = true;
        });
      }
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<void> _togglePlayPause() async {
    if (_filePath.isEmpty) return;
    
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      await _audioPlayer.resume();
      setState(() => _isPlaying = true);
    }
  }

  // BEAUTIFUL IN-APP AZKAR POP-UP
  void _showAzkarPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1512), // Dark background
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF8C6A4F), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wb_sunny, color: Color(0xFF8C6A4F), size: 50),
                const SizedBox(height: 16),
                const Text(
                  "Morning Azkar",
                  style: TextStyle(
                    color: Color(0xFFEAE0D5),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ",
                  style: TextStyle(
                    color: Color(0xFFEAE0D5),
                    fontSize: 22,
                    height: 1.8,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8C6A4F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "آمين",
                    style: TextStyle(color: Color(0xFF1A1512), fontSize: 18, fontWeight: FontWeight.bold),
                  ),
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
        title: const Text("Quran Player", style: TextStyle(color: Color(0xFFEAE0D5), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2A2522),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Quran Text Display (Parchment Style)
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAE0D5), 
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF8C6A4F), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _quranText,
                      style: const TextStyle(color: Color(0xFF1A1512), fontSize: 26, height: 2.0, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Audio Player Controls
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE0D5), 
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF8C6A4F), width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      _fileName,
                      style: const TextStyle(color: Color(0xFF1A1512), fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            size: 50,
                            color: const Color(0xFF8C6A4F),
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.folder_open, size: 20),
                          label: const Text("Select Audio"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A2522), 
                            foregroundColor: const Color(0xFFEAE0D5),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAzkarPopup,
        backgroundColor: const Color(0xFF2A2522),
        icon: const Icon(Icons.notifications_active, color: Color(0xFFEAE0D5)),
        label: const Text("Test Azkar", style: TextStyle(color: Color(0xFFEAE0D5))),
      ),
    );
  }
}
