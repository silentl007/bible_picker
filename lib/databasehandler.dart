// ignore_for_file: depend_on_referenced_packages

import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BibleDataBase {
  static final BibleDataBase instance = BibleDataBase._init();
  static Database? _database;
  BibleDataBase._init();

  Future<Database> get getDatabase async {
    return _database!;
  }

  Future<bool> initializaDB(
      {String dbName = 'asv.db',
      String assetPath = "assets/bible/asv.sqlite"}) async {
    // Get the directory for the app's documents directory.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, dbName);

    // Check if the database exists
    bool exists = await databaseExists(path);

    if (!exists) {
      // If it doesn't exist, copy from assets
      ByteData data = await rootBundle.load(assetPath);
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }

    _database = await openDatabase(path, readOnly: true);
    if (_database != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<List> getVerse({
    required String bookID,
    required String chapterID,
    required String verseID,
  }) async {
    final db = await instance.getDatabase;
    final maps = await db.rawQuery(
      'SELECT * FROM verses WHERE book=$bookID AND chapter=$chapterID AND verse=$verseID',
    );

    if (maps.isNotEmpty) {
      return maps;
    } else {
      // throw Exception('ID $id not found');
      return [];
    }
  }

  Future<List> getRangeVerse({
    required String bookID,
    required String chapterID,
    required List<String> verseRange,
  }) async {
    List allVerses = [];
    final db = await instance.getDatabase;
    for (int i = int.tryParse(verseRange.first)!;
        i <= int.tryParse(verseRange.last)!;
        i++) {
      final maps = await db.rawQuery(
        'SELECT * FROM verses WHERE book=$bookID AND chapter=$chapterID AND verse=$i',
      );

      if (maps.isNotEmpty) {
        allVerses.add('$i. ${maps.first['text']}');
      }
    }
    return allVerses;
  }

  Future<bool> close() async {
    final db = await instance.getDatabase;
    db.close();
    return db.isOpen;
  }
}
