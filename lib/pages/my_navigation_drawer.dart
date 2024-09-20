import 'package:flutter/material.dart';
import 'package:quran_ui/config/colors_constant.dart';
import 'package:quran_ui/pages/searche.pages.dart';

class MyNavigationDrawer extends StatefulWidget {
  const MyNavigationDrawer({super.key});

  @override
  State<MyNavigationDrawer> createState() => _MyNavigationDrawerState();
}

class _MyNavigationDrawerState extends State<MyNavigationDrawer> {
  final txt_advanced_searche = TextEditingController();
  final txt_serche_controller = TextEditingController();
  bool is_txt_seache = false;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: primaryColor,
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: FittedBox(
              fit: BoxFit.contain,
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/logo.png'),
                radius: 200,
                backgroundColor: Colors.greenAccent,
              ),
            ),
          ),
          ListTile(
            trailing: const Icon(
              Icons.home,
            ),
            title: const Text(
              "الفهرس",
              textDirection: TextDirection.rtl,
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, "/");
            },
          ),
          ListTile(
            title: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              width: MediaQuery.of(context).size.width * .4,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.green.withOpacity(0.5),
              ),
              child: TextFormField(
                textDirection: TextDirection.rtl,
                controller: txt_serche_controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "بحـــث",
                  hintTextDirection: TextDirection.rtl,
                  suffixIcon: IconButton(
                    onPressed: () {
                      showSurah(txt_serche_controller.text, false);
                      txt_serche_controller.text = "";
                    },
                    icon: Icon(
                      Icons.search,
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            title: Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              width: MediaQuery.of(context).size.width * .4,
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.green.withOpacity(0.5),
              ),
              child: TextFormField(
                textDirection: TextDirection.rtl,
                controller: txt_advanced_searche,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: " بحـــث متقدم ",
                  hintTextDirection: TextDirection.rtl,
                  suffixIcon: IconButton(
                    onPressed: () {
                      showSurah(txt_advanced_searche.text, true);
                      txt_advanced_searche.text = "";
                    },
                    icon: Icon(
                      Icons.search,
                      color: Colors.green.shade900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showSurah(surName, isAdvncd) async {
    Navigator.pop(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SearchePage(txt_rechercher: surName, isAdvanced: isAdvncd),
      ), // Pass the id here
    );
  }
}
