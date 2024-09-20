import 'package:flutter/material.dart';
import 'package:quran_ui/config/colors_constant.dart';
import 'package:quran_ui/config/database_helper.dart';
import 'package:quran_ui/pages/my_navigation_drawer.dart';

class SurahPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final String place;
  final int versesCount;
  const SurahPage(
      {super.key,
      required this.surahNumber,
      required this.surahName,
      required this.place,
      required this.versesCount});

  @override
  State<SurahPage> createState() => _SurahPageState();
}

class _SurahPageState extends State<SurahPage> {
  List<Map<String, dynamic>> _data = [];
  String idsString = "";
  Future<void> _loadData(surahNumber) async {
    List<Map<String, dynamic>> result =
        await DatabaseHelper.getSurahByNumber(surahNumber);

    setState(() {
      _data = result;
      idsString = _data.map((id) {
        return "${id['text_ar']} ﴿${id['number']}";
      }).join('﴾ ');
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _loadData(widget.surahNumber);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Container(
          child: TextFormField(
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
                  " ${widget.surahName} - ${widget.place} - ${widget.versesCount} ",
              hintTextDirection: TextDirection.rtl,
              suffixIcon: IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.search,
                  color: Colors.green.shade900,
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: const MyNavigationDrawer(),
      body: Container(
        color: Colors.green.withOpacity(.3),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 40, right: 20, left: 20),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.justify,
              idsString,
              style: const TextStyle(
                fontSize: 20,
                height: 2.0,
              ),
            ),
          ),
        ),
      ),
      /* floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.transparent,
        child: Icon(
          Icons.settings,
          color: Colors.green,
        ),
      ), */
    );
  }
}
