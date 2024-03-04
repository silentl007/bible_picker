// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:developer';
import 'package:bibleapp/bibleversions.dart';
import 'package:bibleapp/databasehandler.dart';
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

List<Map> bibleBooks = [
  {
    "index": 1,
    "book": "Genesis",
    "max_chapters": 50,
    "max_verses": 31,
    "chapters": {
      "1": 31,
      "2": 25,
      "3": 24,
      "4": 26,
      "5": 32,
      "6": 22,
      "7": 24,
      "8": 22,
      "9": 29,
      "10": 32,
      "11": 32,
      "12": 20,
      "13": 18,
      "14": 24,
      "15": 21,
      "16": 16,
      "17": 27,
      "18": 33,
      "19": 38,
      "20": 18,
      "21": 34,
      "22": 24,
      "23": 20,
      "24": 67,
      "25": 34,
      "26": 35,
      "27": 46,
      "28": 22,
      "29": 35,
      "30": 43,
      "31": 55,
      "32": 32,
      "33": 20,
      "34": 31,
      "35": 29,
      "36": 43,
      "37": 36,
      "38": 30,
      "39": 23,
      "40": 23,
      "41": 57,
      "42": 38,
      "43": 34,
      "44": 34,
      "45": 28,
      "46": 34,
      "47": 31,
      "48": 22,
      "49": 33,
      "50": 26
    }
  },
  {
    "index": 2,
    "book": "Exodus",
    "max_chapters": 40,
    "max_verses": 51,
    "chapters": {
      "1": 22,
      "2": 25,
      "3": 22,
      "4": 31,
      "5": 23,
      "6": 30,
      "7": 25,
      "8": 32,
      "9": 35,
      "10": 29,
      "11": 10,
      "12": 51,
      "13": 22,
      "14": 31,
      "15": 27,
      "16": 36,
      "17": 16,
      "18": 27,
      "19": 25,
      "20": 26,
      "21": 36,
      "22": 31,
      "23": 33,
      "24": 18,
      "25": 40,
      "26": 37,
      "27": 21,
      "28": 43,
      "29": 46,
      "30": 38,
      "31": 18,
      "32": 35,
      "33": 23,
      "34": 35,
      "35": 35,
      "36": 38,
      "37": 29,
      "38": 31,
      "39": 43,
      "40": 38
    }
  },
  {
    "index": 3,
    "book": "Leviticus",
    "max_chapters": 27,
    "max_verses": 17,
    "chapters": {
      "1": 17,
      "2": 16,
      "3": 17,
      "4": 35,
      "5": 19,
      "6": 30,
      "7": 38,
      "8": 36,
      "9": 24,
      "10": 20,
      "11": 47,
      "12": 8,
      "13": 59,
      "14": 57,
      "15": 33,
      "16": 34,
      "17": 16,
      "18": 30,
      "19": 37,
      "20": 27,
      "21": 24,
      "22": 33,
      "23": 44,
      "24": 23,
      "25": 55,
      "26": 46,
      "27": 34
    }
  },
  {
    "index": 4,
    "book": "Numbers",
    "max_chapters": 36,
    "max_verses": 89,
    "chapters": {
      "1": 54,
      "2": 34,
      "3": 51,
      "4": 49,
      "5": 31,
      "6": 27,
      "7": 89,
      "8": 26,
      "9": 23,
      "10": 36,
      "11": 35,
      "12": 16,
      "13": 33,
      "14": 45,
      "15": 41,
      "16": 50,
      "17": 13,
      "18": 32,
      "19": 22,
      "20": 29,
      "21": 35,
      "22": 41,
      "23": 30,
      "24": 25,
      "25": 18,
      "26": 65,
      "27": 23,
      "28": 31,
      "29": 40,
      "30": 16,
      "31": 54,
      "32": 42,
      "33": 56,
      "34": 29,
      "35": 34,
      "36": 13
    }
  },
  {
    "index": 5,
    "book": "Deuteronomy",
    "max_chapters": 34,
    "max_verses": 68,
    "chapters": {
      "1": 46,
      "2": 37,
      "3": 29,
      "4": 49,
      "5": 33,
      "6": 25,
      "7": 26,
      "8": 20,
      "9": 29,
      "10": 22,
      "11": 32,
      "12": 32,
      "13": 18,
      "14": 29,
      "15": 23,
      "16": 22,
      "17": 20,
      "18": 22,
      "19": 21,
      "20": 20,
      "21": 23,
      "22": 30,
      "23": 25,
      "24": 22,
      "25": 19,
      "26": 19,
      "27": 26,
      "28": 68,
      "29": 29,
      "30": 20,
      "31": 30,
      "32": 52,
      "33": 29,
      "34": 12
    }
  },
  {"index": 6, "book": "Joshua", "max_chapters": 24, "max_verses": 33},
  {"index": 7, "book": "Judges", "max_chapters": 21, "max_verses": 40},
  {"index": 8, "book": "Ruth", "max_chapters": 4, "max_verses": 22},
  {"index": 9, "book": "1 Samuel", "max_chapters": 31, "max_verses": 35},
  {"index": 10, "book": "2 Samuel", "max_chapters": 24, "max_verses": 25},
  {"index": 11, "book": "1 Kings", "max_chapters": 22, "max_verses": 66},
  {"index": 12, "book": "2 Kings", "max_chapters": 25, "max_verses": 37},
  {"index": 13, "book": "1 Chronicles", "max_chapters": 29, "max_verses": 34},
  {"index": 14, "book": "2 Chronicles", "max_chapters": 36, "max_verses": 27},
  {"index": 15, "book": "Ezra", "max_chapters": 10, "max_verses": 28},
  {"index": 16, "book": "Nehemiah", "max_chapters": 13, "max_verses": 18},
  {"index": 17, "book": "Esther", "max_chapters": 10, "max_verses": 17},
  {"index": 18, "book": "Job", "max_chapters": 42, "max_verses": 22},
  {"index": 19, "book": "Psalms", "max_chapters": 150, "max_verses": 176},
  {"index": 20, "book": "Proverbs", "max_chapters": 31, "max_verses": 31},
  {"index": 21, "book": "Ecclesiastes", "max_chapters": 12, "max_verses": 29},
  {"index": 22, "book": "Song of Solomon", "max_chapters": 8, "max_verses": 16},
  {"index": 23, "book": "Isaiah", "max_chapters": 66, "max_verses": 24},
  {"index": 24, "book": "Jeremiah", "max_chapters": 52, "max_verses": 34},
  {"index": 25, "book": "Lamentations", "max_chapters": 5, "max_verses": 66},
  {"index": 26, "book": "Ezekiel", "max_chapters": 48, "max_verses": 35},
  {"index": 27, "book": "Daniel", "max_chapters": 12, "max_verses": 30},
  {"index": 28, "book": "Hosea", "max_chapters": 14, "max_verses": 9},
  {"index": 29, "book": "Joel", "max_chapters": 3, "max_verses": 21},
  {"index": 30, "book": "Amos", "max_chapters": 9, "max_verses": 15},
  {"index": 31, "book": "Obadiah", "max_chapters": 1, "max_verses": 21},
  {"index": 32, "book": "Jonah", "max_chapters": 4, "max_verses": 10},
  {"index": 33, "book": "Micah", "max_chapters": 7, "max_verses": 20},
  {"index": 34, "book": "Nahum", "max_chapters": 3, "max_verses": 15},
  {"index": 35, "book": "Habakkuk", "max_chapters": 3, "max_verses": 20},
  {"index": 36, "book": "Zephaniah", "max_chapters": 3, "max_verses": 20},
  {"index": 37, "book": "Haggai", "max_chapters": 2, "max_verses": 23},
  {"index": 38, "book": "Zechariah", "max_chapters": 14, "max_verses": 21},
  {"index": 39, "book": "Malachi", "max_chapters": 4, "max_verses": 6},
  {"index": 40, "book": "Matthew", "max_chapters": 28, "max_verses": 48},
  {"index": 41, "book": "Mark", "max_chapters": 16, "max_verses": 47},
  {"index": 42, "book": "Luke", "max_chapters": 24, "max_verses": 80},
  {"index": 43, "book": "John", "max_chapters": 21, "max_verses": 57},
  {"index": 44, "book": "Acts", "max_chapters": 28, "max_verses": 60},
  {"index": 45, "book": "Romans", "max_chapters": 16, "max_verses": 39},
  {"index": 46, "book": "1 Corinthians", "max_chapters": 16, "max_verses": 58},
  {"index": 47, "book": "2 Corinthians", "max_chapters": 13, "max_verses": 18},
  {"index": 48, "book": "Galatians", "max_chapters": 6, "max_verses": 24},
  {"index": 49, "book": "Ephesians", "max_chapters": 6, "max_verses": 21},
  {"index": 50, "book": "Philippians", "max_chapters": 4, "max_verses": 23},
  {"index": 51, "book": "Colossians", "max_chapters": 4, "max_verses": 23},
  {"index": 52, "book": "1 Thessalonians", "max_chapters": 5, "max_verses": 28},
  {"index": 53, "book": "2 Thessalonians", "max_chapters": 3, "max_verses": 18},
  {"index": 54, "book": "1 Timothy", "max_chapters": 6, "max_verses": 21},
  {"index": 55, "book": "2 Timothy", "max_chapters": 4, "max_verses": 26},
  {"index": 56, "book": "Titus", "max_chapters": 3, "max_verses": 15},
  {"index": 57, "book": "Philemon", "max_chapters": 1, "max_verses": 25},
  {"index": 58, "book": "Hebrews", "max_chapters": 13, "max_verses": 40},
  {"index": 59, "book": "James", "max_chapters": 5, "max_verses": 26},
  {"index": 60, "book": "1 Peter", "max_chapters": 5, "max_verses": 22},
  {"index": 61, "book": "2 Peter", "max_chapters": 3, "max_verses": 18},
  {"index": 62, "book": "1 John", "max_chapters": 5, "max_verses": 24},
  {"index": 63, "book": "2 John", "max_chapters": 1, "max_verses": 13},
  {"index": 64, "book": "3 John", "max_chapters": 1, "max_verses": 14},
  {"index": 65, "book": "Jude", "max_chapters": 1, "max_verses": 25},
  {"index": 66, "book": "Revelation", "max_chapters": 22, "max_verses": 17}
];

