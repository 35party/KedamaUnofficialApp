import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share/share.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '毛玉线圈物语',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        accentColor: Colors.black,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.white,
      ),
      home: MyHomePage(title: '毛玉线圈物语'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  String title;
  WebViewController controller;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

SelectView(IconData icon, String text, String id) {
  return new PopupMenuItem<String>(
      value: id,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          new Icon(icon, color: Colors.blue),
          new Text(text),
        ],
      ));
}

class _MyHomePageState extends State<MyHomePage> {
  var _scaffoldkey = new GlobalKey<ScaffoldState>();
  DateTime lastPopTime = DateTime.now();
  WebViewController _controller;
  Future<bool> _exitApp(BuildContext context) async {
    if (await _controller.canGoBack()) {
      _controller.goBack();
    } else {
      if (lastPopTime == null ||
          DateTime.now().difference(lastPopTime) > Duration(seconds: 2)) {
        lastPopTime = DateTime.now();
        var snackBar = SnackBar(
          content: Text('再按一次退出'),
          action: new SnackBarAction(
              label: '退出',
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              }),
        );
        _scaffoldkey.currentState.showSnackBar(snackBar);
      } else {
        lastPopTime = DateTime.now();
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      }
    }
  }

  String webtitle = '';
  String weburl = '';
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _exitApp(context),
      child: Scaffold(
        key: _scaffoldkey,
        drawer: new Drawer(
          child: buildDrawer(context),
        ),
        appBar: AppBar(
          title: Text(widget.title),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.share),
              tooltip: '分享',
              onPressed: () => Share.share(webtitle + "\n" + weburl),
            ),
            new PopupMenuButton<String>(
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                new PopupMenuItem(value: "feedback", child: new Text("反馈")),
                new PopupMenuItem(value: "about", child: new Text("关于")),
                new PopupMenuItem(value: 'exit', child: new Text("退出"))
              ],
              onSelected: (String value) {
                if (value == 'feedback') {
                  _controller.loadUrl('https://bbs.craft.moe/d/521-app/');
                }
                if (value == 'exit') {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                }
                if (value == 'about') {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AboutScreen()));
                }
              },
            ),
          ],
        ),
        body: Builder(
          builder: (BuildContext context) {
            return WebView(
              initialUrl: 'https://bbs.craft.moe',
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (url) {
                _controller.evaluateJavascript("document.title").then((result) {
                  webtitle = result;
                });
                _controller
                    .evaluateJavascript("window.location.href")
                    .then((result) {
                  weburl = result;
                });
              },
              onWebViewCreated: (WebViewController con) {
                _controller = con;
                _controller.canGoBack();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDrawerBody() {
    return new Column(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.people),
          title: Text("论坛"),
          onTap: () {
            Navigator.of(context).pop();
            _controller.loadUrl('https://bbs.craft.moe');
          },
        ),
        ListTile(
          leading: Icon(Icons.search),
          title: Text("论坛内搜索"),
          onTap: () {
            Navigator.of(context).pop();
            _controller.loadUrl('https://dl.blingwang.cn/static/bbs_search.html');
          },
        ),
        ListTile(
          leading: Icon(Icons.local_laundry_service),
          title: Text("服务器状态"),
          onTap: () {
            Navigator.of(context).pop();
            _controller.loadUrl('https://labs.blw.moe/mcphp');
          },
        ),
        ListTile(
          leading: Icon(Icons.playlist_add_check),
          title: Text("玩家数据查询（官方）"),
          onTap: () {
            Navigator.of(context).pop();
            _controller.loadUrl('https://stats.craft.moe');
          },
        ),
        ListTile(
          leading: Icon(Icons.playlist_add_check),
          title: Text("玩家数据查询（第三方）"),
          onTap: () {
            Navigator.of(context).pop();
            _controller.loadUrl('https://labs.blw.moe/kedama');
          },
        ),
        ListTile(
          leading: Icon(Icons.settings_input_svideo),
          title: Text("调试工具"),
          onTap: () {
            Navigator.of(context).pop();
            _controller.loadUrl('https://labs.blw.moe/KedamaAppDebugTools');
          },
        ),
      ],
    );
  }

  Widget buildDrawer(BuildContext context) {
    return new ListView(
      children: <Widget>[
        new Image.asset(
          'images/banner.png',
          height: 170,
          fit: BoxFit.cover,
        ),
        _buildDrawerBody(),
      ],
    );
  }
}
class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('关于应用'),
        ),
        body: ListView(children: <Widget>[
          Container(
              alignment: Alignment.center,
              child:
              Column(mainAxisAlignment: MainAxisAlignment.start, children: <
                  Widget>[
                Container(
                  width: 300,
                  height: 80,
                  margin: EdgeInsets.fromLTRB(30.0, 20.0, 0.0, 15.0),
                  child: Row(children: <Widget>[
                    Image.asset('images/players/BlingWang.png'),
                    Container(
                        margin: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                text: 'BlingWang\n',
                                style:
                                TextStyle(color: Theme.of(context).accentColor, fontSize: 20.0),
                              ),
                              TextSpan(
                                text: '开发者\n',
                                style:
                                TextStyle(color: Colors.grey, fontSize: 16.0),
                              ),
                            ]))),
                  ]),
                ),
                Text(
                  '另外感谢下列提出意见的朋友们\n正是因为你们，这个APP才变得越来越好\n',
                  style: TextStyle(fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
                Container(
                  width: 300,
                  height: 80,
                  margin: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 5.0),
                  child: Row(children: <Widget>[
                    Image.asset('images/players/forst_candy.png'),
                    Container(
                        margin: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                text: 'forst_candy\n',
                                style:
                                TextStyle(color: Theme.of(context).accentColor, fontSize: 20.0),
                              ),
                              TextSpan(
                                text: '小甜甜\n',
                                style:
                                TextStyle(color: Colors.grey, fontSize: 16.0),
                              ),
                            ]))),
                  ]),
                ),
                Container(
                  width: 300,
                  height: 80,
                  margin: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 5.0),
                  child: Row(children: <Widget>[
                    Image.asset('images/players/Azur_KingGeorgeV.png'),
                    Container(
                        margin: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                text: 'Azur_KingGeorgeV\n',
                                style:
                                TextStyle(color: Theme.of(context).accentColor, fontSize: 20.0),
                              ),
                              TextSpan(
                                text: '大哥大乔五\n',
                                style:
                                TextStyle(color: Colors.grey, fontSize: 16.0),
                              ),
                            ]))),
                  ]),
                ),
                Container(
                  width: 300,
                  height: 80,
                  margin: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 5.0),
                  child: Row(children: <Widget>[
                    Image.asset('images/players/PinkishRed.png'),
                    Container(
                        margin: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                text: 'PinkishRed\n',
                                style:
                                TextStyle(color: Theme.of(context).accentColor, fontSize: 20.0),
                              ),
                              TextSpan(
                                text: '贰叄\n',
                                style:
                                TextStyle(color: Colors.grey, fontSize: 16.0),
                              ),
                            ]))),
                  ]),
                ),
                Container(
                  width: 300,
                  height: 80,
                  margin: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 5.0),
                  child: Row(children: <Widget>[
                    Image.asset('images/players/Azur_Washington.png'),
                    Container(
                        margin: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                text: 'Azur_Washington\n',
                                style:
                                TextStyle(color: Theme.of(context).accentColor, fontSize: 20.0),
                              ),
                              TextSpan(
                                text: '花生\n',
                                style:
                                TextStyle(color: Colors.grey, fontSize: 16.0),
                              ),
                            ]))),
                  ]),
                ),
                Container(
                  width: 300,
                  height: 80,
                  margin: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 5.0),
                  child: Row(children: <Widget>[
                    Image.asset('images/players/Ping_timeout.png'),
                    Container(
                        margin: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                text: 'Ping_timeout\n',
                                style:
                                TextStyle(color: Theme.of(context).accentColor, fontSize: 20.0),
                              ),
                              TextSpan(
                                text: 'WIP\n',
                                style: TextStyle(
                                    color: Colors.orange,
                                    fontSize: 16.0,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold),
                              ),
                            ]))),
                  ]),
                ),
                Container(
                  width: 300,
                  height: 80,
                  margin: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 50.0),
                  child: Row(children: <Widget>[
                    Container(
                        margin: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                              TextSpan(
                                text: '更多精彩，等你发现！\n',
                                style:
                                TextStyle(color: Theme.of(context).accentColor, fontSize: 20.0),
                              ),
                              TextSpan(
                                text: '©2020 blw.moe All rights reserved.\n',
                                style:
                                TextStyle(color: Colors.grey, fontSize: 16.0),
                              ),
                            ]))),
                  ]),
                ),
              ]))
        ]));
  }
}