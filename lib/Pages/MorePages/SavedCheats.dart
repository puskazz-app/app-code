import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:puskazz_app/Utils/Cheats/DatabaseHelper.dart';
import 'package:puskazz_app/Utils/Cheats/SaveModel.dart';
import 'package:puskazz_app/Utils/WS/WebsocketServer.dart';
import 'package:qr_bar_code/qr/qr.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Utils/GitHub/GitHubApi.dart';

class SavedCheats extends StatefulWidget {
  const SavedCheats({super.key});

  @override
  State<SavedCheats> createState() => _SavedCheatsState();
}

bool showShare = false;
String url = "";

class _SavedCheatsState extends State<SavedCheats> {
  List share = ["Megosztás", "Megosztás"];
  List specialCharacters = ["á", "é", "í", "ó", "ö", "ő", "ú", "ü", "ű"];
  List specialCharactersReplace = ["a", "e", "i", "o", "o", "o", "u", "u", "u"];
  String? cheat = "";
  String? scan = "";
  String query = "";
  bool loaded = false;
  bool searching = false;
  TextEditingController _controller = TextEditingController();
  FocusNode _focusNode = FocusNode();
  List<FocusNode> _focusNodes = [];
  List<TextEditingController> _controllers = [];
  int? lastItemId;

  final githubApi = GitHubApi(
    uniqueId: Random().nextInt(9999).toRadixString(36),
  );

  @override
  void initState() {
    super.initState();
    ScreenBrightness().resetScreenBrightness();
    getTitles("");
  }

  void getTitles(String? query) {
    var future = CheatsDBhelper.instance.search(query ?? '').then((value) {
      for (int i = 0; i < value.length; i++) {
        setState(() {
          _controllers.add(TextEditingController());
          _controllers[i].text = value[i].savedCheatTitle;
          _focusNodes.add(FocusNode());
        });
      }
    });
  }

  List<CheatsModel> searchItems(List<CheatsModel> allItems, String query) {
    //query = query.toLowerCase();
    /* for (var i = 0; i < specialCharacters.length; i++) {
      if(query.contains(specialCharacters[i])){
        query = query.replaceAll(specialCharacters[i], specialCharactersReplace[i]).toLowerCase();
      }
    } */
    return allItems
        .where((item) => item.savedCheatTitle.contains(query))
        .toList();
  }

  Future<void> saveBase64ToFile(String base64String, int index) async {
    try {
      List<int> bytes;
      if (base64String.startsWith("txt/md:::")) {
        base64String = base64String.substring(9, base64String.length - 3);

        String dateFormat = DateFormat("yyyyMMddHHmm").format(DateTime.now());

        Directory appDocDir = await getApplicationDocumentsDirectory();

        File file = File('${appDocDir.path}/file_${dateFormat}.txt');

        await file.writeAsString(base64String);

        print('File created: ${file.path}');

        String uniqueId = await githubApi.uniqueId;

        setState(() {
          url = "szoveg_puska::::${dateFormat}_${uniqueId}";
        });

        await githubApi.uploadMarkdownFile(file.path);
      } else {
        bytes = base64.decode(base64String);

        String dateFormat = DateFormat("yyyyMMddHHmm").format(DateTime.now());

        Directory appDocDir = await getApplicationDocumentsDirectory();

        File file = File('${appDocDir.path}/file_${dateFormat}.txt');

        await file.writeAsBytes(bytes);

        print('File created: ${file.path}');

        String uniqueId = await githubApi.uniqueId;

        setState(() {
          url = "puska::::${dateFormat}_${uniqueId}:::${index}";
        });
        await githubApi.uploadPngFile(file.path, index);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    Color textColor = Theme.of(context).primaryColor;
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return RefreshIndicator(
      color: bgColor,
      onRefresh: () async {
        setState(() {
          loaded = false;
          loaded = true;
        });
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(18),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        maxLines: 1,
                        focusNode: _focusNode,
                        textCapitalization: TextCapitalization.sentences,
                        cursorColor: Theme.of(context).primaryColor,
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                        controller: _controller,
                        decoration: InputDecoration(
                          fillColor:
                              Theme.of(context).scaffoldBackgroundColor ==
                                      Colors.white
                                  ? Colors.grey[200]
                                  : Colors.grey[900],
                          iconColor: Theme.of(context).scaffoldBackgroundColor,
                          suffixIconColor: Theme.of(context).primaryColor,
                          filled: true,
                          focusColor: Theme.of(context).primaryColor,
                          hoverColor: Theme.of(context).primaryColor,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          hintStyle:
                              TextStyle(color: Theme.of(context).primaryColor),
                          hintText: 'Keresés cím alapján',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear, color: textColor),
                            onPressed: () {
                              setState(() {
                                query = "";
                                _controller.clear();
                                _focusNode.unfocus();
                                searching = true;
                                loaded = false;
                              });
                              Timer.periodic(Duration(milliseconds: 250),
                                  (timer) {
                                getTitles(query);
                                timer.cancel();
                              });
                            },
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            query = _controller.text;
                            searching = true;
                            loaded = false;
                          });
                          Timer.periodic(Duration(milliseconds: 250), (timer) {
                            getTitles(query);
                            timer.cancel();
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          FutureBuilder<List<CheatsModel>>(
                            future: loaded == false
                                ? CheatsDBhelper.instance
                                    .search(query.toLowerCase())
                                : null,
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                if (snapshot.data!.isNotEmpty) {
                                  List<CheatsModel> allItems = snapshot.data!;
                                  List<CheatsModel> searchedItems =
                                      searchItems(allItems, query);

                                  return ListView.builder(
                                    itemCount: searchedItems.length,
                                    itemBuilder: (context, index) {
                                      index = searchedItems.length - index - 1;
                                      loaded = true;

                                      if (snapshot.data!.isNotEmpty) {
                                        return Container(
                                          width: width,
                                          margin: EdgeInsets.all(8),
                                          padding: EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            color: Theme.of(context)
                                                        .scaffoldBackgroundColor ==
                                                    Colors.white
                                                ? Colors.grey[200]
                                                : Colors.grey[900],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              TextField(
                                                maxLines: 1,
                                                focusNode: _focusNodes[index],
                                                controller: _controllers[index],
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
                                                cursorColor: Theme.of(context)
                                                    .primaryColor,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                                onChanged: (value) {
                                                  setState(() {
                                                    loaded = false;
                                                    snapshot.data![index]
                                                            .savedCheatTitle =
                                                        value;
                                                    query = value;
                                                  });
                                                  CheatsDBhelper.instance
                                                      .update(CheatsModel(
                                                    id: snapshot
                                                        .data![index].id,
                                                    savedCheatTitle:
                                                        _controllers[index]
                                                            .text,
                                                    savedCheatImages: snapshot
                                                        .data![index]
                                                        .savedCheatImages,
                                                  ));
                                                },
                                                decoration: InputDecoration(
                                                    fillColor: Theme.of(context)
                                                                .scaffoldBackgroundColor ==
                                                            Colors.white
                                                        ? Colors.grey[200]
                                                        : Colors.grey[900],
                                                    iconColor: Theme.of(context)
                                                        .scaffoldBackgroundColor,
                                                    suffixIconColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    filled: true,
                                                    focusColor: Theme.of(context)
                                                        .primaryColor,
                                                    hoverColor: Theme.of(
                                                            context)
                                                        .primaryColor,
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        25,
                                                      ),
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                    ),
                                                    disabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              25),
                                                    ),
                                                    hintStyle: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor),
                                                    hintText: 'Új cím',
                                                    suffixIcon: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            CheatsDBhelper
                                                                .instance
                                                                .update(
                                                                    CheatsModel(
                                                              id: snapshot
                                                                  .data![index]
                                                                  .id,
                                                              savedCheatTitle:
                                                                  _controllers[
                                                                          index]
                                                                      .text,
                                                              savedCheatImages:
                                                                  snapshot
                                                                      .data![
                                                                          index]
                                                                      .savedCheatImages,
                                                            ));
                                                            _focusNodes[index]
                                                                .unfocus();
                                                          });
                                                        },
                                                        child: Icon(
                                                          Icons.done,
                                                          color:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                        ))),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: GridView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      NeverScrollableScrollPhysics(),
                                                  itemCount: snapshot
                                                          .data![index]
                                                          .savedCheatImages
                                                          .split(',,,')
                                                          .length -
                                                      1,
                                                  itemBuilder: (context, i) {
                                                    return Container(
                                                      width: width / 2,
                                                      height: height / 2,
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                                    .scaffoldBackgroundColor ==
                                                                Colors.white
                                                            ? Colors.grey[300]
                                                            : Color(0xFF121212),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        image: !snapshot
                                                                .data![index]
                                                                .savedCheatImages
                                                                .startsWith(
                                                                    "txt/md:::")
                                                            ? DecorationImage(
                                                                image: MemoryImage(
                                                                    base64Decode(snapshot
                                                                        .data![
                                                                            index]
                                                                        .savedCheatImages
                                                                        .split(
                                                                            ',,,')[i])),
                                                                fit: BoxFit.cover)
                                                            : null,
                                                      ),
                                                      child: Visibility(
                                                        visible: snapshot
                                                            .data![index]
                                                            .savedCheatImages
                                                            .startsWith(
                                                                "txt/md:::"),
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: MarkdownBody(
                                                                onTapLink: (text,
                                                                    href,
                                                                    title) async {
                                                                  await launchUrl(
                                                                      Uri.parse(
                                                                          href!));
                                                                },
                                                                data: snapshot
                                                                    .data![
                                                                        index]
                                                                    .savedCheatImages
                                                                    .substring(
                                                                        9,
                                                                        snapshot.data![index].savedCheatImages.length -
                                                                            3),
                                                                selectable:
                                                                    true,
                                                                styleSheet:
                                                                    MarkdownStyleSheet(
                                                                  p: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        18,
                                                                  ),
                                                                  blockquote:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        18,
                                                                  ),
                                                                  h1: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        26,
                                                                  ),
                                                                  h2: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        25,
                                                                  ),
                                                                  h3: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        24,
                                                                  ),
                                                                  h4: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        23,
                                                                  ),
                                                                  h5: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        22,
                                                                  ),
                                                                  h6: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        21,
                                                                  ),
                                                                  em: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        20,
                                                                  ),
                                                                  strong:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        20,
                                                                  ),
                                                                  code:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                    fontSize:
                                                                        20,
                                                                  ),
                                                                  codeblockDecoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                  ),
                                                                  codeblockPadding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                )),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: snapshot
                                                                .data![index]
                                                                .savedCheatImages
                                                                .split(',,,')
                                                                .length <=
                                                            2
                                                        ? 1
                                                        : 2,
                                                    crossAxisSpacing: 8,
                                                    mainAxisSpacing: 8,
                                                  ),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      showDialog(
                                                          context: context,
                                                          builder:
                                                              (context) =>
                                                                  AlertDialog(
                                                                    title: Text(
                                                                      "Biztos?",
                                                                      style: TextStyle(
                                                                          color: Theme.of(context)
                                                                              .primaryColor,
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    ),
                                                                    content:
                                                                        Text(
                                                                      "Biztosan ki szeretnéd törölni ezt a puskát? \n\n A művelet nem vonható vissza!",
                                                                      style:
                                                                          TextStyle(
                                                                        color: Theme.of(context)
                                                                            .primaryColor,
                                                                      ),
                                                                    ),
                                                                    backgroundColor:
                                                                        Theme.of(context)
                                                                            .scaffoldBackgroundColor,
                                                                    surfaceTintColor:
                                                                        Theme.of(context)
                                                                            .scaffoldBackgroundColor,
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              Navigator.pop(context);
                                                                            });
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            "Nem",
                                                                            style:
                                                                                TextStyle(color: Theme.of(context).primaryColor),
                                                                          )),
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              CheatsDBhelper.instance.delete(snapshot.data![index].id!);
                                                                              Navigator.pop(context);
                                                                              Navigator.pushReplacementNamed(context, '/homepage', arguments: {
                                                                                "initPage": 1
                                                                              });
                                                                            });
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            "Igen",
                                                                            style:
                                                                                TextStyle(color: Colors.redAccent),
                                                                          ))
                                                                    ],
                                                                  ));
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.all(8),
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.redAccent,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.delete_rounded,
                                                        color: Theme.of(context)
                                                                    .scaffoldBackgroundColor ==
                                                                Colors.white
                                                            ? Colors.grey[200]
                                                            : Colors.grey[900],
                                                        size: 32,
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (!snapshot
                                                            .data![index]
                                                            .savedCheatImages
                                                            .startsWith(
                                                                "txt/md:::")) {
                                                          Navigator.pushNamed(
                                                              context, '/load',
                                                              arguments: {
                                                                "data": snapshot
                                                                    .data![
                                                                        index]
                                                                    .savedCheatImages
                                                              });
                                                        } else {
                                                          Navigator.pushNamed(
                                                              context,
                                                              '/loadText',
                                                              arguments: {
                                                                "data": snapshot
                                                                    .data![
                                                                        index]
                                                                    .savedCheatImages
                                                                    .substring(
                                                                        9,
                                                                        snapshot.data![index].savedCheatImages.length -
                                                                            3)
                                                              });
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.all(8),
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(25),
                                                      ),
                                                      child: Text("Használni",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16)),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      setState(() {
                                                        showShare = true;
                                                      });
                                                      debugPrint(
                                                          "upload started");
                                                      if (!snapshot.data![index]
                                                          .savedCheatImages
                                                          .startsWith(
                                                              "txt/md:::")) {
                                                        List splitted = snapshot
                                                            .data![index]
                                                            .savedCheatImages
                                                            .split(',,,');
                                                        debugPrint("original:" +
                                                            splitted
                                                                .toString());
                                                        splitted.removeLast();

                                                        for (int i = 0;
                                                            i < splitted.length;
                                                            i++) {
                                                          await saveBase64ToFile(
                                                              splitted[i], i);
                                                        }
                                                      } else {
                                                        List splitted = snapshot
                                                            .data![index]
                                                            .savedCheatImages
                                                            .split(',,,');

                                                        debugPrint("original:" +
                                                            splitted[0]
                                                                .toString());

                                                        await saveBase64ToFile(
                                                            splitted[0], 0);
                                                      }

                                                      debugPrint(
                                                          "upload finished");
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.all(8),
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                                    .scaffoldBackgroundColor ==
                                                                Colors.white
                                                            ? Colors.black
                                                            : Colors.white,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.share_rounded,
                                                        color: Theme.of(context)
                                                                    .scaffoldBackgroundColor ==
                                                                Colors.white
                                                            ? Colors.grey[200]
                                                            : Colors.grey[900],
                                                        size: 32,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Color(0xFF70d6ff),
                                                      Color(0xFFff70a6),
                                                      Color(0xFFff9770),
                                                      Color.fromARGB(
                                                          255, 255, 189, 22),
                                                    ]),
                                              ),
                                              child: Icon(Icons.search_rounded,
                                                  size: 100,
                                                  color: Theme.of(context)
                                                      .scaffoldBackgroundColor),
                                            ),
                                            Text(
                                              '\nNincsen elmentett puskád\n',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: textColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 32),
                                            ),
                                            Text(
                                              '\nHozz létre egy új puskát! A rendszer automatikusan elmenti azt.\n',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  color: textColor,
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 22),
                                            ),
                                          ],
                                        );
                                      }
                                    },
                                  );
                                } else {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Color(0xFF70d6ff),
                                                Color(0xFFff70a6),
                                                Color(0xFFff9770),
                                                Color.fromARGB(
                                                    255, 255, 189, 22),
                                              ]),
                                        ),
                                        child: Icon(Icons.search_rounded,
                                            size: 100,
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor),
                                      ),
                                      Text(
                                        '\nNincsen elmentett puskád\n',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 32),
                                      ),
                                      Text(
                                        '\nHozz létre egy új puskát! A rendszer automatikusan elmenti azt.\n',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: textColor,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 22),
                                      ),
                                    ],
                                  );
                                }
                              } else if (snapshot.hasError) {
                                return Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      "HIBA: Az imént elmentett képek egyike valószínűleg sérült, vagy túl nagy felbontású!",
                                      style: TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 26),
                                      textAlign: TextAlign.center,
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Theme.of(context)
                                                    .scaffoldBackgroundColor ==
                                                Colors.white
                                            ? Colors.grey[200]
                                            : Colors.grey[900],
                                        onPrimary: Colors.white,
                                      ),
                                      onPressed: () async {
                                        showDialog(
                                            context: context,
                                            builder: (context) => AlertDialog(
                                                  title: Text(
                                                    "Figyelem!",
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .primaryColor,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  content: Text(
                                                    "Ez a vissza nem vonható művelet törölni fogja az ÖSSZES elmentett puskádat! \n\nBiztosan folytatod?",
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    ),
                                                  ),
                                                  backgroundColor: Theme.of(
                                                          context)
                                                      .scaffoldBackgroundColor,
                                                  surfaceTintColor: Theme.of(
                                                          context)
                                                      .scaffoldBackgroundColor,
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            Navigator.pop(
                                                                context);
                                                          });
                                                        },
                                                        child: Text(
                                                          "Nem",
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor),
                                                        )),
                                                    TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            CheatsDBhelper
                                                                .instance
                                                                .deleteAll();
                                                            Navigator
                                                                .pushReplacementNamed(
                                                                    context,
                                                                    '/homepage');
                                                          });
                                                        },
                                                        child: Text(
                                                          "Igen",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .redAccent),
                                                        ))
                                                  ],
                                                ));
                                      },
                                      child: Text('Adatbázis törlése'),
                                    ),
                                  ],
                                );
                              } else {
                                return Center(
                                    child: CircularProgressIndicator(
                                  color: Theme.of(context).primaryColor,
                                ));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                QRCodePanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QRCodePanel extends StatefulWidget {
  const QRCodePanel({super.key});

  @override
  State<QRCodePanel> createState() => _QRCodePanelState();
}

class _QRCodePanelState extends State<QRCodePanel> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: showShare,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: MediaQuery.of(context).size.width / 1.25,
          height: MediaQuery.of(context).size.height / 1.5,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  "Megosztás",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 32),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: url != ""
                      ? QRCode(data: url.toString())
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.grey.shade400,
                                  ],
                                ),
                              ),
                              child: Icon(Icons.upload_rounded,
                                  size: 100,
                                  color: Theme.of(context)
                                      .scaffoldBackgroundColor),
                            ),
                            SizedBox(height: 32),
                            Text(
                              "Feltöltés",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      showShare = false;

                      WebsocketServer().stop(55444);
                    });
                  },
                  child: Text(url != "" ? 'Kész' : 'Mégse'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
