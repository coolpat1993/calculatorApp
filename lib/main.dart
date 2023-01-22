import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const Calculator());
}

class Calculator extends StatelessWidget {
  const Calculator({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SimpleCalculator(),
    );
  }
}

class SimpleCalculator extends StatefulWidget {
  const SimpleCalculator({super.key});

  @override
  State<SimpleCalculator> createState() => _SimpleCalculatorState();
}

class _SimpleCalculatorState extends State<SimpleCalculator> {
  String equation = "0";
  String result = "0";
  String expression = "";
  double equationFontSize = 38.0;
  double resultFontSize = 48.0;
  static const List<String> excludedChars = ['×', '÷', '.', '-', '+'];
  List colorScheme = [
    Colors.black54,
    Colors.white,
    Colors.black87,
    Color.fromARGB(248, 38, 38, 38),
    Color.fromARGB(255, 19, 25, 83),
  ];

/*
List<Map<String, dynamic>> colorScheme = [
    {
      "primaryColor": Colors.black54,
      "secondaryColor": Colors.white,
      "textColor": Colors.black87,
      "backgroundColor": Color.fromARGB(248, 38, 38, 38),
      "buttonColor": Color.fromARGB(255, 19, 25, 83)
    },
    {
      "primaryColor": Colors.white,
      "secondaryColor": Colors.black87,
      "textColor": Colors.white,
      "backgroundColor": Color.fromARGB(248, 38, 38, 38),
      "buttonColor": Color.fromARGB(255, 19, 25, 83)
    },
  ];
  */

  bool newEquasion = false;
  bool _isOn = true;

  final Parser _parser = Parser();
  final ContextModel _contextModel = ContextModel();

  toggle() {
    setState(() => _isOn = !_isOn);
    print(_isOn);
  }

  buttonPressed(String buttonText) {
    setState(() {
      print(newEquasion);
      if (buttonText == "C") {
        newEquasion = false;
        equation = "0";
        result = "0";
        equationFontSize = 38.0;
        resultFontSize = 48.0;
      } else if (buttonText == "⌫") {
        newEquasion = false;
        equationFontSize = 48.0;
        resultFontSize = 38.0;
        equation = equation.substring(0, equation.length - 1);
        if (equation == "") {
          equation = "0";
        }
      } else if (buttonText == "=") {
        newEquasion = true;
        equationFontSize = 38.0;
        resultFontSize = 48.0;

        StringBuffer tempResult = StringBuffer();
        for (int i = 0; i < equation.length - 1; i++) {
          if (excludedChars.contains(equation[i]) &&
              equation[i] == equation[i + 1]) {
            tempResult.write(equation[i]);
            i++;
          } else {
            tempResult.write(equation[i]);
          }
        }
        tempResult.write(equation[equation.length - 1]);
        equation = tempResult.toString();

        if (excludedChars.contains(equation[equation.length - 1])) {
          equation = equation.substring(0, equation.length - 1);
        }
        expression = equation;
        expression = expression.replaceAll('×', "*");
        expression = expression.replaceAll('÷', "/");

        try {
          Expression exp = _parser.parse(expression);
          result = '${exp.evaluate(EvaluationType.REAL, _contextModel)}';

          if (result[result.length - 1] == '0' &&
              result[result.length - 2] == '.') {
            result = result.substring(0, result.length - 2);
          }
        } catch (e) {
          result = "Error";
        }
      } else {
        equationFontSize = 48.0;
        resultFontSize = 38.0;
        if (equation == "0") {
          equation = buttonText;
          // logic for handling adding more to completed equation
        } else if ((newEquasion == true &&
            result != 'Error' &&
            !excludedChars.contains(buttonText))) {
          equation = '';
          equation = equation + buttonText;
          newEquasion = false;
        } else if (newEquasion == true && result != 'Error') {
          equation = result;
          newEquasion = false;
          equation = equation + buttonText;
        } else {
          equation = equation + buttonText;
        }
      }
    });
  }

  Widget buildButton(
      String buttonText, double buttonHeight, Color buttonColor) {
    return Container(
        height: MediaQuery.of(context).size.height * 0.1 * buttonHeight,
        color: buttonColor,
        child: TextButton(
          style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0.0),
                  side: BorderSide(
                      color: _isOn ? colorScheme[1] : colorScheme[3],
                      width: 1,
                      style: BorderStyle.solid)),
              padding: EdgeInsets.all(16.0)),
          onPressed: () => buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: TextStyle(
                fontSize: 30.0,
                fontWeight: FontWeight.normal,
                color: Colors.white),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: _isOn ? colorScheme[1] : colorScheme[3],
        appBar: AppBar(
          title: Text(
            'Simple Calculator',
          ),
          actions: <Widget>[
            IconButton(
              icon: _isOn
                  ? Icon(Icons.bedtime_rounded)
                  : Icon(Icons.bedtime_outlined),
              tooltip: 'Show Snackbar',
              onPressed: () => toggle(),
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: Text(
                  equation,
                  style: TextStyle(
                      fontSize: equationFontSize,
                      color: _isOn ? Colors.black : Colors.white),
                )),
            Container(
                alignment: Alignment.centerRight,
                padding: EdgeInsets.fromLTRB(10, 30, 10, 0),
                child: Text(
                  result,
                  style: TextStyle(
                      fontSize: resultFontSize,
                      color: _isOn ? Colors.black : Colors.white),
                )),
            Expanded(child: Divider()),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width * .75,
                  child: Table(
                    children: [
                      TableRow(children: [
                        buildButton('C', 1, Colors.redAccent),
                        buildButton('⌫', 1, Colors.blue),
                        buildButton('÷', 1, Colors.blue),
                      ]),
                      TableRow(children: [
                        buildButton('7', 1, Colors.black54),
                        buildButton('8', 1, Colors.black54),
                        buildButton('9', 1, Colors.black54),
                      ]),
                      TableRow(children: [
                        buildButton('4', 1, Colors.black54),
                        buildButton('5', 1, Colors.black54),
                        buildButton('6', 1, Colors.black54),
                      ]),
                      TableRow(children: [
                        buildButton('1', 1, Colors.black54),
                        buildButton('2', 1, Colors.black54),
                        buildButton('3', 1, Colors.black54),
                      ]),
                      TableRow(children: [
                        buildButton('.', 1, Colors.black54),
                        buildButton('0', 1, Colors.black54),
                        buildButton('00', 1, Colors.black54),
                      ]),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.25,
                  child: Table(
                    children: [
                      TableRow(children: [
                        buildButton('×', 1, Colors.blue),
                      ]),
                      TableRow(children: [
                        buildButton('-', 1, Colors.blue),
                      ]),
                      TableRow(children: [
                        buildButton('+', 1, Colors.blue),
                      ]),
                      TableRow(children: [
                        buildButton('=', 2, Colors.redAccent),
                      ]),
                    ],
                  ),
                )
              ],
            ),
          ],
        ));
  }
}
