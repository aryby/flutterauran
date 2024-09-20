import 'package:flutter/material.dart';
import 'package:quran_ui/config/colors_constant.dart';
import 'package:quran_ui/config/database_helper.dart';
import 'package:quran_ui/pages/my_navigation_drawer.dart';
import 'package:quran_ui/pages/surah.pages.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final surah_name_controller = TextEditingController();
  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _filteredData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    surah_name_controller.addListener(
        _onSearchChanged); // Add listener for changes in the input field
  }

  Future<void> _loadData() async {
    List<Map<String, dynamic>> result =
        await DatabaseHelper.queryAllRows('surahs');
    setState(() {
      _data = result;
      _filteredData = result; // Initially show all data
    });
  }

  void _onSearchChanged() {
    searchSurahByName(surah_name_controller.text);
  }

  void searchSurahByName(String surahName) {
    List<Map<String, dynamic>> tempData = [];
    if (surahName.isNotEmpty) {
      tempData = _data
          .where((surah) => surah['name_ar']
              .toString()
              .contains(surahName)) // Filter data by Arabic name
          .toList();
    } else {
      tempData = _data; // If search is empty, show all data
    }
    setState(() {
      _filteredData = tempData; // Update the filtered list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: TextFormField(
            textDirection: TextDirection.rtl,
            controller: surah_name_controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: " بحـــث : اسم السورة",
              hintTextDirection: TextDirection.rtl,
              suffixIcon: IconButton(
                onPressed: () {
                  searchSurahByName(surah_name_controller.text);
                },
                icon: Icon(
                  Icons.search,
                  color: Colors.green.shade900,
                ),
              ),
            ),
          ),
        ),
        backgroundColor: primaryColor,
      ),
      drawer: const MyNavigationDrawer(),
      body: ListView.builder(
        itemCount: _filteredData.length, // Use filtered data for display
        itemBuilder: (context, index) {
          return ListTile(
            title: Text("${_filteredData[index]['name_ar']}"),
            subtitle:
                Text("عدد الايات -  ${_filteredData[index]['verses_count']}"),
            trailing: Icon(
              Icons.book,
              color: Colors.green.shade500,
            ),
            onTap: () {
              setState(() {
                showSurah(
                    _filteredData[index]['number'],
                    _filteredData[index]['name_ar'],
                    _filteredData[index]
                        ['revelation_place_ar'], // makiya ou madaniya
                    _filteredData[index]['verses_count'] // 3adad l ayat
                    );
              });
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
}
