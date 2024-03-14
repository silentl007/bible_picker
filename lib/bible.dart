// ignore_for_file: unused_import

import 'dart:convert';
import 'dart:developer';
import 'package:bible_picker/bibledata.dart';
import 'package:bible_picker/bibleversions.dart';
import 'package:bible_picker/classes.dart';
import 'package:bible_picker/databasehandler.dart';
import 'package:bible_picker/widgets.dart';
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
    final url = Uri.parse('https://www.catholic.org/xml/rss_dailyreadings.php');
    final response = await http.get(url);
    // log(response.body.toString());
    try {
      if (response.statusCode == 200) {
        // Parse the XML response
        xml2json.parse(response.body);

// Convert XML to JSON format
        var jsondata = xml2json.toGData();
        var data = json.decode(jsondata);

// Extract top stories from the JSON data
        setState(() {
          topStories = data;
        });
        dailyReadingList = topStories['rss']['channel']['item']
            .first['description']['\$t']
            .split(',');
        log('<========== ${topStories['rss']['channel']['item'].first['description']['\$t'].split(',')} =============>');
        // log('<========== ${topStories['rss']['channel']['item'].first['link']} =============>');
      }
    } catch (e) {
      log('<========== $e =============>');
    }
  }

  List dailyReadingList = [];
  final CustomPopupMenuController popcontrollerbible =
      CustomPopupMenuController();
  final CustomPopupMenuController popcontrollerbook =
      CustomPopupMenuController();
  final CustomPopupMenuController popcontrollerchapter =
      CustomPopupMenuController();
  final CustomPopupMenuController popcontrollerverse =
      CustomPopupMenuController();
  final CustomPopupMenuController popcontrollerversesecond =
      CustomPopupMenuController();
  TextEditingController bible =
      TextEditingController(text: 'American Standard Version (1901)');
  TextEditingController book = TextEditingController();
  TextEditingController chapter = TextEditingController();
  TextEditingController verse = TextEditingController();
  TextEditingController customVerseController = TextEditingController();
  int currentVerse = 0;
  TextEditingController verseSecond = TextEditingController();
  int currentVerseSecond = 0;
  int currentBookIndex = 0;
  int currentChapter = 0;
  String bibleVerse = '';
  String bibleBookChapterVerse = '';
  bool showCustom = false;
  bool showVerse = false;
  List<Map> bibleCustomVerses = [];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
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
                const Text('First Verse'),
                separator(height: 5),
                verseWidget(),
                const Text('Second Verse'),
                separator(height: 5),
                verseSecondWidget(),
                separator(height: 15),
                TextFormField(
                  controller: customVerseController,
                  decoration: Decor().textform(),
                  onChanged: (value) {
                    setState(() {
                      showCustom = false;
                      showVerse = false;
                      bibleCustomVerses = [];
                    });
                  },
                ),
                separator(height: 25),
                if (showVerse) Text(bibleVerse),
                if (showCustom)
                  Column(
                      children: bibleCustomVerses
                          .map((e) => Column(
                                children: [
                                  Container(
                                    height: 50,
                                    width: double.infinity,
                                    color: UserColors.purple,
                                    alignment: Alignment.centerLeft,
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Text(
                                      e['book'],
                                      style: Decor().textStyle(
                                          size: 18, color: Colors.white),
                                    ),
                                  ),
                                  Padding(
                                    padding: internalPadding(),
                                    child: Text(
                                      e['verse'],
                                      style: Decor().textStyle(size: 18),
                                    ),
                                  )
                                ],
                              ))
                          .toList()),
                separator(height: 25),
                ElevatedButton(
                    onPressed: () async {
                      showVerse = true;
                      showCustom = false;
                    },
                    child: const Text('show verse')),
                separator(height: 25),
                ElevatedButton(
                    onPressed: () async {
                      showVerse = false;
                      showCustom = true;
                      if (validator()) {
                        generateCustomVerses();
                      } else {
                        log('failed');
                      }
                    },
                    child: const Text('show custom verses')),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool validator() {
    bool allow = true;
    List<String> customVerses = customVerseController.text.trim().split(',');
    for (String element in customVerses) {
      if (element.contains('-')) {
        if (element.trim().contains(RegExp(r'[!@#$%^&*(),.?":;{}|<>_]'))) {
          allow = false;
          break;
        }
      } else {
        if (int.tryParse(element.trim()) == null) {
          allow = false;
          break;
        }
      }
    }
    return allow;
  }

  generateCustomVerses() async {
    bibleVerse = '';
    bibleCustomVerses = [];
    String bibleBookChapter = '${book.text} ${chapter.text}';
    List<String> customVerses = customVerseController.text.trim().split(',');
    for (String element in customVerses) {
      if (element.contains('-')) {
        String extractedVerse =
            await bibleRangeVerse('$bibleBookChapter:${element.trim()}');
        bibleCustomVerses.add({
          'book': '$bibleBookChapter:${element.trim()}',
          'verse': extractedVerse
        });
      } else {
        String extractedVerse = await getSingleVerse(element.trim());
        bibleCustomVerses.add({
          'book': '$bibleBookChapter:${element.trim()}',
          'verse': extractedVerse
        });
      }
    }
    setState(() {});
  }

  Future<String> getSingleVerse(String verse) async {
    String resultText = '';
    List result = await BibleDataBase.instance.getVerse(
        bookID: (currentBookIndex + 1).toString(),
        chapterID: currentChapter.toString(),
        verseID: verse.toString());
    if (result.isNotEmpty) {
      resultText = result.first['text'];
    }
    return resultText;
  }

  Future<String> bibleRangeVerse(String book) async {
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
    // dev.log('<========== $bibleBook =============>');
    // dev.log('<========== $chapterBible =============>');
    // dev.log('<========== $verseBible =============>');
    // dev.log('<========== $bookIndex =============>');
    List bookVerses = await BibleDataBase.instance.getRangeVerse(
        bookID: bookIndex, chapterID: chapterBible, verseRange: verseBible);

    setState(() {});
    return bookVerses.join('\n\n');
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
                                bibleRangeVerse(bibleBookChapterVerse);
                              }
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
                              verseSecond.text = '';
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
                            verseSecond.text = '';
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
                          setState(() {});
                          // List result = await BibleDataBase.instance.getVerse(
                          //     bookID: (currentBookIndex + 1).toString(),
                          //     chapterID: chapter.text,
                          //     verseID: verse.text);
                          // if (result.isNotEmpty) {
                          //   bibleVerse = result.first['text'];
                          // }
                          // setState(() {});
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

  Widget verseSecondWidget() {
    List<int> verseInts = [];
    for (var i = currentVerse;
        i <= bibleBooks[currentBookIndex]['max_verses'];
        i++) {
      verseInts.add(i);
    }
    return CustomPopupMenu(
      controller: popcontrollerversesecond,
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
                          popcontrollerversesecond.hideMenu();
                          currentVerseSecond = e;
                          verseSecond.text = e.toString();
                          bibleBookChapterVerse =
                              '${book.text} ${chapter.text}:$currentVerse-$currentVerseSecond';
                          showCustom = false;
                          showVerse = true;
                          setState(() {});
                          bibleRangeVerse(bibleBookChapterVerse);
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
              verseSecond.text,
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
