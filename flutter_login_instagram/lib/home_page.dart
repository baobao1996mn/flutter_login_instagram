import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_web_view/flutter_web_view.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String _client_id = 'e9a882a7c659478d99fbd68b93fb2cb7';
  final String _client_secret = 'db47ab5ecec04541a82159c709922659';
  final String _redirect_uri = 'https://www.instagram.com';
  final String _host = 'https://api.instagram.com/oauth';
  String _url;
  bool _isDismiss = false;
  FlutterWebView flutterWebView = FlutterWebView();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _url =
        "$_host/authorize/?client_id=$_client_id&redirect_uri=$_redirect_uri&response_type=code";

    flutterWebView.onToolbarAction.listen((_) {
      flutterWebView.dismiss();
      Navigator.of(context).pop();
    });

    flutterWebView.onWebViewDidStartLoading.listen((url) {
      print('StartLoading: $url');
    });
    flutterWebView.onWebViewDidLoad.listen((url) {
      print('Didload: $url');
      onPageFinished(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 92),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 20)
                        ]),
                    child: _buildLoginButton(),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  _buildLoginButton() {
    return Material(
      child: InkWell(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Image.asset("images/instagram.png", height: 36.0),
              ),
              Text(
                "Login with Instagram",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
              )
            ],
          ),
        ),
        onTap: _login,
      ),
    );
  }

  void _login() async {
    _isDismiss = false;
    Platform.isAndroid
        ? flutterWebView.launch(_url, javaScriptEnabled: true)
        : flutterWebView.launch(_url,
            headers: {"X-SOME-HEADER": "MyCustomHeader"},
            toolbarActions: [new ToolbarAction("Back", 1)],
            javaScriptEnabled: false);

    flutterWebView.onToolbarAction.listen((_) {
      flutterWebView.dismiss();
      Navigator.of(context).pop();
    });

    flutterWebView.onWebViewDidStartLoading.listen((url) {
      print('StartLoading: $url');
    });
    flutterWebView.onWebViewDidLoad.listen((url) {
      print('Didload: $url');
      onPageFinished(url);
    });
  }

  void onPageFinished(String url) async {
    String prefix = "$_redirect_uri/?code=";
    if (url.startsWith(prefix) && !_isDismiss) {
      flutterWebView.dismiss();
      _isDismiss = true;
      String code = url.replaceFirst(prefix, "");
      Map map = {
        'client_id': _client_id,
        'client_secret': _client_secret,
        'grant_type': 'authorization_code',
        'redirect_uri': _redirect_uri,
        'code': code
      };
      var response = await http.post('$_host/access_token', body: map);
      String _toast = response.reasonPhrase;
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        _toast = data['access_token'] ?? 'empty';
      }
      if (_toast != null) {
        var snackBar = SnackBar(content: Text(_toast));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      }
    } else if (url == '$_redirect_uri/') {
      flutterWebView.load(_url);
    }
  }
}
