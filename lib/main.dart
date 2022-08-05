import 'dart:io';
import 'dart:math';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';
import 'package:path_provider/path_provider.dart';

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

  String? _username = '';
  String _total = '0.00';
  int tasks = 0;

  List<dynamic>? _data = [];
  int _dataLength = 0;

  late File jsonFile;
  late Directory dir;
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
                                '${_data![i]["name"]}',
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
                                  '${_data![i]["money"]}\$',
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
    Appodeal.initialize(
      appKey: "d44844485ed9327b1faf7321ccb7e12fb4e4773bdaed80a1",
      adTypes: [
        AppodealAdType.Interstitial,
        AppodealAdType.RewardedVideo,
        AppodealAdType.Banner,
        AppodealAdType.MREC
      ],
    );
    Future.delayed(const Duration(seconds: 10), _watchAd());

    _loadData();
    _loadTotal();
  }

  _watchAd() {
    if (tasks <= 0) {
      Appodeal.show(AppodealAdType.Interstitial);
      setState(() {
        tasks = 10;
      });
    }
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
          _dataLength = _data!.length;
        });
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
        _dataLength = _data!.length;
        double t = 0.0;

        this.setState(() {
          for (int i = 0; i < _dataLength; i++) {
            double m = _data![i]["money"];
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
                            const AppodealBanner(
                              adSize: AppodealBannerSize.BANNER,
                            ),
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
    setState(() {
      tasks -= 1;
    });
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
    setState(() {
      tasks -= 1;
    });
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
        double? money = jsonFileContent[index]["money"];
        content = {"name": name, "money": money};
        jsonFileContent.insert(0, content);
        jsonFileContent.removeAt(index + 1);
        jsonFile.writeAsStringSync(json.encode(jsonFileContent));
      }
    });

    _loadData();
    _loadTotal();
    setState(() {
      tasks -= 1;
    });
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
        String? name = jsonFileContent[index]["name"];
        double? money = jsonFileContent[index]["money"] + m;
        content = {"name": name, "money": money};
        jsonFileContent.insert(0, content);
        jsonFileContent.removeAt(index + 1);
        jsonFile.writeAsStringSync(json.encode(jsonFileContent));
      }
    });

    _loadData();
    _loadTotal();
    setState(() {
      tasks -= 1;
    });
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
        String? name = jsonFileContent[index]["name"];
        double? money = jsonFileContent[index]["money"] - m;
        content = {"name": name, "money": money};
        jsonFileContent.insert(0, content);
        jsonFileContent.removeAt(index + 1);
        jsonFile.writeAsStringSync(json.encode(jsonFileContent));
      }
    });

    _loadData();
    _loadTotal();
    setState(() {
      tasks -= 1;
    });
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
    setState(() {
      tasks -= 1;
    });
    _watchAd();
  }
}
