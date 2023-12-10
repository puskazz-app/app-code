import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:puskazz_app/Pages/Etc/NetworkConnectivityPage.dart';

class CalculatorHomePage extends StatefulWidget {
  const CalculatorHomePage({super.key});

  @override
  State<CalculatorHomePage> createState() => _CalculatorHomePageState();
}

class _CalculatorHomePageState extends State<CalculatorHomePage> {
  String equation = "0";
  String result = "0";
  String expression = "";
  double equationFontSize = 38.0;
  double resultFontSize = 48.0;
  bool loaded = false;

  buttonPressed(String buttonText) {
    // used to check if the result contains a decimal
    String doesContainDecimal(dynamic result) {
      if (result.toString().contains('.')) {
        List<String> splitDecimal = result.toString().split('.');
        if (!(int.parse(splitDecimal[1]) > 0)) {
          return result = splitDecimal[0].toString();
        }
      }
      return result;
    }

    setState(() {
      if (buttonText == "AC") {
        equation = "0";
        result = "0";
      } else if (buttonText == "⌫") {
        equation = equation.substring(0, equation.length - 1);
        if (equation == "") {
          equation = "0";
        }
      } else if (buttonText == "+/-") {
        if (equation[0] != '-') {
          equation = '-$equation';
        } else {
          equation = equation.substring(1);
        }
      } else if (buttonText == "=") {
        expression = equation;
        expression = expression.replaceAll('×', '*');
        expression = expression.replaceAll('÷', '/');
        expression = expression.replaceAll('%', '%');

        try {
          Parser p = Parser();
          Expression exp = p.parse(expression);

          ContextModel cm = ContextModel();
          result = '${exp.evaluate(EvaluationType.REAL, cm)}';
          if (expression.contains('%')) {
            result = doesContainDecimal(result);
          }
        } catch (e) {
          result = "Error";
        }
      } else {
        if (equation == "0") {
          equation = buttonText;
        } else {
          equation = equation + buttonText;
        }
      }
      result = doesContainDecimal(result);
    });
  }

  @override
  void initState() {
    getMessage();
    super.initState();
  }

  void getMessage() async {
    final url = Uri.parse(
        'https://szeligbalazs.github.io/shotgunapp-messages/status.html');
    final response = await http.get(url);
    dom.Document document = dom.Document.html(response.body);

    final text =
        document.querySelectorAll('p').map((e) => e.innerHtml.trim()).toList();
    for (var i = 0; i < text.length; i++) {
      if (text[i].contains('calculator')) {
        setState(() {
          loaded = true;
        });
        debugPrint(text[i]);
      } else {
        setState(() {
          loaded = false;
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      NetworkConnectivity(destination: 'welcome')));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black54,
        body: loaded == true
            ? SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(result,
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 80))),
                                const Icon(Icons.more_vert,
                                    color: Colors.orange, size: 30),
                                const SizedBox(width: 20),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text(equation,
                                      style: const TextStyle(
                                        fontSize: 40,
                                        color: Colors.white38,
                                      )),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.backspace_outlined,
                                      color: Colors.orange, size: 30),
                                  onPressed: () {
                                    buttonPressed("⌫");
                                  },
                                ),
                                const SizedBox(width: 20),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        calcButton(
                            'AC', Colors.white10, () => buttonPressed('AC')),
                        calcButton(
                            '%', Colors.white10, () => buttonPressed('%')),
                        calcButton(
                            '÷', Colors.white10, () => buttonPressed('÷')),
                        calcButton(
                            "×", Colors.white10, () => buttonPressed('×')),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        calcButton(
                            '7', Colors.white24, () => buttonPressed('7')),
                        calcButton(
                            '8', Colors.white24, () => buttonPressed('8')),
                        calcButton(
                            '9', Colors.white24, () => buttonPressed('9')),
                        calcButton(
                            '-', Colors.white10, () => buttonPressed('-')),
                      ],
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        calcButton(
                            '4', Colors.white24, () => buttonPressed('4')),
                        calcButton(
                            '5', Colors.white24, () => buttonPressed('5')),
                        calcButton(
                            '6', Colors.white24, () => buttonPressed('6')),
                        calcButton(
                            '+', Colors.white10, () => buttonPressed('+')),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // calculator number buttons

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
//mainAxisAlignment: MainAxisAlignment.spaceAround
                          children: [
                            Row(
                              children: [
                                calcButton('1', Colors.white24,
                                    () => buttonPressed('1')),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.04),
                                calcButton('2', Colors.white24,
                                    () => buttonPressed('2')),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.04),
                                calcButton('3', Colors.white24,
                                    () => buttonPressed('3')),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                calcButton('+/-', Colors.white24,
                                    () => buttonPressed('+/-')),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.04),
                                calcButton('0', Colors.white24,
                                    () => buttonPressed('0')),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.04),
                                calcButton('.', Colors.white24,
                                    () => buttonPressed('.')),
                              ],
                            ),
                          ],
                        ),
                        calcButton(
                            '=', Colors.orange, () => buttonPressed('=')),
                      ],
                    )
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              )));
  }
}

Widget calcButton(
    String buttonText, Color buttonColor, void Function()? buttonPressed) {
  return Container(
    width: 85,
    height: buttonText == '=' ? 160 : 80,
    padding: const EdgeInsets.all(0),
    child: ElevatedButton(
      onPressed: buttonPressed,
      style: ElevatedButton.styleFrom(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          backgroundColor: buttonColor),
      child: Center(
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
    ),
  );
}
