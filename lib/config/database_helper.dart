import 'dart:io';
import 'package:flutter/services.dart';
// Standard sqflite for mobile
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import sqflite_common_ffi for desktop
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:diacritic/diacritic.dart';

class DatabaseHelper {
  static Database? _database;

  // Initialize the database
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Copy the database from assets and open it
  static Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'quran.sqlite');

    // Check if the database already exists
    if (!await File(path).exists()) {
      // Copy from assets
      ByteData data = await rootBundle.load('assets/quran.sqlite');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write the bytes to a new file
      await File(path).writeAsBytes(bytes);
    }

    // Use the appropriate database factory depending on platform
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      return await databaseFactoryFfi.openDatabase(path); // Desktop with FFI
    } else {
      return await openDatabase(path); // Mobile without FFI
    }
  }

  static Future<String> getSurahNameFromId(int id) async {
    Database db = await database;

    // Query the surahs table for the name_ar where number matches the id
    List<Map<String, dynamic>> results = await db.query(
      'surahs',
      columns: ['name_ar'],
      where: 'number = ?',
      whereArgs: [id],
    );

    // Check if we have results
    if (results.isNotEmpty) {
      // Return the name_ar from the first result
      return results.first['name_ar'] as String;
    } else {
      // Handle the case where no result is found
      return 'Surah not found';
    }
  }

  // Example: Fetch all rows from a table
  static Future<List<Map<String, dynamic>>> queryAllRows(
      String tableName) async {
    Database db = await database;
    return await db.query(tableName);
  }

  static Future<List<Map<String, dynamic>>> getSurahByNumber(
      int surahNumber) async {
    Database db = await database;
    return await db.query("verses", where: "surah_number = $surahNumber");
  }

  static Future<List<Map<String, dynamic>>> searchSurahByName(
      String surahName) async {
    Database db = await database;
    return await db.query("surahs", where: "name_ar = $surahName");
  }

  static Future<List<Map<String, dynamic>>> findByString(
      String txtSearch, bool isAdvanced) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query("verses");
    String normalizedSearchText;

    if (isAdvanced) {
      String searchText = removeArabicDiacriticsAdvanced(txtSearch);
      normalizedSearchText = removeDiacritics(searchText);
    } else {
      normalizedSearchText = removeDiacritics(txtSearch);
    }

    return results.where((row) {
      String normalizedText = removeArabicDiacritics(row['text_ar']);
      return normalizedText.contains(normalizedSearchText);
    }).toList();
  }

  static String removeArabicDiacritics(String text) {
    // Arabic diacritics and marks
    final diacritics = [
      'َ', // Fatha
      'ً', // Fathatan
      'ُ', // Damma
      'ٌ', // Dammatan
      'ِ', // Kasra
      'ٍ', // Kasratan
      'ْ', // Sukun
      'ّ', // Shadda
      'ٓ', // Superscript Alef
      'ٰ', // Arabic Letter Superscript Alef
      'ۡ', // Arabic Letter Small Yeh
      'ۢ', // Arabic Letter Small Ta
      'ۣ', // Arabic Letter Small Seen
      'ۥ', // Arabic Letter Small Yeh
      'ۧ', // Arabic Letter Small Fatha
      'ۨ', // Arabic Letter Small Damma
      '۩', // Arabic Letter Small Kasra
      '۪', // Arabic Letter Small Shadda
      '۫', // Arabic Letter Small Sukun
      '۬', // Arabic Letter Small Waw
      'ۭ', // Arabic Letter Small Yeh
      'ۮ', // Arabic Letter Small Sukun
      'ۯ', // Arabic Letter Small Fatha
      'ۿ', // Arabic Letter Small Shadda
      'ٗ', // Arabic Letter Small Yeh
      'ٖ', // Arabic Fatha With Qaf
      'ٚ', // Arabic Letter Fatha
      'ٛ', // Arabic Letter Damma
      'ٜ', // Arabic Letter Kasra
      'ٝ', // Arabic Letter Sukun
      'ٟ', // Arabic Letter Shadda
      '٠', // Arabic Letter Superscript Waw
      '١', // Arabic Letter Superscript Ya
      '٢', // Arabic Letter Superscript Alef
      '٣', // Arabic Letter Superscript Alef
      '٤', // Arabic Letter Superscript Alef
      '٥', // Arabic Letter Superscript Alef
      '٦', // Arabic Letter Superscript Alef
      '٧', // Arabic Letter Superscript Alef
      '٨', // Arabic Letter Superscript Alef
      '٩', // Arabic Letter Superscript Alef
      '٪', // Arabic Percent Sign
      '٫', // Arabic Decimal Separator
      '٬', // Arabic Comma
      '٭', // Arabic Five Pointed Star
      'ٮ', // Arabic Letter Superscript Alef
      'ٯ', // Arabic Letter Superscript Alef
      '۠', // Arabic Letter Superscript Alef
      'ۡ', // Arabic Letter Small Yeh
      'ۢ', // Arabic Letter Small Ta
      'ۣ', // Arabic Letter Small Seen
      'ۥ', // Arabic Letter Small Yeh
      'ۧ', // Arabic Letter Small Fatha
      'ۨ', // Arabic Letter Small Damma
      '۩', // Arabic Letter Small Kasra
      '۪', // Arabic Letter Small Shadda
      '۫', // Arabic Letter Small Sukun
      '۬', // Arabic Letter Small Waw
      'ۭ', // Arabic Letter Small Yeh
      'ۮ', // Arabic Letter Small Sukun
      'ۯ', // Arabic Letter Small Fatha
      '۰', // Arabic Letter Small Damma
      '۱', // Arabic Letter Small Kasra
      '۲', // Arabic Letter Small Shadda
      '۳', // Arabic Letter Small Waw
      '۴', // Arabic Letter Small Yeh
      '۵', // Arabic Letter Small Fatha
      '۶', // Arabic Letter Small Damma
      '۷', // Arabic Letter Small Kasra
      '۸', // Arabic Letter Small Shadda
      '۹', // Arabic Letter Small Yeh
      'ۺ', // Arabic Letter Small Waw
      'ۻ', // Arabic Letter Small Yeh
      'ۼ', // Arabic Letter Small Fatha
      '۽', // Arabic Letter Small Damma
      '۾', // Arabic Letter Small Kasra
      'ۿ', // Arabic Letter Small Shadda
      'ـ', // Arabic Tatweel (Stretching character)
      'ٔ', // Arabic Letter Hamza Above
      'ٴ', // Arabic Letter Hamza
      'ٵ', // Arabic Letter Waw With Hamza
      'ٶ', // Arabic Letter Waw With Hamza
      'ٷ', // Arabic Letter Waw With Hamza
      'ٸ', // Arabic Letter Yeh With Hamza
      'ٹ', // Arabic Letter Yeh With Hamza
      'ٺ', // Arabic Letter Yeh With Hamza
      'ٻ', // Arabic Letter Yeh With Hamza
      'ٽ', // Arabic Letter Yeh With Hamza
      'پ', // Arabic Letter Yeh With Hamza
      'ٿ', // Arabic Letter Yeh With Hamza
      'ٰ', // Arabic Letter Superscript Alef
      'ّ', // Arabic Shadda
      'ۡ', // Arabic Letter Small Yeh
      'ۢ', // Arabic Letter Small Ta
      'ۣ', // Arabic Letter Small Seen
      'ۥ', // Arabic Letter Small Yeh
      'ۧ', // Arabic Letter Small Fatha
      'ۨ', // Arabic Letter Small Damma
      '۩', // Arabic Letter Small Kasra
      '۪', // Arabic Letter Small Shadda
      '۫', // Arabic Letter Small Sukun
      '۬', // Arabic Letter Small Waw
      'ۭ', // Arabic Letter Small Yeh
      'ۮ', // Arabic Letter Small Sukun
      'ۯ', // Arabic Letter Small Fatha
      'ۿ', // Arabic Letter Small Shadda
      'ۗ', // Arabic Letter Small Sukun
      'ۚ', // Arabic Letter Small Damma
    ];
    text = text.replaceAll('ٳ', 'ا');
    text = text.replaceAll('ٲ', 'ا');
    text = text.replaceAll('ٱ', 'ا');
    return text.split('').where((char) => !diacritics.contains(char)).join('');
  }

  static String removeArabicDiacriticsAdvanced(String textRechercher) {
    textRechercher = textRechercher.replaceAll('ٳ', '');
    textRechercher = textRechercher.replaceAll('ٲ', '');
    textRechercher = textRechercher.replaceAll('ٱ', '');
    textRechercher = textRechercher.replaceAll('ا', '');
    return textRechercher;
  }
}


// يَوۡمِ ٱلدِّينِ