import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class WebPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WebPageState();
  }
}

class _WebPageState extends State<WebPage> {
  final String client_id = 'e9a882a7c659478d99fbd68b93fb2cb7';
  final String client_secret = 'db47ab5ecec04541a82159c709922659 ';
  final String redirect_uri = 'https://baobao1996mn.wordpress.com';

  String _url;
  WebViewController _controller;
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _url =
        "https://api.instagram.com/oauth/authorize/?client_id=$client_id&redirect_uri=$redirect_uri&response_type=code";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          body: Stack(
            children: <Widget>[
              WebView(
              initialUrl: _url,
                onPageFinished: onPageFinished,
              ),
              isLoading
                  ? Container(
                      color: Colors.black12,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator(),
                    )
                  : SizedBox()
            ],
          ),
        ),
        onWillPop: () async => !isLoading);
  }

  void onPageFinished(String url) async {
    String prefix = "https://baobao1996mn.wordpress.com/?code=";
    if (url.startsWith(prefix)) {
      setState(() => this.isLoading = true);

      String code = url.replaceFirst(prefix, "");
      Map map = {
        'client_id': client_id,
        'client_secret': client_secret,
        'grant_type': 'authorization_code',
        'redirect_uri': redirect_uri,
        'code': code
      };
      var response = await http
          .post('https://api.instagram.com/oauth/access_token', body: map);
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        Navigator.of(context).pop(data['access_token']);
      } else {
        print(response.reasonPhrase);
        var snackBar = SnackBar(content: Text(response.reasonPhrase));
        Scaffold.of(context).showSnackBar(snackBar);
      }
      setState(() => this.isLoading = false);
    }
  }
}
