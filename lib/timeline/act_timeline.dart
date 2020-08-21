import 'package:daydrive/models/act.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeline_tile/timeline_tile.dart';

class ActTimeline extends StatefulWidget {
  final List<Act> list;
  ActTimeline(this.list);

  @override
  ActTimelineState createState() => ActTimelineState(list);
}

class ActTimelineState extends State<ActTimeline> {
  List<ActData> _firstHalf;

  ActTimelineState(List<Act> list) {
    _firstHalf = [];
    for (var e in list) {
      var actdata = ActData(
          name: e.name,
          des: e.sdes,
          hr: e.startdatetime.hour(),
          mm: e.startdatetime.min(),
          status: Status.start);
      _firstHalf.add(actdata);

      if (e.enddatetime.datetime != 0) {
        var actdata = ActData(
            name: e.name,
            des: e.edes,
            hr: e.enddatetime.hour(),
            mm: e.enddatetime.min(),
            status: Status.end);
        _firstHalf.add(actdata);
      }
    }

    _firstHalf.sort((a, b) {
      return a.hr != b.hr ? a.hr - b.hr : a.mm - b.mm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF117E69),
            Color(0xFF383A47),
          ],
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          accentColor: const Color(0xFF117E69).withOpacity(0.2),
          chipTheme: Theme.of(context).chipTheme.copyWith(
                disabledColor: Colors.transparent,
                labelStyle: GoogleFonts.dosis(
                  fontSize: 18,
                  color: Colors.black45,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                '01 June 2020 16:00',
                style: GoogleFonts.dosis(
                  fontSize: 20,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            extendBodyBehindAppBar: true,
            body: Center(
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 16),

                  // _Scoreboard(),
                  Expanded(
                    child: CustomScrollView(
                      slivers: <Widget>[
                        _TimelineAct(data: _firstHalf),
                        SliverList(
                          delegate: SliverChildListDelegate(<Widget>[
                            const _MessageTimeline(
                              message: 'Thats all',
                            ),
                          ]),
                        ),
                        const SliverPadding(padding: EdgeInsets.only(top: 20)),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<ActData> _generateData() {
    return <ActData>[
      ActData(
          name: "movie",
          des: "Started movie with fun",
          hr: 8,
          mm: 40,
          status: Status.start),
      ActData(
          name: "whatsapp",
          des: "video chat with Genedy koroksh",
          hr: 8,
          mm: 55,
          status: Status.start),
      ActData(
          name: "whatsapp",
          des: "video chat with Genedy koroksh end up with a fight",
          hr: 9,
          mm: 10,
          status: Status.end),
      ActData(
          name: "popcorn",
          des: "making cheese popcorn",
          hr: 9,
          mm: 25,
          status: Status.start),
      ActData(
          name: "popcorn",
          des: "made cheese popcorn",
          hr: 9,
          mm: 30,
          status: Status.end),
      ActData(
          name: "movie",
          des: "movie was really funn.",
          hr: 10,
          mm: 10,
          status: Status.end),
    ];
  }
}

class ActiveActs extends StatefulWidget {
  @override
  _ActiveActsState createState() => _ActiveActsState();
}

class _ActiveActsState extends State<ActiveActs> {
  // final GlobalKey<AnimatedListState> _active = GlobalKey<AnimatedListState>();
  final list = [
    FilterChip(selected: true, label: Text('movie'), onSelected: null),
    FilterChip(label: Text('popcorn'), onSelected: null),
    ChoiceChip(label: Text('whatsapp'), selected: true),
    ChoiceChip(label: Text('whatsapp'), selected: false),
    FilterChip(label: Text('popcorn'), onSelected: null),
    ChoiceChip(label: Text('whatsapp'), selected: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: list,
    );
  }
}

class _TimelineAct extends StatelessWidget {
  const _TimelineAct({Key key, this.data}) : super(key: key);

  final List<ActData> data;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final ActData event = data[index];

          final isLeftChild = event.status == Status.start;

          final child = _TimelineActChild(
            name: event.name,
            des: event.des,
            hr: event.hr,
            mm: event.mm,
            isLeftChild: isLeftChild,
          );

          return TimelineTile(
            alignment: TimelineAlign.center,
            rightChild: isLeftChild ? null : child,
            leftChild: isLeftChild ? child : null,
            indicatorStyle: IndicatorStyle(
              width: 40,
              height: 40,
              indicator: _TimelineActIndicator(
                  time: event.hr.toString() + ":" + event.mm.toString()),
              drawGap: true,
            ),
            topLineStyle: LineStyle(
              color: Colors.white.withOpacity(0.2),
              width: 3,
            ),
          );
        },
        childCount: data.length,
      ),
    );
  }
}

class _MessageTimeline extends StatelessWidget {
  const _MessageTimeline({Key key, this.message}) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.dosis(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineActChild extends StatelessWidget {
  const _TimelineActChild(
      {Key key,
      this.name,
      this.des,
      this.hr,
      this.mm,
      this.status,
      this.isLeftChild})
      : super(key: key);

  final String name;
  final String des;
  final int hr;
  final int mm;
  final Status status;
  final bool isLeftChild;

  @override
  Widget build(BuildContext context) {
    final rowChildren = <Widget>[
      Expanded(
        child: Text(
          name,
          textAlign: isLeftChild ? TextAlign.right : TextAlign.left,
          style: GoogleFonts.dosis(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ];

    return Padding(
      padding: isLeftChild
          ? const EdgeInsets.only(left: 16, top: 10, bottom: 10, right: 10)
          : const EdgeInsets.only(right: 16, top: 10, bottom: 10, left: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: isLeftChild ? rowChildren.reversed.toList() : rowChildren,
          ),
          Flexible(
            child: Text(
              des,
              textAlign: isLeftChild ? TextAlign.right : TextAlign.left,
              style: GoogleFonts.dosis(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildIconByAction(Action action) {
  //   final imageAsset =
  //       'assets/football/${action.toString().split('.').last}.png';
  //   return Image.asset(
  //     imageAsset,
  //     height: 20,
  //     width: 20,
  //   );
  // }
}

class _TimelineActIndicator extends StatelessWidget {
  const _TimelineActIndicator({Key key, this.time}) : super(key: key);

  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 3,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          time,
          style: GoogleFonts.dosis(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

enum Status {
  start,
  end,
}

class ActData {
  ActData({this.name, this.des, this.hr, this.mm, this.status});

  final String name;
  final String des;
  final int hr;
  final int mm;
  final Status status;
}
