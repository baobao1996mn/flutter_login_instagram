import 'package:flutter/material.dart';
import 'package:flutter_login_instagram/web_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
    var result = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => WebPage()));
    if (result != null) {
      var snackBar = SnackBar(content: Text(result));
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }
}
