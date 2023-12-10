import 'dart:async';

import 'package:flutter/material.dart';
import 'package:puskazz_app/Widgets/GrdientButton.dart';

class PremiumShowcaseScreen extends StatefulWidget {
  const PremiumShowcaseScreen({super.key});

  @override
  State<PremiumShowcaseScreen> createState() => _PremiumShowcaseScreenState();
}

class _PremiumShowcaseScreenState extends State<PremiumShowcaseScreen> {
  PageController pageController = PageController(initialPage: 0);
  Color highlightColor = Colors.redAccent;
  double iconSize = 40;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (highlightColor == Colors.redAccent) {
        setState(() {
          highlightColor = Colors.white;
          iconSize = 25;
        });
      } else {
        setState(() {
          highlightColor = Colors.redAccent;
          iconSize = 40;
        });
      }
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
                      GradientText("Prémium feloldva\n",
                          style: TextStyle(
                              fontWeight: FontWeight.w900, fontSize: width / 6),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF70d6ff),
                                Color(0xFFff70a6),
                                Color(0xFFff9770),
                                Color.fromARGB(255, 255, 189, 22),
                              ])),
                      Text(
                        'Prémium fehasználó lettél, így hozzáférhetsz az összes Prémium funkcióhoz!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                    ],
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
                            "Jeee!",
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
                        'Elmenthető puskák\n',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: width / 8,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                    ],
                  ),
                  BottomNavigationBar(
                    type: BottomNavigationBarType.fixed,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    selectedItemColor: Theme.of(context).primaryColor,
                    unselectedItemColor: Colors.grey,
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home),
                        label: 'Kezdőlap',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.save_outlined,
                          color: highlightColor,
                          size: iconSize,
                        ),
                        label: 'Elmentettek',
                      ),
                    ],
                    onTap: (index) {
                      setState(() {});
                    },
                  ),
                  Text(
                    'Az újonan nyitott puskáidat a rendszer automatikusan elmenti.\n\nA mentett puskákat át tudod nevezni és akár át is tudod küldeni bármilyen Puskázz App felhasználónak, továbbá keresni is tudsz köztük.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor),
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
                            "Értem",
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
                        'Már meg tudod változtatni az app ikonját a beállításokban\n ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor),
                      ),
                      AnimatedRotation(
                        duration: Duration(milliseconds: 900),
                        turns: 360,
                        child: IconButton(
                            icon: Icon(
                              Icons.settings,
                              color: Theme.of(context).primaryColor,
                              size: 50,
                            ),
                            onPressed: () {}),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () async {
                      Navigator.pushNamedAndRemoveUntil(
                          context, "/homepage", (route) => false);
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
          ],
        ));
  }
}
