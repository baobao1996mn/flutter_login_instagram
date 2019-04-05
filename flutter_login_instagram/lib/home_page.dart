import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;

enum LoginState { None, Loading, WebView }

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginState loginState = LoginState.None;
  final String _client_id = 'e9a882a7c659478d99fbd68b93fb2cb7';
  final String _client_secret = 'db47ab5ecec04541a82159c709922659';
  final String _redirect_uri = 'https://baobao1996mn.wordpress.com';
  final String _host = 'https://api.instagram.com/oauth';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final webView = new FlutterWebviewPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    webView.onUrlChanged.listen((url) => onUrlChanged(webView, url));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[
            _buildMainView(),
            loginState == LoginState.Loading
                ? Container(
                    alignment: Alignment.center,
                    color: Colors.black12,
                    child: CircularProgressIndicator(),
                  )
                : SizedBox()
          ],
        ),
      ),
      onWillPop: () async {
        if (loginState == LoginState.WebView) {
          setState(() => loginState = LoginState.None);
          webView.close();
        } else
          return loginState != LoginState.Loading;
      },
    );
  }

  _buildMainView() {
    return Column(
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
    final String client_id = 'client_id=$_client_id';
    final String redirect_uri = 'redirect_uri=$_redirect_uri';
    final String response_type = 'response_type=code';
    String _url = "$_host/authorize/?$client_id&$redirect_uri&$response_type";
    setState(() => this.loginState = LoginState.WebView);
    webView.launch(_url);
  }

  void onUrlChanged(FlutterWebviewPlugin webView, String url) async {
    String prefix = "https://baobao1996mn.wordpress.com/?code=";
    if (url.startsWith(prefix)) {
      webView.close();
      setState(() => this.loginState = LoginState.Loading);

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
      var snackBar = SnackBar(content: Text(_toast));
      _scaffoldKey.currentState.showSnackBar(snackBar);
      setState(() => this.loginState = LoginState.None);
    }
  }
}
