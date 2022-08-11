import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show debugPaintSizeEnabled;
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share/share.dart';
import 'package:flutter_egg/flutter_egg.dart';
import 'package:fluttertoast/fluttertoast.dart';

void main() {
  debugPaintSizeEnabled = false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    return MaterialApp(
      title: '毛玉线圈物语',
      theme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
          primary: Colors.blue,
          secondary: Colors.black,
          background: Colors.white,
        ),
      ),
      darkTheme: theme.copyWith(
        colorScheme: theme.colorScheme.copyWith(
            primary: Colors.black,
            secondary: Colors.white,
            background: Colors.black),
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

selectView(IconData icon, String text, String id) {
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
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }
  // Enable hybrid composition

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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          content: Text(
            '再按一次退出',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          action: new SnackBarAction(
              label: '退出',
              textColor: Theme.of(context).colorScheme.secondary,
              onPressed: () {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              }),
        ));
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
              color: Theme.of(context).colorScheme.background,
              itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                new PopupMenuItem(
                    value: "feedback",
                    child: new Text(
                      '反馈',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    )),
                new PopupMenuItem(
                    value: "about",
                    child: new Text(
                      '关于',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    )),
                new PopupMenuItem(
                    value: 'exit',
                    child: new Text(
                      '退出',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary),
                    ))
              ],
              onSelected: (String value) {
                if (value == 'feedback') {
                  _controller.loadUrl('https://community.craft.moe/d/521-app/');
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
              initialUrl: 'https://community.craft.moe',
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (url) {
                _controller
                    .runJavascriptReturningResult("document.title")
                    .then((result) {
                  webtitle = result;
                });
                _controller
                    .runJavascriptReturningResult("window.location.href")
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
          leading: Icon(Icons.people,
              color: Theme.of(context).colorScheme.secondary),
          title: Text(
            '论坛',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onTap: () {
            Navigator.of(context).pop();
            _controller.loadUrl('https://community.craft.moe');
          },
        ),
        ListTile(
          leading: Icon(Icons.search,
              color: Theme.of(context).colorScheme.secondary),
          title: Text(
            '论坛内搜索',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onTap: () {
            Navigator.of(context).pop();
            _controller
                .loadUrl('https://dl.blingwang.cn/static/bbs_search.html');
          },
        ),
        ListTile(
          leading:
              Icon(Icons.map, color: Theme.of(context).colorScheme.secondary),
          title: Text(
            '世界地图',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onTap: () {
            Navigator.of(context).pop();
            _controller.loadUrl('https://3ec5k.csb.app/?world=v5');
          },
        ),
        ListTile(
          leading: Icon(Icons.location_pin,
              color: Theme.of(context).colorScheme.secondary),
          title: Text(
            '毛线交通向导',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onTap: () {
            Navigator.of(context).pop();
            _controller.loadUrl('https://map.ououe.com/');
          },
        ),
        ListTile(
          leading: Icon(Icons.terminal,
              color: Theme.of(context).colorScheme.secondary),
          title: Text(
            '指令大全',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onTap: () {
            Navigator.of(context).pop();
            _controller.loadUrl('https://www.craft.moe/help');
          },
        ),
        ListTile(
          leading: Icon(Icons.local_laundry_service,
              color: Theme.of(context).colorScheme.secondary),
          title: Text(
            '服务器状态',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onTap: () {
            Navigator.of(context).pop();
            _controller.loadUrl('https://labs.blw.moe/mcphp');
          },
        ),
        ListTile(
          leading: Icon(Icons.playlist_add_check,
              color: Theme.of(context).colorScheme.secondary),
          title: Text(
            '玩家数据查询（官方）',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onTap: () {
            Navigator.of(context).pop();
            _controller.loadUrl('https://stats.craft.moe');
          },
        ),
        ListTile(
          leading: Icon(Icons.playlist_add_check,
              color: Theme.of(context).colorScheme.secondary),
          title: Text(
            '玩家数据查询（第三方）',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onTap: () {
            Navigator.of(context).pop();
            _controller.loadUrl('https://labs.blw.moe/kedama');
          },
        ),
        ListTile(
          leading: Icon(Icons.settings_input_svideo,
              color: Theme.of(context).colorScheme.secondary),
          title: Text(
            '调试工具',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          onTap: () {
            Navigator.of(context).pop();
            _controller.loadUrl('https://labs.blw.moe/KedamaAppDebugTools');
          },
        ),
      ],
    );
  }

  Widget buildDrawer(BuildContext context) {
    return new Container(
        color: Theme.of(context).colorScheme.onBackground,
        child: ListView(
          children: <Widget>[
            new Image.asset(
              'images/banner.png',
              height: 200,
              fit: BoxFit.cover,
            ),
            new Container(
              child: _buildDrawerBody(),
            )
          ],
        ));
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
              color: Theme.of(context).colorScheme.background,
              height: 1800,
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
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20.0),
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
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 18.0),
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
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 18.0),
                          ),
                          TextSpan(
                            text: '超级大笨蛋\n',
                            style:
                                TextStyle(color: Colors.blue, fontSize: 32.0),
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
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20.0),
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
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20.0),
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
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20.0),
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
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20.0),
                          ),
                          TextSpan(
                            text: 'WIP\n在摸了，在摸了',
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
                  height: 100,
                  margin: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 5.0),
                  child: Row(children: <Widget>[
                    Image.asset('images/players/Empesuzuran.png'),
                    Container(
                        margin: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                          TextSpan(
                            text: '\nEmpesuzuran\n',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20.0),
                          ),
                          TextSpan(
                            text: '没见过主城二楼的夕云姐姐\n不要跟别人说你玩过毛线（\n',
                            style: TextStyle(
                                color: Colors.deepPurpleAccent, fontSize: 16.0),
                          ),
                        ]))),
                  ]),
                ),
                Container(
                  width: 300,
                  height: 80,
                  margin: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 5.0),
                  child: Row(children: <Widget>[
                    Image.asset('images/players/gdides.png'),
                    Container(
                        margin: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                          TextSpan(
                            text: 'gdides\n',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20.0),
                          ),
                          TextSpan(
                            text: '找 Bug 的神！\n',
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
                    Image.asset('images/players/Rikka_cute.png'),
                    Container(
                        margin: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                          TextSpan(
                            text: 'Rikka_cute\n',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20.0),
                          ),
                          TextSpan(
                            text: '一般路过rikka\n',
                            style: TextStyle(
                                color: Colors.pinkAccent, fontSize: 16.0),
                          ),
                        ]))),
                  ]),
                ),
                Container(
                  width: 300,
                  height: 80,
                  margin: EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 5.0),
                  child: Row(children: <Widget>[
                    Image.asset('images/players/Eillenc.png'),
                    Container(
                        margin: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                          TextSpan(
                            text: 'Eillenc\n',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20.0),
                          ),
                          TextSpan(
                            text: '窝很阔爱，请亏我全\n',
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
                    Image.asset('images/players/Rhythm202.png'),
                    Container(
                        margin: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                          TextSpan(
                            text: 'Rhythm202\n',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20.0),
                          ),
                          TextSpan(
                            text: '天气很冷，该加衣服了\n',
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
                    Image.asset('images/players/Yaolinger102.png'),
                    Container(
                        margin: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                          TextSpan(
                            text: 'Yaolinger102\n',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20.0),
                          ),
                          TextSpan(
                            text: '甜甜的\n',
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
                    Image.asset('images/players/coolgunnerfish.png'),
                    Container(
                        margin: EdgeInsets.fromLTRB(15.0, 0.0, 0.0, 0.0),
                        child: RichText(
                            text: TextSpan(children: <TextSpan>[
                          TextSpan(
                            text: 'coolgunnerfish\n',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 20.0),
                          ),
                          TextSpan(
                            text: '希望大家都能出货\n',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 16.0),
                          ),
                        ]))),
                  ]),
                ),
                Container(
                    height: 430,
                    margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    child: Column(children: <Widget>[
                      SizedBox(height: 10),
                      Text(
                        '\n请问你们看见我们家的蓝瓜了吗？\n他非常可爱，简直就是小天使\n',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 18.0),
                        textAlign: TextAlign.center,
                      ),
                      Image.asset('images/players/langua.png'),
                      Text(
                        '\n他没失踪也没怎样\n只是觉得你们都该看一下\n',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 18.0),
                        textAlign: TextAlign.center,
                      ),
                      Image.asset('images/players/VLAGL.png'),
                      Text(
                        '\n还有永远的眯眯眼发条\n你永远活在我们的心里\n',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 18.0),
                        textAlign: TextAlign.center,
                      ),
                    ])),
                Container(
                  width: 300,
                  height: 80,
                  margin: EdgeInsets.fromLTRB(50.0, 0.0, 0.0, 0.0),
                  child: Row(children: <Widget>[
                    Container(
                        margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                        child: Egg(
                            neededNum: 20,
                            onTap: (int tapNum, int neededNum) {
                              if (tapNum == 5) {
                                Fluttertoast.showToast(
                                    msg: "不要点啦",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    fontSize: 16.0);
                              }
                              if (tapNum == 10) {
                                Fluttertoast.showToast(
                                    msg: "不要再点了啦",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 1,
                                    fontSize: 16.0);
                              }
                            },
                            onTrigger: (int tapNum, int neededNum) {
                              Fluttertoast.showToast(
                                  msg: "真的不要再点啦，这里是没有东西的（",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  fontSize: 16.0);
                            },
                            child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(children: <TextSpan>[
                                  TextSpan(
                                    text: '更多精彩，等你发现\n',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 20.0),
                                  ),
                                  TextSpan(
                                    text: 'Version 1.3.0\n',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16.0),
                                  ),
                                  TextSpan(
                                    text:
                                        '©2022 blw.moe All rights reserved.\n',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16.0),
                                  ),
                                ])))),
                  ]),
                ),
              ]))
        ]));
  }
}
