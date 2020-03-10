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
      )
  );
}


class _MyHomePageState extends State<MyHomePage> {
  WebViewController _controller;

  String webtitle = '';
  String weburl = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              itemBuilder: (BuildContext context) =><PopupMenuItem<String>>[
                new PopupMenuItem(
                    value: "1",
                    child: new Text("反馈")
                ),
                new PopupMenuItem(
                    value:'2',
                    child: new Text("退出")
                )
              ],
            onSelected: (String value){
              if(value == '1'){
                _controller.loadUrl('https://bbs.craft.moe/d/521-app/');
              }
              if(value == '2'){
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              }
            },
          ),
        ],
      ),
      body: WebView(
        initialUrl: 'https://bbs.craft.moe',
        javascriptMode: JavascriptMode.unrestricted,
        onPageFinished: (url) {
          _controller.evaluateJavascript("document.title").then((result) {
            webtitle = result;
          });
          _controller.evaluateJavascript("window.location.href").then((result) {
            weburl = result;
          });
        },
        onWebViewCreated: (WebViewController con) {
          _controller = con;
        },
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
          leading: Icon(Icons.my_location),
          title: Text("世界地图"),
          onTap: () {
            Navigator.of(context).pop();
            _controller.loadUrl('https://kedama-map.jsw3286.eu.org/?utm_source=blw_app');
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
          title: Text("玩家数据查询"),
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