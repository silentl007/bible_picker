class BibleVersions {
  String name;
  String assetPath;
  String dbName;
  BibleVersions({
    required this.name,
    required this.dbName,
    required this.assetPath,
  });
}

List<BibleVersions> bibleVersions = [
  BibleVersions(
      name: 'American Standard Version (1901)',
      dbName: 'asv.db',
      assetPath: 'assets/bible/asv.sqlite'),

  BibleVersions(
      name: "Bishops Bible (1568)",
      dbName: 'bishops.db',
      assetPath: 'assets/bible/bishops.sqlite'),
  BibleVersions(
      name: "Coverdale Bible (1535)",
      dbName: 'coverdale.db',
      assetPath: 'assets/bible/coverdale.sqlite'),
  BibleVersions(
      name: "Geneva Bible (1587)",
      dbName: 'geneva.db',
      assetPath: 'assets/bible/geneva.sqlite'),
  BibleVersions(
      name: "Authorized King James Version (1611 / 1769)",
      dbName: 'kjv.db',
      assetPath: 'assets/bible/kjv.sqlite'),
 
  BibleVersions(
      name: "NET Bible® (1996-2016)",
      dbName: 'net.db',
      assetPath: 'assets/bible/net.sqlite'),
  BibleVersions(
      name: "Tyndale Bible",
      dbName: 'tyndale.db',
      assetPath: 'assets/bible/tyndale.sqlite'),
  BibleVersions(
      name: "World English Bible (2006)",
      dbName: 'web.db',
      assetPath: 'assets/bible/web.sqlite'),
];
