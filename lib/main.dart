import 'dart:io';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:appodeal_flutter/appodeal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController moneyController = TextEditingController();
  TextEditingController nameEditController = TextEditingController();
  TextEditingController moneyEditController = TextEditingController();

  TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  GlobalKey keyButton = GlobalKey();
  GlobalKey keyButton1 = GlobalKey();
  GlobalKey keyButton2 = GlobalKey();
  GlobalKey keyButton3 = GlobalKey();
  GlobalKey keyButton4 = GlobalKey();

  bool watchedTutorial = false;

  String _username = '';
  String _total = '0.00';

  var _data = [];
  int _dataLength = 0;

  File jsonFile;
  Directory dir;
  bool fileExists = false;

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    nameController.dispose();
    moneyController.dispose();
    nameEditController.dispose();
    moneyEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _height =
        MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top;
    final _width = MediaQuery.of(context).size.width;

    return MaterialApp(
      title: 'IOU',
      home: Scaffold(
        body: Center(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.only(bottom: _height * 0.07)),
              Container(
                width: _width * 0.85,
                height: _width * 0.5,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    Padding(padding: EdgeInsets.all(_width * 0.04)),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.only(right: _width * 0.07)),
                        Container(
                          width: _width * 0.15,
                          height: _height * 0.05,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(right: _width * 0.01)),
                        Transform.rotate(
                          angle: 90 * pi / 180,
                          child: Icon(
                            Icons.wifi_rounded,
                            size: 40,
                          ),
                        ),
                        Spacer(),
                        Text(
                          '$_total\$',
                          key: keyButton2,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(left: _width * 0.07)),
                      ],
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.only(right: _width * 0.07)),
                        Container(
                          width: _width * 0.6,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          child: SizedBox(
                            width: _width * 0.6,
                            height: _height * 0.1,
                            child: TextButton(
                              key: keyButton,
                              child: Text(
                                '$_username',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                _changeUsername();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(_width * 0.04)),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(bottom: _height * 0.02)),
              Offstage(
                offstage: watchedTutorial,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: _width * 0.07,
                    right: _width * 0.07,
                    bottom: _height * 0.01,
                  ),
                  child: Container(
                    width: _width * 0.85,
                    height: _height * 0.1,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.green,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        TextButton(
                          key: keyButton4,
                          child: Text(
                            'GSPTeck',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            _watchAd();
                          },
                        ),
                        Spacer(),
                        Container(
                          height: _height * 0.08,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: TextButton(
                            key: keyButton3,
                            child: Text(
                              '0\$',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              _watchAd();
                            },
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: _width * 0.01),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _dataLength,
                  itemBuilder: (BuildContext context, int i) {
                    return Padding(
                      padding: EdgeInsets.only(
                        left: _width * 0.07,
                        right: _width * 0.07,
                        bottom: _height * 0.01,
                      ),
                      child: Container(
                        width: _width * 0.85,
                        height: _height * 0.1,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.green,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            TextButton(
                              child: Text(
                                '${_data[i]["name"]}',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () {
                                int index = i;
                                _editName(index);
                              },
                            ),
                            Spacer(),
                            Container(
                              height: _height * 0.08,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: TextButton(
                                child: Text(
                                  '${_data[i]["money"]}\$',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  int index = i;
                                  _editMoney(index);
                                },
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: _width * 0.01),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          key: keyButton1,
          height: 75,
          decoration: BoxDecoration(color: Colors.green),
          child: TextButton(
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 50,
            ),
            onPressed: () {
              Future.delayed(const Duration(milliseconds: 1), () {
                _addPerson();
              });
            },
          ),
        ),
      ),
    );
  }

  _init() async {
    Appodeal.setAppKeys(
      androidAppKey: 'd44844485ed9327b1faf7321ccb7e12fb4e4773bdaed80a1',
    );
    await Appodeal.initialize(
      hasConsent: true,
      adTypes: [AdType.BANNER, AdType.INTERSTITIAL, AdType.NON_SKIPPABLE],
      testMode: false,
    );
    _watchAd();

    _loadData();
    _loadTotal();
  }

  _watchAd() {
    Appodeal.show(AdType.INTERSTITIAL);
  }

  _loadData() async {
    //load username from username.json
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + 'username.json');
      fileExists = jsonFile.existsSync();
      if (fileExists) {
        this.setState(() {
          var u = json.decode(jsonFile.readAsStringSync());
          _username = u["username"];
        });
      } else {
        this.setState(() {
          _username = 'John Doe';
        });
      }
    });

    //load people from people.json
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + 'people.json');
      fileExists = jsonFile.existsSync();
      if (fileExists && jsonFile.readAsStringSync().isNotEmpty) {
        this.setState(() {
          _data = json.decode(jsonFile.readAsStringSync());
          _dataLength = _data.length;
        });
      }
    });

    //load watchedTutorial value
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + 'tutorial.json');
      fileExists = jsonFile.existsSync();
      if (fileExists && jsonFile.readAsStringSync().isNotEmpty) {
        this.setState(() {
          var w = json.decode(jsonFile.readAsStringSync());
          watchedTutorial = w["watched"];
          print(watchedTutorial);
        });

        if (watchedTutorial == false) {
          _initTargets();
          _showTutorial();
        } else {
          return;
        }
      } else {
        File file = new File(dir.path + "/" + 'tutorial.json');
        file.createSync();
        fileExists = true;
        var content = {"watched": false};
        Map jsonFileContent = {};
        jsonFileContent.addAll(content);
        file.writeAsStringSync(json.encode(jsonFileContent));

        if (watchedTutorial == false) {
          _initTargets();
          _showTutorial();
        } else {
          return;
        }
      }
    });
  }

  _loadTotal() async {
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + 'people.json');
      fileExists = jsonFile.existsSync();
      if (fileExists && jsonFile.readAsStringSync().isNotEmpty) {
        _data = json.decode(jsonFile.readAsStringSync());
        _dataLength = _data.length;
        double t = 0.0;

        this.setState(() {
          for (int i = 0; i < _dataLength; i++) {
            double m = _data[i]["money"];
            t += m;
            _total = t.toStringAsFixed(2);
          }
        });
      }
    });
  }

  _addPerson() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLength: 8,
                decoration: InputDecoration(
                  labelText: 'Name (eg.: John):',
                ),
                controller: nameController,
              ),
              TextField(
                keyboardType: TextInputType.number,
                maxLength: 8,
                decoration: InputDecoration(
                  labelText: 'Money (eg.: 200.00):',
                ),
                controller: moneyController,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("CANCEL", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("ADD", style: TextStyle(color: Colors.black)),
              onPressed: () {
                String name = nameController.text;
                double money = double.parse(moneyController.text);

                if (money < 100000.00) {
                  Navigator.pop(context);
                  _savePerson(name, money);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Money value must be less than 100.000,00\$',
                            ),
                            AppodealBanner(),
                          ],
                        ),
                        actions: [
                          TextButton(
                            child: Text("OK",
                                style: TextStyle(color: Colors.black)),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  _changeUsername() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change your username"),
          content: TextField(
            maxLength: 15,
            controller: usernameController,
          ),
          actions: [
            TextButton(
              child: Text("CANCEL", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("CHANGE", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.pop(context);
                String username = usernameController.text;
                _saveUsername(username);
              },
            ),
          ],
        );
      },
    );
  }

  _savePerson(name, money) async {
    Map<String, dynamic> content = {"name": name, "money": money};

    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + 'people.json');
      fileExists = jsonFile.existsSync();
      if (fileExists && jsonFile.readAsStringSync().isNotEmpty) {
        List jsonFileContent = json.decode(jsonFile.readAsStringSync());
        jsonFileContent.insert(0, content);
        jsonFile.writeAsStringSync(json.encode(jsonFileContent));
      } else {
        File file = new File(dir.path + "/" + 'people.json');
        file.createSync();
        fileExists = true;
        List<Map<String, dynamic>> jsonFileContent = [];
        jsonFileContent.insert(0, content);
        file.writeAsStringSync(json.encode(jsonFileContent));
      }
    });

    _loadData();
    _loadTotal();
    _watchAd();
  }

  _saveUsername(username) async {
    Map<String, dynamic> content = {"username": username};

    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + 'username.json');
      fileExists = jsonFile.existsSync();
      if (fileExists) {
        Map<String, dynamic> jsonFileContent = json.decode(
          jsonFile.readAsStringSync(),
        );
        jsonFileContent.addAll(content);
        jsonFile.writeAsStringSync(json.encode(jsonFileContent));
      } else {
        File file = new File(dir.path + "/" + 'username.json');
        file.createSync();
        fileExists = true;
        file.writeAsStringSync(json.encode(content));
      }
    });

    _loadData();
    _watchAd();
  }

  _editName(index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLength: 8,
                decoration: InputDecoration(
                  labelText: 'Name (eg.: John):',
                ),
                controller: nameEditController,
              ),
            ],
          ),
          actions: [
            Column(
              children: [
                TextButton(
                  child: Text(
                    "DELETE PERSON",
                    style: TextStyle(
                      color: Colors.red[900],
                    ),
                  ),
                  onPressed: () {
                    _deletePerson(index);
                    Navigator.pop(context);
                  },
                ),
                Row(
                  children: [
                    TextButton(
                      child:
                          Text("CANCEL", style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child:
                          Text("CHANGE", style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        _saveName(index);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _editMoney(index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                maxLength: 8,
                decoration: InputDecoration(
                  labelText: 'Money (eg.: 200.00):',
                ),
                controller: moneyEditController,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("CANCEL", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text("REMOVE", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.pop(context);
                _saveRemoveMoney(index);
              },
            ),
            TextButton(
              child: Text("ADD", style: TextStyle(color: Colors.black)),
              onPressed: () {
                Navigator.pop(context);
                _saveAddMoney(index);
              },
            ),
          ],
        );
      },
    );
  }

  _saveName(index) {
    String n = nameEditController.text;
    Map<String, dynamic> content = {};

    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + 'people.json');
      fileExists = jsonFile.existsSync();
      if (fileExists && jsonFile.readAsStringSync().isNotEmpty) {
        List jsonFileContent = json.decode(jsonFile.readAsStringSync());
        String name = n;
        double money = jsonFileContent[index]["money"];
        content = {"name": name, "money": money};
        jsonFileContent.insert(0, content);
        jsonFileContent.removeAt(index + 1);
        jsonFile.writeAsStringSync(json.encode(jsonFileContent));
      }
    });

    _loadData();
    _loadTotal();
    _watchAd();
  }

  _saveAddMoney(index) {
    double m = double.parse(moneyEditController.text);
    Map<String, dynamic> content = {};

    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + 'people.json');
      fileExists = jsonFile.existsSync();
      if (fileExists && jsonFile.readAsStringSync().isNotEmpty) {
        List jsonFileContent = json.decode(jsonFile.readAsStringSync());
        String name = jsonFileContent[index]["name"];
        double money = jsonFileContent[index]["money"] + m;
        content = {"name": name, "money": money};
        jsonFileContent.insert(0, content);
        jsonFileContent.removeAt(index + 1);
        jsonFile.writeAsStringSync(json.encode(jsonFileContent));
      }
    });

    _loadData();
    _loadTotal();
    _watchAd();
  }

  _saveRemoveMoney(index) {
    double m = double.parse(moneyEditController.text);
    Map<String, dynamic> content = {};

    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + 'people.json');
      fileExists = jsonFile.existsSync();
      if (fileExists && jsonFile.readAsStringSync().isNotEmpty) {
        List jsonFileContent = json.decode(jsonFile.readAsStringSync());
        String name = jsonFileContent[index]["name"];
        double money = jsonFileContent[index]["money"] - m;
        content = {"name": name, "money": money};
        jsonFileContent.insert(0, content);
        jsonFileContent.removeAt(index + 1);
        jsonFile.writeAsStringSync(json.encode(jsonFileContent));
      }
    });

    _loadData();
    _loadTotal();
    _watchAd();
  }

  _deletePerson(index) {
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + 'people.json');
      fileExists = jsonFile.existsSync();
      if (fileExists && jsonFile.readAsStringSync().isNotEmpty) {
        List jsonFileContent = json.decode(jsonFile.readAsStringSync());
        jsonFileContent.removeAt(index);
        jsonFile.writeAsStringSync(json.encode(jsonFileContent));
      }
    });

    _loadData();
    _loadTotal();
    _watchAd();
  }

  void _initTargets() {
    targets.add(
      TargetFocus(
        identify: "Add Person",
        keyTarget: keyButton1,
        color: Colors.green[900],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Add People",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Add a new person you owe money to by clicking this button. You are able to add a name and the money value.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
        shape: ShapeLightFocus.RRect,
        radius: 5,
      ),
    );
    targets.add(
      TargetFocus(
        identify: "Change Username",
        keyTarget: keyButton,
        color: Colors.green[900],
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Edit your username",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "By clicking this button you can change your username to your liking.",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
        shape: ShapeLightFocus.RRect,
        radius: 5,
      ),
    );
    targets.add(
      TargetFocus(
        identify: "Edit Person Name",
        keyTarget: keyButton4,
        color: Colors.green[900],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "Edit Persons Info",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  ),
                  Text(
                    "Here you can change the persons name and/or completely delete the persons info if needed.",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
        shape: ShapeLightFocus.Circle,
      ),
    );
    targets.add(
      TargetFocus(
        identify: "Edit Person Money",
        keyTarget: keyButton3,
        color: Colors.green[900],
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "Edit Money You Owe",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  ),
                  Text(
                    "By clicking this button you can edit the amount of money you owe. You can add money to the total you owe, or you can remove money from the total.",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
        shape: ShapeLightFocus.Circle,
      ),
    );
    targets.add(
      TargetFocus(
        identify: "Total Money",
        keyTarget: keyButton2,
        color: Colors.green[900],
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "Total Money You Owe",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  ),
                  Text(
                    "Here you can see the total amount of money you owe.",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "Try to keep that low!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        shape: ShapeLightFocus.Circle,
      ),
    );
  }

  tutorialCompleted() {
    getApplicationDocumentsDirectory().then((Directory directory) {
      dir = directory;
      jsonFile = new File(dir.path + "/" + 'tutorial.json');
      fileExists = jsonFile.existsSync();
      if (fileExists && jsonFile.readAsStringSync().isNotEmpty) {
        File file = new File(dir.path + "/" + 'tutorial.json');
        var content = {"watched": true};
        Map jsonFileContent = {};
        jsonFileContent.addAll(content);
        file.writeAsStringSync(json.encode(jsonFileContent));
      }
    });

    _loadData();
  }

  void _showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.red,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        tutorialCompleted();
      },
      onSkip: () {
        //tutorialCompleted();
      },
    )..show();
  }
}
