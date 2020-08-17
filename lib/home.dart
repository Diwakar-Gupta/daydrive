import 'package:daydrive/models/act.dart';
import 'package:daydrive/timeline/act_timeline.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Act> list;

  @override
  void initState() {
    super.initState();

    Act.inRange(to: TimeDate(datetime: 0)).then((value) => list = value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'What r u doing',
          style: TextStyle(
              fontSize: 35,
              color: Colors.black87,
              decoration: TextDecoration.none),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              ' now',
              style: TextStyle(
                  backgroundColor: Colors.transparent,
                  fontSize: 35,
                  color: Colors.black87,
                  decoration: TextDecoration.none),
            ),
            Align(
              alignment: Alignment.topRight,
              child: FlatButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (contex) => ActTimeline(list)));
                  },
                  child: Text(
                    'timeline',
                    style: TextStyle(fontSize: 16),
                  )),
            ),
          ],
        ),
        Spacer(),
        Center(
          child: Container(
              width: 250,
              child: NotificationListener<ActCreate>(
                onNotification: (ActCreate nact) {
                  nact.act.insert();
                  setState(() {
                    list.add(nact.act);
                  });
                  return true;
                },
                child: _CreateAct(),
              )),
        ),
        Spacer(),
        _ActivePicker(
          list: list,
        )
      ],
    );
  }
}

class _CreateAct extends StatelessWidget {
  final TextEditingController titlecontroler = new TextEditingController();
  final TextEditingController descontroler = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Card(
        child: TextField(
          controller: titlecontroler,
          autofocus: false,
          style: TextStyle(fontSize: 20.0, color: Colors.black54),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'movie, cricket',
            contentPadding:
                const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(25.7),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(25.7),
            ),
          ),
        ),
      ),
      Card(
        child: TextField(
          controller: descontroler,
          maxLines: 3,
          autofocus: false,
          style: TextStyle(fontSize: 20.0, color: Colors.black54),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'watching avengers endgame with friends really exceiting',
            contentPadding:
                const EdgeInsets.only(left: 14.0, bottom: 8.0, top: 8.0),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(25.7),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(25.7),
            ),
          ),
        ),
      ),
      Row(
        children: [
          Text(
            'icon: ',
            style: TextStyle(
                fontSize: 20,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          Icon(Icons.block)
        ],
      ),
      SizedBox(height: 20),
      Container(
        width: double.infinity,
        height: 50,
        child: RaisedButton(
          onPressed: () {
            ActCreate(Act(
                    name: titlecontroler.text, startdatetime: TimeDate.now(), enddatetime: TimeDate(datetime: 0)))
                .dispatch(context);
          },
          child: Text(
            'create',
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
          ),
        ),
      )
    ]);
  }
}

class _ActivePicker extends StatefulWidget {
  final List<Act> list;

  const _ActivePicker({Key key, this.list}) : super(key: key);

  @override
  __ActivePickerState createState() => __ActivePickerState();
}

class __ActivePickerState extends State<_ActivePicker> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 100),
      child: Card(
        color: Colors.transparent,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List<Widget>.generate(widget.list==null?0:widget.list, (index) {
              var e = widget.list[index];
              return Chip(
                deleteButtonTooltipMessage: 'done',
                padding: EdgeInsets.all(6),
                label: Text(e.name),
                avatar: CircleAvatar(
                  child: Icon(Icons.food_bank),
                ),
                onDeleted: () async {
                  if (await e.done('des', TimeDate.now())) {
                    setState(() {
                      widget.list.removeAt(index);
                    });
                  }
                },
                deleteIcon: Icon(Icons.done),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class ActCreate extends Notification {
  final Act act;

  ActCreate(this.act);
}
