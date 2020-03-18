import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:wanandroidflutter/page/account/login_form.dart';
import 'package:wanandroidflutter/page/account/register_form.dart';

class LoginPage extends StatelessWidget {
  var _pageController = new PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          child: FlareActor(
            "assets/flrs/loginbg.flr",
            animation: "wave",
            fit: BoxFit.fill,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 20,
              child: null,
            ),
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(top: 20),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        )),
                    Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: new Image(
                          image: AssetImage("assets/img/logo.png"),
                          width: 60,
                          height: 60,
                        )),
                    new Container(
                      height: 20,
                    ),
                  ],
                )),
            Expanded(
              child: new PageView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return index == 0
                      ? new LoginForm(_pageController)
                      : new RegisterForm(_pageController);
                },
                itemCount: 2,
                controller: _pageController,
              ),
              flex: 4,
            )
          ],
        )
      ],
    );
  }
}