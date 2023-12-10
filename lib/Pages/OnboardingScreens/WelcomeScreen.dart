import 'dart:async';

import 'package:flutter/material.dart';
import 'package:puskazz_app/Pages/LoadCheat/TextBasedPage.dart';
import 'package:puskazz_app/Widgets/GrdientButton.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  PageController _pageController = PageController(initialPage: 0);
  late AnimationController _controller;
  late Animation<double> _animation;
  bool accepted = false;
  Color _startColor = Colors.redAccent.withOpacity(0.5);
  Color _endColor = Colors.red;
  bool _isChanged = false;

  void _changeColor() {
    Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        _isChanged = !_isChanged;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    Future.delayed(Duration(milliseconds: 500), () {
      _controller.forward();
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
      });
      _changeColor();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    Color bgColor = Theme.of(context).scaffoldBackgroundColor;
    Color textColor = Theme.of(context).primaryColor;

    return Scaffold(
        backgroundColor: bgColor,
        body: PageView(
          controller: pageController,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotationTransition(
                        turns:
                            Tween(begin: 0.0, end: 0.125).animate(_controller!),
                        child: Text(
                          "👋",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: width * 0.2,
                              fontWeight: FontWeight.bold,
                              color: textColor),
                        ),
                      ),
                      Text(
                        'Üdvözlünk a Puskázz Appban!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                    ],
                  ),
                  Text(
                    'A puskázz app az egyetlen olyan alkalmazás, amivel egyszerűen és biztonságosan tudsz puskázni!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                  InkWell(
                    onTap: () {
                      pageController.animateToPage(1,
                          duration: Duration(milliseconds: 250),
                          curve: Curves.easeIn);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.25,
                      height: MediaQuery.of(context).size.height / 12,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor ==
                                  Colors.black
                              ? Color(0xFF343434)
                              : Color(0xFfdedede),
                          borderRadius: BorderRadius.circular(50)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GradientText(
                            "Lássuk!",
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF70d6ff),
                                  Color(0xFFff70a6),
                                  Color(0xFFff9770),
                                  Color.fromARGB(255, 255, 189, 22),
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Az alkalmazáson belül képeket tudsz betölteni, vagy akár szöveges puskát is írhatsz!\n',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                      Text(
                        '🏞️  📝',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: () {},
                          child: Container(
                            width: width / 2.5,
                            height: width / 2.5,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).scaffoldBackgroundColor ==
                                          Colors.white
                                      ? Colors.grey[200]
                                      : Colors.grey[900],
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image,
                                    color: Theme.of(context).primaryColor,
                                    size:
                                        width >= 1200 ? width / 10 : width / 8,
                                  ),
                                  Text('\nKép betöltése',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(25),
                          onTap: () {},
                          child: Container(
                            width: width / 2.5,
                            height: width / 2.5,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).scaffoldBackgroundColor ==
                                          Colors.white
                                      ? Colors.grey[200]
                                      : Colors.grey[900],
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.text_fields,
                                    color: Theme.of(context).primaryColor,
                                    size:
                                        width >= 1200 ? width / 10 : width / 8,
                                  ),
                                  Text('\nSzöveges puska\nírása',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      pageController.animateToPage(2,
                          duration: Duration(milliseconds: 250),
                          curve: Curves.easeIn);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.25,
                      height: MediaQuery.of(context).size.height / 12,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor ==
                                  Colors.black
                              ? Color(0xFF343434)
                              : Color(0xFfdedede),
                          borderRadius: BorderRadius.circular(50)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GradientText(
                            "Tovább",
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF70d6ff),
                                  Color(0xFFff70a6),
                                  Color(0xFFff9770),
                                  Color.fromARGB(255, 255, 189, 22),
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'A Puskázz App fő funkciója:\n\nA puskát csak akkor látod ha nyomva tartod a kijelzőt.\n\nHa elengeded a kijelzőt, eltűnik a puskád, a telefon "kikapcsoltnak" látszik!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () async {
                      pageController.animateToPage(3,
                          duration: Duration(milliseconds: 250),
                          curve: Curves.easeIn);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.25,
                      height: MediaQuery.of(context).size.height / 12,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor ==
                                  Colors.black
                              ? Color(0xFF343434)
                              : Color(0xFfdedede),
                          borderRadius: BorderRadius.circular(50)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GradientText(
                            "Szuper",
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF70d6ff),
                                  Color(0xFFff70a6),
                                  Color(0xFFff9770),
                                  Color.fromARGB(255, 255, 189, 22),
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'A Puskázz Appban még sok más funkció is van\n\nPéldául:\n',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 2.5,
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor ==
                                  Colors.white
                              ? Colors.grey[200]
                              : Colors.grey[900],
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GradientText("Továbbküldhető puskák",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF70d6ff),
                                      Color(0xFFff70a6),
                                      Color(0xFFff9770),
                                      Color.fromARGB(255, 255, 189, 22),
                                    ])),
                            GradientText("Elmenthető puskák",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF70d6ff),
                                      Color(0xFFff70a6),
                                      Color(0xFFff9770),
                                      Color.fromARGB(255, 255, 189, 22),
                                    ])),
                            GradientText("Visszakereshető puskák",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF70d6ff),
                                      Color(0xFFff70a6),
                                      Color(0xFFff9770),
                                      Color.fromARGB(255, 255, 189, 22),
                                    ])),
                            GradientText("Átnevezhető puskák",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF70d6ff),
                                      Color(0xFFff70a6),
                                      Color(0xFFff9770),
                                      Color.fromARGB(255, 255, 189, 22),
                                    ])),
                            GradientText("Megváltoztatható app ikon",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF70d6ff),
                                      Color(0xFFff70a6),
                                      Color(0xFFff9770),
                                      Color.fromARGB(255, 255, 189, 22),
                                    ])),
                          ],
                        )),
                      )
                    ],
                  ),
                  InkWell(
                    onTap: () async {
                      pageController.animateToPage(4,
                          duration: Duration(milliseconds: 250),
                          curve: Curves.easeIn);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 1.25,
                      height: MediaQuery.of(context).size.height / 12,
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor ==
                                  Colors.black
                              ? Color(0xFF343434)
                              : Color(0xFfdedede),
                          borderRadius: BorderRadius.circular(50)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GradientText(
                            "Tovább",
                            style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF70d6ff),
                                  Color(0xFFff70a6),
                                  Color(0xFFff9770),
                                  Color.fromARGB(255, 255, 189, 22),
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(),
                  Text(
                    'A Puskázz App használata előtt meg kell ismerned és el kell fogadnod az',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.25,
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor ==
                                Colors.black
                            ? Color(0xFF343434)
                            : Color(0xFfdedede),
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
                            color: textColor),
                      ),
                    ),
                  ),
                  Text(
                    'és az',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: textColor),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.25,
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor ==
                                Colors.black
                            ? Color(0xFF343434)
                            : Color(0xFfdedede),
                        borderRadius: BorderRadius.circular(50)),
                    child: TextButton(
                      onPressed: () {
                        launchUrl(Uri.parse(
                            "https://szeligbalazs.github.io/SzeligBalazs/puskazz-app-eula.html"));
                      },
                      child: Text(
                        'EULA-t',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Elfogadom',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 250),
                        width: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: _isChanged ? _endColor : _startColor,
                        ),
                        child: Center(
                          child: Switch(
                            value: accepted,
                            onChanged: (value) async {
                              setState(() {
                                accepted = value;
                              });
                            },
                            activeTrackColor:
                                Theme.of(context).scaffoldBackgroundColor ==
                                        Colors.white
                                    ? Colors.grey[100]
                                    : Colors.grey[900],
                            activeColor: Colors.lightGreen,
                            inactiveThumbColor: Theme.of(context).primaryColor,
                            inactiveTrackColor:
                                Theme.of(context).scaffoldBackgroundColor ==
                                        Colors.white
                                    ? Colors.grey[100]
                                    : Colors.grey[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () async {
                      if (accepted == true) {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('isSettedUp', true);
                        await prefs.setBool(
                          'enableAnalytics',
                          true,
                        );
                        Navigator.pushReplacementNamed(context, '/homepage');
                      }
                    },
                    child: accepted == true
                        ? Container(
                            width: MediaQuery.of(context).size.width / 1.25,
                            height: MediaQuery.of(context).size.height / 12,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor ==
                                            Colors.black
                                        ? Color(0xFF343434)
                                        : Color(0xFfdedede),
                                borderRadius: BorderRadius.circular(50)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GradientText(
                                  "Kezdjük!",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF70d6ff),
                                        Color(0xFFff70a6),
                                        Color(0xFFff9770),
                                        Color.fromARGB(255, 255, 189, 22),
                                      ]),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            width: MediaQuery.of(context).size.width / 1.25,
                            height: MediaQuery.of(context).size.height / 12,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor ==
                                            Colors.black
                                        ? Color(0xFF343434)
                                        : Color(0xFfdedede),
                                borderRadius: BorderRadius.circular(50)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GradientText(
                                  "Kezdjük!",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.grey,
                                        Colors.grey.shade400,
                                        Colors.grey.shade600,
                                      ]),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
