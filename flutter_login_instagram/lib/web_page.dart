import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:http/http.dart' as http;

class WebPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WebPageState();
  }
}

class _WebPageState extends State<WebPage> {
  final String _client_id = 'e9a882a7c659478d99fbd68b93fb2cb7';
  final String _client_secret = 'db47ab5ecec04541a82159c709922659';
  final String _redirect_uri = 'https://baobao1996mn.wordpress.com';
  final String _host = 'https://api.instagram.com/oauth';
  bool isLoading = false;
  final webView = new FlutterWebviewPlugin();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final String _url =
        "$_host/authorize/?client_id=$_client_id&redirect_uri=$_redirect_uri&response_type=code";
    webView.onUrlChanged.listen((url) => onUrlChanged(webView, url));
    webView.launch(_url,
        withJavascript: true, withLocalStorage: true, withZoom: true);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(),
        onWillPop: () async {
          webView.close();
          return true;
        });
  }

  void onUrlChanged(FlutterWebviewPlugin webView, String url) async {
    String prefix = "https://baobao1996mn.wordpress.com/?code=";
    if (url.startsWith(prefix)) {
      webView.close();
      setState(() => this.isLoading = true);

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
      setState(() => this.isLoading = false);
      Navigator.of(context).pop(_toast);
    }
  }
}
