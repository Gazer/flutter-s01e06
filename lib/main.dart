import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
import 'dart:math';
import 'network.dart';

const swatch_1 = Color(0xff91a1b4);
const swatch_2 = Color(0xffe3e6f3);
const swatch_3 = Color(0xffbabdd2);
const swatch_4 = Color(0xff545c6b);
const swatch_5 = Color(0xff363cb0);
const swatch_6 = Color(0xff09090a);
const swatch_7 = Color(0xff25255b);

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Latest news'),
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
  ScrollController _controller;
  double backgroundHeight = 180.0;
  Future<RssFeed> future;

  @override
  void initState() {
    super.initState();

    future = getNews();

    _controller = ScrollController();
    _controller.addListener(() {
      setState(() {
        backgroundHeight = max(
            0,
            180.0 - _controller.offset
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: swatch_3.withOpacity(0.5),
        elevation: 0.0,
        centerTitle: false,
        title: Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Text(widget.title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 30.0,
            ),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 32.0),
            child: InkWell(
              child: Icon(Icons.share,
                color: swatch_1,
              ),
            ),
          )
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return FutureBuilder(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<RssFeed> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          case ConnectionState.done:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');

            return Stack(
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: backgroundHeight,
                  color: swatch_3.withOpacity(0.5),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: ListView.builder(
                    controller: _controller,
                    itemCount: snapshot.data.items.length + 2,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
                          child: Text(snapshot.data.description),
                        );
                      }
                      if (index == 1) {
                        return _bigItem();
                      }

                      return _item(snapshot.data.items[index - 2]);
                    },
                  ),
                ),
              ],
            );
        }
        return null;
      },
    );
  }

  Widget _bigItem() {
    var screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: (screenWidth - 64) * 3 / 5,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/big_item.png'),
            ),
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        Container(
          width: 64.0,
          height: 64.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32.0),
          ),
          child: Icon(Icons.play_arrow,
            size: 40.0,
            color: swatch_7,
          ),
        )
      ],
    );
  }

  Widget _item(RssItem item) {
    var mediaUrl = _extractImage(item.content.value);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 42.0,
                        height: 42.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(21.0),
                          color: swatch_5,
                        ),
                        child: Center(
                          child: Text(item.categories.first.value[0],
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Text(item.categories.first.value,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(item.title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                  Text(item.dc.creator,
                    style: TextStyle(
                      color: swatch_4,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(width: 16.0),
            mediaUrl != null ? Container(
              width: 120,
              height: 120,
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/item_1.jpg',
                image: mediaUrl,
                fit: BoxFit.cover,
              ),
            ): SizedBox(width: 0.0)
          ],
        ),
      ),
    );
  }

  String _extractImage(String content) {
    RegExp regexp = RegExp('<img[^>]+src="([^">]+)"');

    Iterable<Match> matches = regexp.allMatches(content);

    if (matches.length > 0) {
      return matches.first.group(1);
    }

    return null;
  }
}
