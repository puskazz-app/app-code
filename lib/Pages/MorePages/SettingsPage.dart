import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dynamic_icon_flutter/dynamic_icon_flutter.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:flutter/services.dart';
import 'package:puskazz_app/Utils/EncriptionManager.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool showContent = false;
  bool isInitalizedByDev = false;
  bool usePanicButton = true;
  bool usePanicButtonShake = false;
  bool useAnalytics = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    final prefs = await SharedPreferences.getInstance();
    bool usePanicButtonTemp = await prefs.getBool('usePanicButton') ?? true;
    bool usePanicButtonShakeTemp =
        await prefs.getBool('usePanicButtonShake') ?? false;
    bool useAnalyticsTemp = await prefs.getBool('enableAnalytics') ?? true;

    setState(() {
      usePanicButton = usePanicButtonTemp;
      usePanicButtonShake = usePanicButtonShakeTemp;
      useAnalytics = useAnalyticsTemp;
      showContent = true;
    });
  }

  void setIcon(int index) async {
    List<String> list = [];
    index -= 1;
    if (Platform.isAndroid) {
      setState(() {
        list = [
          'webbrowser_icon',
          'lightbulb_icon',
          'calculator_icon',
          'password_manager_icon',
          'notes_app',
          'gallery_icon',
          'MainActivity'
        ];
      });
      try {
        await DynamicIconFlutter.setIcon(
            icon: list[index], listAvailableIcon: list);
        await DynamicIconFlutter.setAlternateIconName(list[index]);
        print("App icon change successful");
        return;
      } on PlatformException catch (e) {
        if (await DynamicIconFlutter.supportsAlternateIcons) {
          return;
        } else {
          print("Failed to change app icon");
        }
      }
    }
    if (Platform.isIOS) {
      setState(() {
        list = [
          'Webbrowser',
          'Lightbulb',
          'Calculator',
          'PasswordManager',
          'NotesApp',
          'Gallery',
          'default'
        ];
      });

      try {
        await FlutterDynamicIcon.setAlternateIconName(
            list[index] == 'default' ? null : list[index]);
        debugPrint("App icon change successful");
        return;
      } on PlatformException catch (e) {
        if (await FlutterDynamicIcon.supportsAlternateIcons) {
          return;
        } else {
          debugPrint("Failed to change app icon");
        }
      }
    }

    print(list[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Beállítások'),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            foregroundColor: Theme.of(context).primaryColor),
        body: showContent == true
            ? SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(height: 25),
                      Text(
                        "Ikon megváltoztatása",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.width,
                                  margin: EdgeInsets.all(25),
                                  padding: EdgeInsets.all(25),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.bottomRight,
                                        end: Alignment.topLeft,
                                        colors: [
                                          Color(0xFF70d6ff),
                                          Color(0xFFff70a6),
                                          Color(0xFFff9770),
                                          Color.fromARGB(255, 255, 189, 22),
                                        ]),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: MediaQuery.of(context).size.width,
                                    child: GridView(
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 3,
                                              crossAxisSpacing: 25,
                                              mainAxisSpacing: 25),
                                      children: [
                                        InkWell(
                                          onTap: () async {},
                                          child: Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image(
                                                  image: AssetImage(
                                                      'assets/fake_icons/webbrowser_icon.png')),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {},
                                          child: Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image(
                                                  image: AssetImage(
                                                      'assets/fake_icons/lightbulb_icon.png')),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {},
                                          child: Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image(
                                                  image: AssetImage(
                                                      'assets/fake_icons/calculator_icon.png')),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {},
                                          child: Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image(
                                                image: AssetImage(
                                                  'assets/fake_icons/password_manager_icon.png',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {},
                                          child: Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image(
                                                image: AssetImage(
                                                  'assets/fake_icons/notes_app.png',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {},
                                          child: Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              child: Image(
                                                image: AssetImage(
                                                  'assets/fake_icons/gallery_icon.png',
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    "Alapértelmezett visszaállítása",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                                Visibility(
                                  visible: Platform.isIOS,
                                  child: Text(
                                    "iOS eszközök esetén sajnos az alkalmazás nevét nem lehet megváltoztatni.\n",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.w200,
                                        fontSize: 18),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor ==
                                    Colors.white
                                ? Colors.grey[200]
                                : Colors.grey[900],
                            borderRadius: BorderRadius.circular(25)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Pánik gomb",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                Switch(
                                  value: usePanicButton,
                                  onChanged: (value) async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool(
                                        'usePanicButton', value);
                                    setState(() {
                                      usePanicButton = value;
                                    });
                                  },
                                  activeTrackColor: Theme.of(context)
                                              .scaffoldBackgroundColor ==
                                          Colors.white
                                      ? Colors.grey[100]
                                      : Colors.black38,
                                  activeColor: Colors.lightGreen,
                                  inactiveThumbColor:
                                      Theme.of(context).primaryColor,
                                  inactiveTrackColor: Theme.of(context)
                                              .scaffoldBackgroundColor ==
                                          Colors.white
                                      ? Colors.grey[100]
                                      : Colors.black38,
                                )
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Pánik gomb rázással",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                Switch(
                                  value: usePanicButtonShake,
                                  onChanged: (value) async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool(
                                        'usePanicButtonShake', value);
                                    setState(() {
                                      usePanicButtonShake = value;
                                    });
                                  },
                                  activeTrackColor: Theme.of(context)
                                              .scaffoldBackgroundColor ==
                                          Colors.white
                                      ? Colors.grey[100]
                                      : Colors.black38,
                                  activeColor: Colors.lightGreen,
                                  inactiveThumbColor:
                                      Theme.of(context).primaryColor,
                                  inactiveTrackColor: Theme.of(context)
                                              .scaffoldBackgroundColor ==
                                          Colors.white
                                      ? Colors.grey[100]
                                      : Colors.black38,
                                )
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Névtelen adatgyűjtés",
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                                Switch(
                                  value: useAnalytics,
                                  onChanged: (value) async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setBool(
                                        'enableAnalytics', value);
                                    setState(() {
                                      useAnalytics = value;
                                    });
                                  },
                                  activeTrackColor: Theme.of(context)
                                              .scaffoldBackgroundColor ==
                                          Colors.white
                                      ? Colors.grey[100]
                                      : Colors.black38,
                                  activeColor: Colors.lightGreen,
                                  inactiveThumbColor:
                                      Theme.of(context).primaryColor,
                                  inactiveTrackColor: Theme.of(context)
                                              .scaffoldBackgroundColor ==
                                          Colors.white
                                      ? Colors.grey[100]
                                      : Colors.black38,
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      TextButton(
                        onPressed: () {
                          ScreenBrightness().resetScreenBrightness();
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color:
                                  Theme.of(context).scaffoldBackgroundColor ==
                                          Colors.white
                                      ? Colors.grey[200]
                                      : Colors.grey[900],
                              borderRadius: BorderRadius.circular(25)),
                          child: Text(
                            "Fényerő visszaállítása",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Egyéb",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 32,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await launchUrl(Uri.parse(
                                        'https://discord.gg/dFc9MDyCxB'));
                                  },
                                  child: Image(
                                      image: Theme.of(context)
                                                  .scaffoldBackgroundColor ==
                                              Colors.white
                                          ? AssetImage(
                                              'assets/logos/discord_light.png')
                                          : AssetImage(
                                              'assets/logos/discord_dark.png'),
                                      width: 50),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await launchUrl(
                                        Uri.parse('https://puskazz.app/'));
                                  },
                                  child: Image(
                                      image: Theme.of(context)
                                                  .scaffoldBackgroundColor ==
                                              Colors.white
                                          ? AssetImage(
                                              'assets/logos/website-dark.svg')
                                          : AssetImage(
                                              'assets/logos/website-light.svg'),
                                      width: 50),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await launchUrl(Uri.parse(
                                        'https://www.tiktok.com/@puskazzapp'));
                                  },
                                  child: Image(
                                      image: Theme.of(context)
                                                  .scaffoldBackgroundColor ==
                                              Colors.white
                                          ? AssetImage(
                                              'assets/logos/tiktok_light.png')
                                          : AssetImage(
                                              'assets/logos/tiktok_dark.png'),
                                      width: 70),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 1.25,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                                .scaffoldBackgroundColor ==
                                            Colors.white
                                        ? Colors.grey[200]
                                        : Colors.grey[900],
                                    borderRadius: BorderRadius.circular(50)),
                                child: TextButton(
                                  onPressed: () {
                                    launchUrl(Uri.parse(
                                        "https://szeligbalazs.github.io/SzeligBalazs/puskazz-app-privacy-policy.html"));
                                  },
                                  child: Text(
                                    'Adatvédelmi irányelveket',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 16,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 1.25,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                                .scaffoldBackgroundColor ==
                                            Colors.white
                                        ? Colors.grey[200]
                                        : Colors.grey[900],
                                    borderRadius: BorderRadius.circular(50)),
                                child: TextButton(
                                  onPressed: () {
                                    launchUrl(Uri.parse(
                                        "https://szeligbalazs.github.io/SzeligBalazs/puskazz-app-eula.html"));
                                  },
                                  child: Text(
                                    'EULA',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 16,
                      ),
                    ],
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              )));
  }
}
