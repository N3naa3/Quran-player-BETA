import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        brightness: Brightness.light, 
        scaffoldBackgroundColor: const Color(0xFF2A2522),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF8C6A4F),
          surface: Color(0xFFEAE0D5),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// --- HOME SCREEN ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String _fileName = "No recitation selected";
  String _filePath = "";

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio, allowMultiple: false);
      if (result != null && result.files.single.path != null) {
        await _audioPlayer.stop();
        await _audioPlayer.play(DeviceFileSource(result.files.single.path!));
        setState(() {
          _fileName = result.files.single.name;
          _filePath = result.files.single.path!;
          _isPlaying = true;
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _showAzkarPopup() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1512),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF8C6A4F), width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wb_sunny, color: Color(0xFF8C6A4F), size: 50),
              const SizedBox(height: 16),
              const Text("Morning Azkar", style: TextStyle(color: Color(0xFFEAE0D5), fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text("أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ", 
                style: TextStyle(color: Color(0xFFEAE0D5), fontSize: 22, height: 1.8), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8C6A4F)),
                child: const Text("آمين", style: TextStyle(color: Color(0xFF1A1512), fontSize: 18, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
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
              // MUSHAF BUTTON
              ElevatedButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MushafScreen())),
                icon: const Icon(Icons.menu_book, size: 28),
                label: const Text("Open Mushaf", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEAE0D5),
                  foregroundColor: const Color(0xFF1A1512),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),
              // AUDIO PLAYER
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFEAE0D5), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF8C6A4F), width: 2)),
                child: Column(
                  children: [
                    Text(_fileName, style: const TextStyle(color: Color(0xFF1A1512), fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, size: 50, color: const Color(0xFF8C6A4F)), onPressed: () async {
                          if (_filePath.isEmpty) return;
                          if (_isPlaying) { await _audioPlayer.pause(); setState(() => _isPlaying = false); } 
                          else { await _audioPlayer.resume(); setState(() => _isPlaying = true); }
                        }),
                        const SizedBox(width: 20),
                        ElevatedButton.icon(onPressed: _pickFile, icon: const Icon(Icons.folder_open, size: 20), label: const Text("Select Audio"),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2A2522), foregroundColor: const Color(0xFFEAE0D5)),
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

// --- MUSHAF SCREEN ---
class MushafScreen extends StatelessWidget {
  const MushafScreen({super.key});

  // Compact list of all 114 Surahs
  final List<Map<String, String>> surahs = const [
    {"n": "1", "ar": "الفاتحة", "en": "Al-Fatiha"}, {"n": "2", "ar": "البقرة", "en": "Al-Baqarah"}, {"n": "3", "ar": "آل عمران", "en": "Aal-E-Imran"},
    {"n": "4", "ar": "النساء", "en": "An-Nisa"}, {"n": "5", "ar": "المائدة", "en": "Al-Ma'idah"}, {"n": "6", "ar": "الأنعام", "en": "Al-An'am"},
    {"n": "7", "ar": "الأعراف", "en": "Al-A'raf"}, {"n": "8", "ar": "الأنفال", "en": "Al-Anfal"}, {"n": "9", "ar": "التوبة", "en": "At-Tawbah"},
    {"n": "10", "ar": "يونس", "en": "Yunus"}, {"n": "11", "ar": "هود", "en": "Hud"}, {"n": "12", "ar": "يوسف", "en": "Yusuf"},
    {"n": "13", "ar": "الرعد", "en": "Ar-Ra'd"}, {"n": "14", "ar": "إبراهيم", "en": "Ibrahim"}, {"n": "15", "ar": "الحجر", "en": "Al-Hijr"},
    {"n": "16", "ar": "النحل", "en": "An-Nahl"}, {"n": "17", "ar": "الإسراء", "en": "Al-Isra"}, {"n": "18", "ar": "الكهف", "en": "Al-Kahf"},
    {"n": "19", "ar": "مريم", "en": "Maryam"}, {"n": "20", "ar": "طه", "en": "Ta-Ha"}, {"n": "21", "ar": "الأنبياء", "en": "Al-Anbiya"},
    {"n": "22", "ar": "الحج", "en": "Al-Hajj"}, {"n": "23", "ar": "المؤمنون", "en": "Al-Mu'minun"}, {"n": "24", "ar": "النور", "en": "An-Nur"},
    {"n": "25", "ar": "الفرقان", "en": "Al-Furqan"}, {"n": "26", "ar": "الشعراء", "en": "Ash-Shu'ara"}, {"n": "27", "ar": "النمل", "en": "An-Naml"},
    {"n": "28", "ar": "القصص", "en": "Al-Qasas"}, {"n": "29", "ar": "العنكبوت", "en": "Al-Ankabut"}, {"n": "30", "ar": "الروم", "en": "Ar-Rum"},
    {"n": "31", "ar": "لقمان", "en": "Luqman"}, {"n": "32", "ar": "السجدة", "en": "As-Sajda"}, {"n": "33", "ar": "الأحزاب", "en": "Al-Ahzab"},
    {"n": "34", "ar": "سبأ", "en": "Saba"}, {"n": "35", "ar": "فاطر", "en": "Fatir"}, {"n": "36", "ar": "يس", "en": "Ya-Sin"},
    {"n": "37", "ar": "الصافات", "en": "As-Saffat"}, {"n": "38", "ar": "ص", "en": "Sad"}, {"n": "39", "ar": "الزمر", "en": "Az-Zumar"},
    {"n": "40", "ar": "غافر", "en": "Ghafir"}, {"n": "41", "ar": "فصلت", "en": "Fussilat"}, {"n": "42", "ar": "الشورى", "en": "Ash-Shura"},
    {"n": "43", "ar": "الزخرف", "en": "Az-Zukhruf"}, {"n": "44", "ar": "الدخان", "en": "Ad-Dukhan"}, {"n": "45", "ar": "الجاثية", "en": "Al-Jathiya"},
    {"n": "46", "ar": "الأحقاف", "en": "Al-Ahqaf"}, {"n": "47", "ar": "محمد", "en": "Muhammad"}, {"n": "48", "ar": "الفتح", "en": "Al-Fath"},
    {"n": "49", "ar": "الحجرات", "en": "Al-Hujurat"}, {"n": "50", "ar": "ق", "en": "Qaf"}, {"n": "51", "ar": "الذاريات", "en": "Adh-Dhariyat"},
    {"n": "52", "ar": "الطور", "en": "At-Tur"}, {"n": "53", "ar": "النجم", "en": "An-Najm"}, {"n": "54", "ar": "القمر", "en": "Al-Qamar"},
    {"n": "55", "ar": "الرحمن", "en": "Ar-Rahman"}, {"n": "56", "ar": "الواقعة", "en": "Al-Waqi'a"}, {"n": "57", "ar": "الحديد", "en": "Al-Hadid"},
    {"n": "58", "ar": "المجادلة", "en": "Al-Mujadila"}, {"n": "59", "ar": "الحشر", "en": "Al-Hashr"}, {"n": "60", "ar": "الممتحنة", "en": "Al-Mumtahina"},
    {"n": "61", "ar": "الصف", "en": "As-Saff"}, {"n": "62", "ar": "الجمعة", "en": "Al-Jumu'a"}, {"n": "63", "ar": "المنافقون", "en": "Al-Munafiqun"},
    {"n": "64", "ar": "التغابن", "en": "At-Taghabun"}, {"n": "65", "ar": "الطلاق", "en": "At-Talaq"}, {"n": "66", "ar": "التحريم", "en": "At-Tahrim"},
    {"n": "67", "ar": "الملك", "en": "Al-Mulk"}, {"n": "68", "ar": "القلم", "en": "Al-Qalam"}, {"n": "69", "ar": "الحاقة", "en": "Al-Haqqah"},
    {"n": "70", "ar": "المعارج", "en": "Al-Ma'arij"}, {"n": "71", "ar": "نوح", "en": "Nuh"}, {"n": "72", "ar": "الجن", "en": "Al-Jinn"},
    {"n": "73", "ar": "المزمل", "en": "Al-Muzzammil"}, {"n": "74", "ar": "المدثر", "en": "Al-Muddaththir"}, {"n": "75", "ar": "القيامة", "en": "Al-Qiyamah"},
    {"n": "76", "ar": "الإنسان", "en": "Al-Insan"}, {"n": "77", "ar": "المرسلات", "en": "Al-Mursalat"}, {"n": "78", "ar": "النبأ", "en": "An-Naba"},
    {"n": "79", "ar": "النازعات", "en": "An-Nazi'at"}, {"n": "80", "ar": "عبس", "en": "Abasa"}, {"n": "81", "ar": "التكوير", "en": "At-Takwir"},
    {"n": "82", "ar": "الانفطار", "en": "Al-Infitar"}, {"n": "83", "ar": "المطففين", "en": "Al-Mutaffifin"}, {"n": "84", "ar": "الانشقاق", "en": "Al-Inshiqaq"},
    {"n": "85", "ar": "البروج", "en": "Al-Buruj"}, {"n": "86", "ar": "الطارق", "en": "At-Tariq"}, {"n": "87", "ar": "الأعلى", "en": "Al-A'la"},
    {"n": "88", "ar": "الغاشية", "en": "Al-Ghashiyah"}, {"n": "89", "ar": "الفجر", "en": "Al-Fajr"}, {"n": "90", "ar": "البلد", "en": "Al-Balad"},
    {"n": "91", "ar": "الشمس", "en": "Ash-Shams"}, {"n": "92", "ar": "الليل", "en": "Al-Lail"}, {"n": "93", "ar": "الضحى", "en": "Ad-Duha"},
    {"n": "94", "ar": "الشرح", "en": "Ash-Sharh"}, {"n": "95", "ar": "التين", "en": "At-Tin"}, {"n": "96", "ar": "العلق", "en": "Al-Alaq"},
    {"n": "97", "ar": "القدر", "en": "Al-Qadr"}, {"n": "98", "ar": "البينة", "en": "Al-Bayyinah"}, {"n": "99", "ar": "الزلزلة", "en": "Az-Zalzalah"},
    {"n": "100", "ar": "العاديات", "en": "Al-Adiyat"}, {"n": "101", "ar": "القارعة", "en": "Al-Qari'a"}, {"n": "102", "ar": "التكاثر", "en": "At-Takathur"},
    {"n": "103", "ar": "العصر", "en": "Al-Asr"}, {"n": "104", "ar": "الهمزة", "en": "Al-Humazah"}, {"n": "105", "ar": "الفيل", "en": "Al-Fil"},
    {"n": "106", "ar": "قريش", "en": "Quraish"}, {"n": "107", "ar": "الماعون", "en": "Al-Ma'un"}, {"n": "108", "ar": "الكوثر", "en": "Al-Kawthar"},
    {"n": "109", "ar": "الكافرون", "en": "Al-Kafirun"}, {"n": "110", "ar": "النصر", "en": "An-Nasr"}, {"n": "111", "ar": "المسد", "en": "Al-Masad"},
    {"n": "112", "ar": "الإخلاص", "en": "Al-Ikhlas"}, {"n": "113", "ar": "الفلق", "en": "Al-Falaq"}, {"n": "114", "ar": "الناس", "en": "An-Nas"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("The Mushaf", style: TextStyle(color: Color(0xFFEAE0D5), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2A2522),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFFEAE0D5)), onPressed: () => Navigator.pop(context)),
      ),
      body: Container(
        color: const Color(0xFF2A2522),
        child: ListView.builder(
          itemCount: surahs.length,
          itemBuilder: (context, index) {
            final surah = surahs[index];
            return Card(
              color: const Color(0xFFEAE0D5),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: const BoxDecoration(color: Color(0xFF8C6A4F), shape: BoxShape.circle),
                  child: Center(child: Text(surah["n"]!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ),
                title: Text(surah["ar"]!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1512))),
                subtitle: Text(surah["en"]!, style: const TextStyle(color: Color(0xFF8C6A4F))),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF8C6A4F)),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SurahDetailScreen(number: surah["n"]!, name: surah["ar"]!))),
              ),
            );
          },
        ),
      ),
    );
  }
}

// --- SURAH DETAIL SCREEN (Fetches 100% Verified Text) ---
class SurahDetailScreen extends StatefulWidget {
  final String number;
  final String name;
  const SurahDetailScreen({super.key, required this.number, required this.name});

  @override
  State<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends State<SurahDetailScreen> {
  String? _quranText;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSurah();
  }

  Future<void> _fetchSurah() async {
    try {
      // Fetching from the globally verified, open-source Quran API
      final response = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/${widget.number}/quran-uthmani'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ayahs = data['data']['ayahs'] as List;
        // Join ayahs with double newline for beautiful readability
        setState(() {
          _quranText = ayahs.map((ayah) => ayah['text']).join('\n\n');
          _isLoading = false;
        });
      } else {
        setState(() {
          _quranText = "فشل في تحميل السورة. تأكد من اتصالك بالإنترنت.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _quranText = "حدث خطأ في الاتصال.";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name, style: const TextStyle(color: Color(0xFFEAE0D5), fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2A2522),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFFEAE0D5)), onPressed: () => Navigator.pop(context)),
      ),
      body: Container(
        color: const Color(0xFF2A2522),
        padding: const EdgeInsets.all(16),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF8C6A4F)))
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE0D5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF8C6A4F), width: 2),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _quranText ?? "",
                    style: const TextStyle(color: Color(0xFF1A1512), fontSize: 26, height: 2.2, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
      ),
    );
  }
}
