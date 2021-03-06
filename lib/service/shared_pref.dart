import 'dart:convert';

import 'package:flutter_jizhangapp/data/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_string_encryption/flutter_string_encryption.dart';
import 'package:provider/provider.dart';


//文本密码和shared preferences 的交互
Future<String> getPassWord() async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  String pw = sharedPref.getString('mpassWord');
  print('password in Sp');
  print(pw);
  return sharedPref.getString('mpassWord');
}

//检测是否已经设置密码
Future<bool> isPasswordSet() async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  bool flag = await sharedPref.containsKey('encrypted');
  return flag;
}

//设置密码
Future<Null> setEncryptedPassword(String rawPassword) async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  final cryptor = new PlatformStringCryptor();
  String key = await cryptor.generateRandomKey();
  await sharedPref.setString('key', key);
  String encrypted = await cryptor.encrypt(rawPassword, key);
  await sharedPref.setString('encrypted', encrypted);
}

//校验密码
Future<bool> isPasswordValid(String rawPassword) async {
  print("input: $rawPassword");
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  final cryptor = new PlatformStringCryptor();
  String key = await sharedPref.getString('key');
  String encrypted = await sharedPref.getString('encrypted');
  String decrypted = await cryptor.decrypt(encrypted, key);
  // print(await cryptor.decrypt(encrypted, key));
  // cryptor.decrypt(encrypted, key).then((decrypted) {
  //   print(decrypted == rawPassword);
  //   return(true);
  // });
  return (decrypted == rawPassword);
}

Future<Null> removePassword() async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  await sharedPref.remove('key');
  await sharedPref.remove('encrypted');
}

Future<Null> setPassWord(String val) async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  sharedPref.setString('mpassWord', val);
}

//图形密码和shared preferences 的交互
Future<String> getGraphicalPassWord() async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  return sharedPref.getString('mGrapthicalPassWord');
}

Future<Null> setGraphicalPassWord(String val) async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  sharedPref.setString('mGrapthicalPassWord', val);
}

//all
Future<String> getPicker(String key) async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  return sharedPref.getString(key);
}

Future<Null> setPicker(String key, String val) async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  sharedPref.setString(key, val);
}

Future<Null> setDraft(BillsModel billsModel) async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  sharedPref.setString('mDraft', JsonEncoder().convert(billsModel.toMap()));
  print(JsonEncoder().convert(billsModel.toMap()));
}

Future<BillsModel> getDraft() async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  BillsModel draft = BillsModel.fromMap(JsonDecoder().convert(sharedPref.getString('mDraft')));
  print(draft.toMap());
  return draft;
}

//判断之前是否有存草稿
Future<bool> isDraftSet() async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  bool flag = await sharedPref.containsKey('mDraft');
  return flag;
}

//清除草稿
Future<Null> removeDraft() async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  await sharedPref.remove('mDraft');
}

Future<String> getColorKey() async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  String colorKey = await sharedPref.getString('colorKey');
  if (colorKey == null)  {
    print("color key not found");
    return 'blue';
  }
  print("get color key: $colorKey");
  return colorKey;
}

Future<Null> setColorKey(String key) async {
  print("set color key: $key");
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  await sharedPref.setString('colorKey', key);
}

Future<Null> removeColorKey() async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  await sharedPref.remove('colorKey');
}

//用户名与shared preferences的交互
Future<String> getUserName() async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  String pw = sharedPref.getString('muserName');
  print('username in Sp');
  print(pw);
  return sharedPref.getString('muserName');
}
Future<Null> setUserName(String val) async {
  SharedPreferences sharedPref = await SharedPreferences.getInstance();
  sharedPref.setString('muserName', val);
}
//判断是否是可用密码
bool isLoginPassword(String input) {
//RegExp mobile = new RegExp(r"(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,18}$");
  RegExp mobile = new RegExp(r"[A-Za-z0-9]{8,18}$");
  return mobile.hasMatch(input);
}
