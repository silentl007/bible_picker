import 'package:bible_picker/bibledata.dart';
import 'package:bible_picker/bibleversions.dart';
import 'package:bible_picker/classes.dart';
import 'package:bible_picker/databasehandler.dart';
import 'package:bible_picker/widgets.dart';
import 'package:flutter/material.dart';

class BiblePicker extends StatefulWidget {
  const BiblePicker({super.key});

  @override
  State<BiblePicker> createState() => _BiblePickerState();
}

class _BiblePickerState extends State<BiblePicker> {
  @override
  void initState() {
    super.initState();
    BibleDataBase.instance.initializaDB();
  }

  TextEditingController bible =
      TextEditingController(text: 'American Standard Version (1901)');
  TextEditingController bookController = TextEditingController();
  TextEditingController chapterController = TextEditingController();
  TextEditingController verseFirstController = TextEditingController();
  TextEditingController verseSecondController = TextEditingController();
  int currentBookIndex = 0;
  int currentFirstVerse = 0;
  int currentSecondVerse = 0;
  int currentChapter = 0;
  String bibleVerse = '';
  String bibleBookChapterVerse = '';
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: internalPadding(),
          child: bibleVersePost(),
        ),
      ),
    );
  }

  Widget bibleVersePost() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          customDivider(height: 5),
          Text(
            'Bible',
            style: Decor().textStyle(size: 16),
          ),
          customDivider(height: 10),
          TextFormField(
            controller: bible,
            readOnly: true,
            onTap: biblePicker,
            decoration: Decor().textform(suffixIcon: sufficIcon()),
          ),
          customDivider(height: 15),
          Text(
            'Book',
            style: Decor().textStyle(size: 16),
          ),
          customDivider(height: 10),
          TextFormField(
            controller: bookController,
            readOnly: true,
            onTap: bibleBookPicker,
            decoration: Decor().textform(suffixIcon: sufficIcon()),
          ),
          customDivider(height: 15),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chapter',
                      style: Decor().textStyle(size: 16),
                    ),
                    customDivider(height: 10),
                    TextFormField(
                      controller: chapterController,
                      readOnly: true,
                      onTap: () {
                        if (bookController.text.isNotEmpty) {
                          bibleChapterPicker();
                        }
                      },
                      decoration: Decor().textform(suffixIcon: sufficIcon()),
                    ),
                  ],
                ),
              ),
              customhorizontal(width: 10),
              Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verse',
                        style: Decor().textStyle(size: 16),
                      ),
                      customDivider(height: 10),
                      Row(
                        children: [
                          Expanded(
                              child: TextFormField(
                            controller: verseFirstController,
                            readOnly: true,
                            onTap: () {
                              if (bookController.text.isNotEmpty &&
                                  chapterController.text.isNotEmpty) {
                                bibleFirstVersePicker();
                              }
                            },
                            decoration:
                                Decor().textform(suffixIcon: sufficIcon()),
                          )),
                          Container(
                              color: UserColors.purple,
                              height: 60,
                              width: 50,
                              child: Center(
                                child: Text(
                                  'To',
                                  style: Decor()
                                      .textStyle(size: 18, color: Colors.white),
                                ),
                              )),
                          Expanded(
                              child: TextFormField(
                            controller: verseSecondController,
                            readOnly: true,
                            onTap: () {
                              if (bookController.text.isNotEmpty &&
                                  chapterController.text.isNotEmpty &&
                                  verseFirstController.text.isNotEmpty) {
                                bibleSecondVersePicker();
                              }
                            },
                            decoration:
                                Decor().textform(suffixIcon: sufficIcon()),
                          )),
                        ],
                      )
                    ],
                  ))
            ],
          ),
          if (bibleVerse.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      bottomSheetWidget(
                          context: context,
                          height: 500,
                          useInternalPadding: false,
                          body: Column(
                            children: [
                              Container(
                                height: 50,
                                width: double.infinity,
                                color: UserColors.purple,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  bibleBookChapterVerse,
                                  style: Decor()
                                      .textStyle(size: 18, color: Colors.white),
                                ),
                              ),
                              Expanded(
                                  child: SingleChildScrollView(
                                child: Padding(
                                  padding: internalPadding(),
                                  child: Text(
                                    bibleVerse,
                                    style: Decor().textStyle(size: 18),
                                  ),
                                ),
                              ))
                            ],
                          ));
                    },
                    child: Text(
                      'View Bible verse',
                      style: Decor().textStyle(color: UserColors.purple),
                    )),
              ],
            ),
          customDivider(height: 15),
        ],
      ),
    );
  }

  biblePicker() {
    return bottomSheetWidget(
      context: context,
      height: 600,
      body: ListView.separated(
          itemBuilder: (context, index) => ListTile(
                onTap: () async {
                  bible.text = bibleVersions[index].name;
                  bool isClosed = await BibleDataBase.instance.close();
                  if (isClosed) {
                    bool isInitialized = await BibleDataBase.instance
                        .initializaDB(
                            dbName: bibleVersions[index].dbName,
                            assetPath: bibleVersions[index].assetPath);
                    if (isInitialized) {
                      bibleRangeVerse(bibleBookChapterVerse);
                    }
                  }
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
                title: Text(bibleVersions[index].name),
              ),
          separatorBuilder: (context, index) =>
              customDivider(color: Colors.grey.withOpacity(.3)),
          itemCount: bibleVersions.length),
    );
  }

  bibleBookPicker() {
    List<Map> bibleFilter = bibleBooks;
    return bottomSheetWidget(
      context: context,
      height: 600,
      body: StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            TextFormField(
              decoration: Decor().searchForm(),
              onChanged: (value) {
                bibleFilter = bibleBooks
                    .where((element) => element['book']
                        .toLowerCase()
                        .contains(value.toLowerCase()))
                    .toList();
                setState(() {});
              },
            ),
            customDivider(height: 15),
            Expanded(
                child: ListView.separated(
                    itemBuilder: (context, index) => ListTile(
                          onTap: () {
                            bookController.text = bibleFilter[index]['book'];
                            currentBookIndex = bibleFilter[index]['index'] - 1;
                            chapterController.text = '';
                            verseFirstController.text = '';
                            verseSecondController.text = '';
                            bibleVerse = '';
                            Navigator.pop(context);
                          },
                          title: Text(bibleFilter[index]['book']),
                        ),
                    separatorBuilder: (context, index) =>
                        customDivider(color: Colors.grey.withOpacity(.3)),
                    itemCount: bibleFilter.length))
          ],
        ),
      ),
    );
  }

  bibleChapterPicker() {
    List<int> chapterInts = [];
    for (var i = 1; i <= bibleBooks[currentBookIndex]['max_chapters']; i++) {
      chapterInts.add(i);
    }
    return bottomSheetWidget(
      context: context,
      height: 600,
      body: StatefulBuilder(
        builder: (context, setState) => ListView.separated(
            itemBuilder: (context, index) => ListTile(
                  onTap: () {
                    chapterController.text = chapterInts[index].toString();
                    currentChapter = chapterInts[index];
                    bibleVerse = '';
                    verseFirstController.text = '';
                    verseSecondController.text = '';
                    Navigator.pop(context);
                  },
                  title: Text(chapterInts[index].toString()),
                ),
            separatorBuilder: (context, index) =>
                customDivider(color: Colors.grey.withOpacity(.3)),
            itemCount: chapterInts.length),
      ),
    );
  }

  int getVerseLength() {
    return chaptersAndVerses[currentBookIndex][currentChapter]!;
  }

  bibleFirstVersePicker() {
    List<int> verseInts = [];
    for (var i = 1; i <= getVerseLength(); i++) {
      verseInts.add(i);
    }
    return bottomSheetWidget(
      context: context,
      height: 600,
      body: StatefulBuilder(
        builder: (context, setState) => ListView.separated(
            itemBuilder: (context, index) => ListTile(
                  onTap: () {
                    verseFirstController.text = verseInts[index].toString();
                    verseSecondController.text = '';
                    currentFirstVerse = verseInts[index];
                    currentSecondVerse = 0;
                    bibleVerse = '';
                    Navigator.pop(context);
                  },
                  title: Text(verseInts[index].toString()),
                ),
            separatorBuilder: (context, index) =>
                customDivider(color: Colors.grey.withOpacity(.3)),
            itemCount: verseInts.length),
      ),
    );
  }

  bibleSecondVersePicker() {
    List<int> verseInts = [];
    for (var i = currentFirstVerse; i <= getVerseLength(); i++) {
      verseInts.add(i);
    }
    return bottomSheetWidget(
      context: context,
      height: 600,
      body: StatefulBuilder(
        builder: (context, setState) => ListView.separated(
            itemBuilder: (context, index) => ListTile(
                  onTap: () {
                    verseSecondController.text = verseInts[index].toString();
                    currentSecondVerse = verseInts[index];
                    bibleBookChapterVerse =
                        '${bookController.text} ${chapterController.text}:$currentFirstVerse-$currentSecondVerse';
                    bibleRangeVerse(bibleBookChapterVerse);
                    Navigator.pop(context);
                  },
                  title: Text(verseInts[index].toString()),
                ),
            separatorBuilder: (context, index) =>
                customDivider(color: Colors.grey.withOpacity(.3)),
            itemCount: verseInts.length),
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
    // dev.log('<========== $bibleBook =============>');
    // dev.log('<========== $chapterBible =============>');
    // dev.log('<========== $verseBible =============>');
    // dev.log('<========== $bookIndex =============>');
    List bookVerses = await BibleDataBase.instance.getRangeVerse(
        bookID: bookIndex, chapterID: chapterBible, verseRange: verseBible);
    bibleVerse = bookVerses.join('\n\n');
    setState(() {});
  }
}
