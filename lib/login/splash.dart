import 'package:flutter/material.dart';

import '../service/shared_pref.dart';
import 'login.dart';
import 'register.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  String userNameGet='kangkang';
  AnimationController _controller;
  Animation _animation;

  void IsNewUser() async {
    print("set user flag");
    print('usernameget is $userNameGet');
    isPasswordSet().then((value) {
      value == false
          ? Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (BuildContext context) => RegisterPage()))
          : Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (BuildContext context){
          return LoginPage(
          userNameGet: userNameGet,
        );
        //return NavigationHomeScreen();
      }));
    });
  }
  void getuserName() async{
    userNameGet = await getUserName();
  }
  @override
  void initState() {
    super.initState();
    getuserName();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller);

    /* 动画事件监听器
    监听动画的执行状态，这里监听动画结束的状态，如果结束则执行页面跳转
     */
    _animation.addStatusListener((status){
      if (status == AnimationStatus.completed) {
        IsNewUser();
      }
    });
    // 播放动画
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition( // 透明动画组件
      opacity: _animation, // 执行动画
      child: Image.asset(
        'image/cat.jpg',
        scale: 2.0, // 缩放
        fit: BoxFit.cover,  // 充满容器
      ),
    );
  }
}