import 'package:flutter/material.dart';
import 'package:quran_ui/config/colors_constant.dart';
import 'package:quran_ui/config/database_helper.dart';

class AdvancedSearchePage extends StatefulWidget {
  final String txt_rechercher;
  const AdvancedSearchePage({super.key, required this.txt_rechercher});

  @override
  State<AdvancedSearchePage> createState() => _AdvancedSearchePageState();
}

class _AdvancedSearchePageState extends State<AdvancedSearchePage> {
  List<Map<String, dynamic>> results = [];
  Map<int, String> surahNames = {};
  bool isLoading = true;
  bool isEmpty = false;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Call the function to fetch data when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
              color: Colors.green,
            )) // Show loading indicator
          : isEmpty
              ? const Center(
                  child:
                      Text("لا يوجد")) // Show "Not Found" message if no results
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    int surahNumber = results[index]['surah_number'];
                    String surahName =
                        surahNames[surahNumber] ?? 'Unknown Surah';
                    return ListTile(
                      title: Text(
                        results[index]['text_ar'].toString(),
                        textDirection: TextDirection.rtl,
                      ), // Display the Arabic text
                      subtitle: Text(
                        " سورة  : $surahName ",
                        textDirection: TextDirection.rtl,
                      ), // Display the Surah name
                    );
                  },
                ),
    );
  }

  Future<void> _fetchData() async {
    // Fetch search results
    List<Map<String, dynamic>> searchResults =
        await DatabaseHelper.findByString(widget.txt_rechercher, true);

    // Fetch Surah names and store them in a map
    await _fetchSurahNames();
    setState(() {
      results = searchResults;
      isEmpty = results.isEmpty;
      isLoading = false;
    });
    setState(() {
      results = searchResults;
    });
  }

  Future<void> _fetchSurahNames() async {
    var db = await DatabaseHelper.database;
    List<Map<String, dynamic>> surahs =
        await db.query('surahs', columns: ['number', 'name_ar']);
    for (var surah in surahs) {
      surahNames[surah['number']] = surah['name_ar'];
    }
  }
}
