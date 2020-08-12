import 'db_test.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int id = 0;
  String name = "july", des = "";
  TextEditingController namecontroller, descontroller;

  @override
  void initState() {
    super.initState();
    namecontroller = TextEditingController();
    descontroller = TextEditingController();
    namecontroller.text = name;
    descontroller.text = des;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextFormField(
              initialValue: id.toString(),
              onChanged: (value) {
                print("changed id");
                id = int.parse(value);
              },
            ),
            TextFormField(
              controller: namecontroller,
              onChanged: (value) {
                print("changed name");
                name = value;
              },
            ),
            TextFormField(
              controller: descontroller,
              onChanged: (value) {
                print("changed des");
                des = value;
              },
            ),
            Row(
              children: [
                RaisedButton(
                    onPressed: () async {
                      var a = await Act.create(name: name, des: des);
                      print(a.toMap());
                    },
                    child: Text("Create")),
                RaisedButton(
                  onPressed: () async {
                    var acts = await Act.all();
                    for (var act in acts) {
                      if (act.pk == id) {
                        setState(() {
                          namecontroller.text = act.name;
                          descontroller.text = act.des;
                        });
                      }
                    }
                  },
                  child: Text("get"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
