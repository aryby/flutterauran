import 'package:flutter/material.dart';
import 'package:quran_ui/config/colors_constant.dart';
import 'package:quran_ui/config/database_helper.dart';
import 'package:quran_ui/pages/surah.pages.dart';

class SearchePage extends StatefulWidget {
  final String txt_rechercher;
  final bool isAdvanced;
  const SearchePage(
      {super.key, required this.txt_rechercher, required this.isAdvanced});

  @override
  State<SearchePage> createState() => _SearchePageState();
}

class _SearchePageState extends State<SearchePage> {
  List<Map<String, dynamic>> results = [];
  Map<int, String> surahNames = {};
  Map<int, String> surahPlaces = {};
  Map<int, int> versesCounts = {};
  bool isLoading = true;
  bool isEmpty = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
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
                    String surahName = surahNames[surahNumber] ?? 'لا يوجد';
                    String surahPlace = surahPlaces[surahNumber] ?? 'لا يوجد';
                    int versesCount = versesCounts[surahNumber] ?? 0;

                    return ListTile(
                      title: Text(
                        results[index]['text_ar'].toString(),
                        textDirection: TextDirection.rtl,
                      ), // Display the Arabic text
                      subtitle: Text(
                        " سورة  : $surahName ($surahPlace) - الاية : ${results[index]['number'].toString()}",
                        textDirection: TextDirection.rtl,
                      ), // Display the Surah name
                      onTap: () {
                        showSurah(
                          surahNumber,
                          surahName,
                          surahPlace,
                          versesCount,
                        );
                      },
                    );
                  },
                ),
    );
  }

  void showSurah(nbr, surName, place, versesCount) async {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SurahPage(
          surahNumber: nbr,
          surahName: surName,
          place: place,
          versesCount: versesCount,
        ),
      ),
    );
  }

  Future<void> _fetchData() async {
    try {
      // Fetch search results
      List<Map<String, dynamic>> searchResults =
          await DatabaseHelper.findByString(
              widget.txt_rechercher, widget.isAdvanced);

      // Fetch Surah names and store them in a map
      await _fetchSurahNames();

      setState(() {
        results = searchResults;
        isEmpty = results.isEmpty;
        isLoading = false;
      });
    } catch (error) {
      // Handle any errors here, for example, show an error message
      setState(() {
        isLoading = false;
        isEmpty = true;
      });
    }
  }

  Future<void> _fetchSurahNames() async {
    var db = await DatabaseHelper.database;
    List<Map<String, dynamic>> surahs = await db.query('surahs',
        columns: ['number', 'name_ar', 'verses_count', 'revelation_place_ar']);
    for (var surah in surahs) {
      surahNames[surah['number']] = surah['name_ar'];
      surahPlaces[surah['number']] = surah['revelation_place_ar'];
      versesCounts[surah['number']] = surah['verses_count'];
    }
  }
}
