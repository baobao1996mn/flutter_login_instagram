import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_web_view/flutter_web_view.dart';
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
  final String _redirect_uri = 'https://www.instagram.com';
  final String _host = 'https://api.instagram.com/oauth';
  bool _isLoading = false;
  String _url;
  FlutterWebView flutterWebView = FlutterWebView();

  @override
  void initState() {
    super.initState();
    _url =
        "$_host/authorize/?client_id=$_client_id&redirect_uri=$_redirect_uri&response_type=code";

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
      setState(() => _isLoading = true);
    });
    flutterWebView.onWebViewDidLoad.listen((url) {
      print('Didload: $url');
      if (mounted) setState(() => _isLoading = false);
      onPageFinished(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Container(
              color: Colors.black12,
              child: CircularProgressIndicator(),
              alignment: Alignment.center,
            )
          : SizedBox(),
    );
  }

  void onPageFinished(String url) async {
    String prefix = "$_redirect_uri/?code=";
    if (url.startsWith(prefix)) {
      flutterWebView.dismiss();
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
      if (mounted) Navigator.of(context).pop(_toast);
    } else if (url == '$_redirect_uri/') {
      flutterWebView.load(_url);
    }
  }
}
