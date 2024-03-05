// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:developer';
import 'package:bible_picker/bibledata.dart';
import 'package:bible_picker/bibleversions.dart';
import 'package:bible_picker/databasehandler.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:xml2json/xml2json.dart';
import 'package:http/http.dart' as http;

class Bible extends StatefulWidget {
  const Bible({super.key});

  @override
  State<Bible> createState() => _BibleState();
}

class _BibleState extends State<Bible> {
  @override
  void initState() {
    super.initState();
    BibleDataBase.instance.initializaDB();
    todayDate =
        '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}';
  }

  String todayDate = '';

  // String dailyReadingURL =
  //     'https://www.catholic.org/bible/daily_reading/?select_date=$todayDate';
  // 'https://www.catholic.org/bible/daily_reading/?select_date=2024-02-28';
  // String dailyReadingURL = 'https://www.catholic.org/xml/rss_dailyreadings.php';
  final Xml2Json xml2json = Xml2Json();
  var topStories;

// Method to fetch and parse the RSS feed
  Future<void> getArticles() async {
    log('<========== $todayDate =============>');
    final url = Uri.parse('https://www.catholic.org/xml/rss_dailyreadings.php');
    final response = await http.get(url);
    // log(response.body.toString());
    try {
      // Parse the XML response
      xml2json.parse(response.body);

// Convert XML to JSON format
      var jsondata = xml2json.toGData();
      var data = json.decode(jsondata);

// Extract top stories from the JSON data
      setState(() {
        topStories = data;
      });

// Print top stories to console (for debugging)
      log('<========== $topStories =============>');
    } catch (e) {
      log('<========== $e =============>');
    }
  }

  final CustomPopupMenuController popcontrollerbible =
      CustomPopupMenuController();
  final CustomPopupMenuController popcontrollerbook =
      CustomPopupMenuController();
  final CustomPopupMenuController popcontrollerchapter =
      CustomPopupMenuController();
  final CustomPopupMenuController popcontrollerverse =
      CustomPopupMenuController();
  TextEditingController bible =
      TextEditingController(text: 'American Standard Version (1901)');
  TextEditingController book = TextEditingController();
  TextEditingController chapter = TextEditingController();
  TextEditingController verse = TextEditingController();
  int currentBookIndex = 0;
  int currentVerse = 0;
  int currentChapter = 0;
  String bibleVerse = '';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            separator(height: 35),
            const Text('Bible'),
            separator(height: 5),
            bibleWidget(),
            const Text('Book'),
            separator(height: 5),
            bookWidget(),
            separator(height: 15),
            const Text('Chapter'),
            separator(height: 5),
            chapterWidget(),
            separator(height: 15),
            const Text('Verse'),
            separator(height: 5),
            verseWidget(),
            separator(height: 25),
            Text(bibleVerse),
            separator(height: 25),
            ElevatedButton(
                onPressed: () {
                  getArticles();
                },
                child: const Text('Arcile')),
            separator(height: 25),
            ElevatedButton(
                onPressed: () {
                  log('<========== ${topStories['rss']['channel']['item'].first['description']['\$t'].split(',')} =============>');
                },
                child: const Text('view')),
            separator(height: 25),
            ElevatedButton(
                onPressed: () async {
                  // bibleRangeVerse(topStories['rss']['channel']['item'].first);
                },
                child: const Text('Resolve range verses')),
          ],
        ),
      ),
    );
  }

  bibleRangeVerse(String book) async {
    String rangeBible = book;
    List<String> splitRangeBible = rangeBible.split(' ');
    String bibleBook = '';
    String chapterBible = '';
    List<String> verseBible = [];
    String bookIndex = '';

    if (splitRangeBible.length == 2) {
      bibleBook = splitRangeBible.first;
    } else {
      bibleBook = '${splitRangeBible[0]} ${splitRangeBible[1]}';
    }
    chapterBible = splitRangeBible.last.split(':').first;
    verseBible = splitRangeBible.last.split(':').last.split('-');

    for (var element in bibleBooks) {
      if (element['book'] == bibleBook) {
        bookIndex = element['index'].toString();
      }
    }
    log('<========== $bibleBook =============>');
    log('<========== $chapterBible =============>');
    log('<========== $verseBible =============>');
    log('<========== $bookIndex =============>');
    List bookVerses = await BibleDataBase.instance.getRangeVerse(
        bookID: bookIndex, chapterID: chapterBible, verseRange: verseBible);
    log('<========== ${bookVerses.join('\n')} =============>');
  }

  Widget bibleWidget() => CustomPopupMenu(
        controller: popcontrollerbible,
        pressType: PressType.singleClick,
        menuBuilder: () {
          return Container(
            height: 200,
            color: Colors.white,
            width: 250,
            child: SingleChildScrollView(
              child: Column(
                children: bibleVersions
                    .map((e) => GestureDetector(
                          onTap: () async {
                            popcontrollerbible.hideMenu();
                            bible.text = e.name;
                            bool isClosed =
                                await BibleDataBase.instance.close();
                            if (isClosed) {
                              bool isInitialized = await BibleDataBase.instance
                                  .initializaDB(
                                      dbName: e.dbName, assetPath: e.assetPath);
                              //     chapter.text = '';
                              // verse.text = '';
                              // bibleVerse = '';
                              if (isInitialized) {
                                List result = await BibleDataBase.instance
                                    .getVerse(
                                        bookID:
                                            (currentBookIndex + 1).toString(),
                                        chapterID: chapter.text,
                                        verseID: verse.text);
                                if (result.isNotEmpty) {
                                  bibleVerse = result.first['text'];
                                }
                              }

                              setState(() {});
                            }
                          },
                          child: Container(
                            height: 40,
                            color: Colors.transparent,
                            child: Center(
                              child: Text(
                                e.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          );
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                bible.text,
              ),
              const Icon(
                Icons.arrow_drop_down,
                size: 25,
              )
            ],
          ),
        ),
      );
  Widget bookWidget() => CustomPopupMenu(
        controller: popcontrollerbook,
        pressType: PressType.singleClick,
        menuBuilder: () {
          return Container(
            height: 200,
            color: Colors.white,
            width: 250,
            child: SingleChildScrollView(
              child: Column(
                children: bibleBooks
                    .map((e) => GestureDetector(
                          onTap: () {
                            popcontrollerbook.hideMenu();
                            setState(() {
                              book.text = e['book'];
                              currentBookIndex = e['index'] - 1;
                              chapter.text = '';
                              verse.text = '';
                              bibleVerse = '';
                            });
                          },
                          child: Container(
                            height: 40,
                            color: Colors.transparent,
                            child: Center(
                              child: Text(
                                e['book'],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          );
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                book.text,
              ),
              const Icon(
                Icons.arrow_drop_down,
                size: 25,
              )
            ],
          ),
        ),
      );
  Widget chapterWidget() {
    List<int> chapterInts = [];
    for (var i = 1; i <= bibleBooks[currentBookIndex]['max_chapters']; i++) {
      chapterInts.add(i);
    }
    return CustomPopupMenu(
      controller: popcontrollerchapter,
      pressType: PressType.singleClick,
      menuBuilder: () {
        return Container(
          height: 200,
          color: Colors.white,
          width: 250,
          child: SingleChildScrollView(
            child: Column(
              children: chapterInts
                  .map((e) => GestureDetector(
                        onTap: () {
                          popcontrollerchapter.hideMenu();
                          setState(() {
                            currentChapter = e;
                            chapter.text = e.toString();
                            verse.text = '';
                          });
                        },
                        child: Container(
                          height: 40,
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              e.toString(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        );
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              chapter.text,
            ),
            const Icon(
              Icons.arrow_drop_down,
              size: 25,
            )
          ],
        ),
      ),
    );
  }

  Widget verseWidget() {
    List<int> verseInts = [];
    for (var i = 1; i <= bibleBooks[currentBookIndex]['max_verses']; i++) {
      verseInts.add(i);
    }
    return CustomPopupMenu(
      controller: popcontrollerverse,
      pressType: PressType.singleClick,
      menuBuilder: () {
        return Container(
          height: 200,
          color: Colors.white,
          width: 250,
          child: SingleChildScrollView(
            child: Column(
              children: verseInts
                  .map((e) => GestureDetector(
                        onTap: () async {
                          popcontrollerverse.hideMenu();
                          currentVerse = e;
                          verse.text = e.toString();
                          List result = await BibleDataBase.instance.getVerse(
                              bookID: (currentBookIndex + 1).toString(),
                              chapterID: chapter.text,
                              verseID: verse.text);
                          if (result.isNotEmpty) {
                            bibleVerse = result.first['text'];
                          }
                          setState(() {});
                        },
                        child: Container(
                          height: 40,
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              e.toString(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
        );
      },
      child: Container(
        height: 40,
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              verse.text,
            ),
            const Icon(
              Icons.arrow_drop_down,
              size: 25,
            )
          ],
        ),
      ),
    );
  }

  Widget separator({double? height}) => SizedBox(
        height: height ?? 1,
      );
}
