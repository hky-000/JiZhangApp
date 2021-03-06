import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'dart:convert';
import '../const/picker_data.dart';
import '../service/shared_pref.dart';
import 'edit_account_picker_page.dart';
import 'edit_class_picker_page.dart';
import 'edit_member_picker_page.dart';
import 'package:date_format/date_format.dart';
import '../service/database.dart';
import '../data/model.dart';
import 'package:toast/toast.dart';
import '../homepage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../total/account_card.dart';

class CardAddBill extends StatefulWidget {
  @override
  _CardAddBill createState() => _CardAddBill();
}

class _CardAddBill extends State<CardAddBill>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<Tab> tabs = [
    Tab(text: "收入"),
    Tab(text: "支出"),
    Tab(text: "转账"),
  ];

  int moneyInput;
  DateTime dateSelect;
  String classPickerData; //分类picker的所有选项
  List classSelect; //用户选择的分类
  //String classSelectText;
  String classInSelectText ;
  String classOutSelectText ;

  String accountPickerData; //账户picker的所有选项
  List accountSelectIn; //用户选择的账户
  List accountSelectOut;
  String accountInSelectText;
  String accountOutSelectText;

  String memberPickerData; //成员picker的所有选项
  List memberSelect; //用户选择的成员
  String memberSelectText;

  String remark; //备注
  int type;
  //double tempMoney;
  TextEditingController moneyController;

  BillsModel currentbill;

  bool isInit;


  @override
  void initState() {
    super.initState();
    isInit = false;

    moneyInput = 0;
    dateSelect = DateTime.now();
    classSelect = [0, 0];
    accountSelectOut = [0];
    accountSelectIn = [0];
    memberSelect = [0];
    classInSelectText = "未选择,未选择";
    classOutSelectText = "未选择,未选择";
    accountInSelectText = "未选择";
    accountOutSelectText = "未选择";
    memberSelectText = "无成员";
    remark = " ";
    type = 1;
    //tempMoney = 0.00;
    //this.moneyController.text = ("0.00");
    currentbill = BillsModel(
        value100: 0,
        title: "",
        date: DateTime.now(),
        type: 1,
        accountIn: "未选择",
        accountOut: "未选择",
        category1: "未选择",
        category2: "未选择",
        member: "无成员"
    );
    draftToCurrentBill();
  }

  FocusNode blankNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    print(isInit);
    if(isInit == false) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    else {
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(blankNode);
        },
        child: WillPopScope(
          onWillPop: () async =>
              showDialog(
                  context: context,
                  builder: (context) =>
                      AlertDialog(
                        content: Text('是否保存草稿？'),
                          title: Text('提示'), actions: <Widget>[
                        RaisedButton(
                          child: Text('是'),
                          onPressed: () {
                            currentbill.title = remark;
                            currentbill.date = dateSelect;
                            currentbill.type = type;
                            currentbill.accountIn = (type == 2)
                                ? accountInSelectText
                                : "未选择"; //保存草稿时，支出和收入类型时，此项无保存必要
                            currentbill.accountOut = accountOutSelectText;
                            currentbill.category1 =
                            (type == 2) ? "其他" : (type == 0) ? classInSelectText
                                .split(",")[0] : classOutSelectText.split(
                                ",")[0]; //转账时无分类，因此赋默认值
                            currentbill.category2 =
                            (type == 2) ? "转账" : (type == 0) ? classInSelectText
                                .split(",")[1] : classOutSelectText.split(
                                ",")[1];
                            currentbill.member = memberSelectText;
                            currentbill.value100 = moneyInput;
                            setDraft(currentbill);
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            // Navigator.of(context).pushReplacement(MaterialPageRoute(
                            //     builder: (BuildContext context) => NavigationHomeScreen()));
                          },
                        ),
                        RaisedButton(
                          child: Text('否'),
                          onPressed: () {
                            removeDraft();
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            // Navigator.of(context).pushReplacement(MaterialPageRoute(
                            //     builder: (BuildContext context) => NavigationHomeScreen()));
                          },
                        ),
                        RaisedButton(
                          child: Text('取消'),
                          onPressed: () {
                            removeDraft();
                            Navigator.of(context).pop();

                          },
                        )
                      ])),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              title: Text("新建记账", style: TextStyle(color: Theme
                  .of(context)
                  .primaryColor),),
              leading: IconButton(
                onPressed: () async =>
                    showDialog(
                        context: context,
                        builder: (context) =>
                            AlertDialog(
                                content: Text('是否保存草稿？'),
                                title: Text('提示'), actions: <Widget>[
                              RaisedButton(
                                child: Text('是'),
                                onPressed: () {
                                  currentbill.title = remark;
                                  currentbill.date = dateSelect;
                                  currentbill.type = type;
                                  currentbill.accountIn = (type == 2)
                                      ? accountInSelectText
                                      : "未选择"; //保存草稿时，支出和收入类型时，此项无保存必要
                                  currentbill.accountOut = accountOutSelectText;
                                  currentbill.category1 =
                                  (type == 2) ? "其他" : (type == 0) ? classInSelectText
                                      .split(",")[0] : classOutSelectText.split(
                                      ",")[0]; //转账时无分类，因此赋默认值
                                  currentbill.category2 =
                                  (type == 2) ? "转账" : (type == 0) ? classInSelectText
                                      .split(",")[1] : classOutSelectText.split(
                                      ",")[1];
                                  currentbill.member = memberSelectText;
                                  currentbill.value100 = moneyInput;
                                  setDraft(currentbill);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  // Navigator.of(context).pushReplacement(MaterialPageRoute(
                                  //     builder: (BuildContext context) => NavigationHomeScreen()));
                                },
                              ),
                              RaisedButton(
                                child: Text('否'),
                                onPressed: () {
                                  removeDraft();
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  // Navigator.of(context).pushReplacement(MaterialPageRoute(
                                  //     builder: (BuildContext context) => NavigationHomeScreen()));
                                },
                              ),
                              RaisedButton(
                                child: Text('取消'),
                                onPressed: () {
                                  removeDraft();
                                  Navigator.of(context).pop();

                                },
                              )
                            ])),
                icon: Icon(Icons.arrow_back),
                color: Theme.of(context).primaryColor,
              ),
              actions: <Widget>[
                AnimatedContainer(
                  margin: EdgeInsets.fromLTRB(10, 6, 0, 6),
                  //EdgeInsets.only(left: 10),
                  duration: Duration(milliseconds: 200),
                  width: 1 == 1 ? 100 : 0,
                  height: 42,
                  curve: Curves.decelerate,
                  child: RaisedButton.icon(
                    color: Theme
                        .of(context)
                        .accentColor,
                    textColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(100),
                            bottomLeft: Radius.circular(100))),
                    icon: Icon(Icons.done),
                    label: Text(
                      '完成',
                      style: TextStyle(letterSpacing: 1),
                    ),
                    onPressed: () {
                      billConfirm();
                    },
                  ),
                )
              ],
              bottom: TabBar(
                labelColor: Theme
                    .of(context)
                    .primaryColor,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                unselectedLabelColor: Colors.grey,
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                controller: _tabController,
                tabs: tabs,
              ),
            ),
            body: TabBarView(
                controller: _tabController,
                children: tabs.map((Tab tab) {
                  //final String tabType = tab.text.toString();
                  String accountTitle = accountTitleController(tab.text);
                  //type = (tab.text=="收入")?0:(tab.text=="支出")?1:2;  //1:收入 2：支出 3：转账
                  _tabController.addListener(() {
                    if (!_tabController.indexIsChanging) {
                      setState(() {
                        var index = _tabController.index;
                        //print("index : $index");
                        currentbill.type = index;
                        //print("cu.type: ${currentbill.type}");
                        type = index;
                        //print("type: $type");
                      });
                    }
                  });
                  return AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      child: ListView(
                        physics: BouncingScrollPhysics(),
                        children: <Widget>[
                          SizedBox(
                            height: 8,
                          ),
                          //以下输入金钱
                          Card(
                            margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            elevation: 2.0,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(8.0))),
                            child: TextField(
                              controller: moneyController,
                              autofocus: false,
                              decoration: InputDecoration(

                                border: InputBorder.none,
                                // labelText: "金额",
                                // labelStyle: TextStyle(
                                //   fontWeight: FontWeight.w300
                                // ),
                                hintText: "请输入金额 ",
                                hintStyle:
                                TextStyle(
                                    color: Colors.black12, fontSize: 24.0),
                                //prefixIcon: Icon(Icons.attach_money),
                                suffixText: " 元   ",
                                suffixStyle: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold),
                                prefixIcon: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 16.0),
                                  child: FaIcon(
                                    FontAwesomeIcons.yenSign,
                                    color: Theme
                                        .of(context)
                                        .primaryColor,
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 42.0,
                                fontWeight: FontWeight.w400,
                                color: Theme
                                    .of(context)
                                    .primaryColor
                                    .withOpacity(0.7),
                                //wordSpacing: 1.5,
                                height: 1.5,
                              ),
                              maxLines: 1,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                MoneyInputFormatter(),
                                LengthLimitingTextInputFormatter(11)
                                //WhitelistingTextInputFormatter(),
                                //FilteringTextInputFormatter.allow(RegExp("\^(([1-9]{1}\\d*)|([0]{1}))(\\.(\\d){0,2})?\$"))
                              ],
                              onChanged: (money) {
                                print("$money");
                                moneyInput =
                                    (double.parse(money) * 100).round();
                                setState(() {});
                              },
                              textAlign: TextAlign.right,
                            ),
                          ),
                          //以下选择时间
                          Card(
                              margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
                              elevation: 2.0,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(8.0))),
                              child: InkWell(
                                onTap: () {
                                  FocusScope.of(context).requestFocus(blankNode);
                                  DatePicker.showDateTimePicker(context,
                                      showTitleActions: true,
                                      minTime: DateTime(2018, 1, 1, 00, 00),
                                      maxTime: DateTime.now(),
                                      onChanged: (date) {
                                        print('change $date in time zone ' +
                                            date.timeZoneOffset.inHours
                                                .toString());
                                      },
                                      onConfirm: (date) {
                                        setState(() {
                                          dateSelect = date;
                                        });
                                        print('confirm $date');
                                      },
                                      locale: LocaleType.zh);
                                },
                                child: ListTile(
                                  title: Text(
                                    "日期",
                                    style: TextStyle(color: Colors.black45),
                                  ),
                                  subtitle: Text(
                                    formatDate(dateSelect,
                                        [
                                          yyyy,
                                          "年",
                                          m,
                                          "月",
                                          d,
                                          "日  ",
                                          H,
                                          ":",
                                          nn
                                        ]),
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                  leading: Icon(
                                    Icons.date_range,
                                    color: Theme
                                        .of(context)
                                        .primaryColor,
                                  ),
                                ),
                              )),
                          //以下选择分类，账户，成员
                          Card(
                            margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            elevation: 2.0,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(8.0))),
                            child: Column(
                              children: <Widget>[
                                //以下选择分类
                                Visibility(
                                  visible: (tab.text == "收入" ||
                                      tab.text == "支出"), //只有选择“收入”“支出”才会显示
                                  maintainInteractivity: false,
                                  maintainSize: false,
                                  child: Column(
                                    children: <Widget>[
                                      InkWell(
                                        onTap: () async { //点击弹出picker
                                          FocusScope.of(context).requestFocus(blankNode);
                                          classPickerData = (tab.text == "支出")
                                              ?
                                          await getPicker("mOutClassPicker")
                                              : await getPicker(
                                              "mInClassPicker");
                                          if (classPickerData ==
                                              null) { //首次打开picker，需要载入picker初始值
                                            if (tab.text == "支出") {
                                              await setPicker(
                                                  "mOutClassPicker",
                                                  OutClassPickerData); //载入支出的分类
                                              classPickerData =
                                              await getPicker(
                                                  "mOutClassPicker");
                                            }
                                            else if (tab.text == "收入") {
                                              await setPicker(
                                                  "mInClassPicker",
                                                  InClassPickerData); //载入收入的分类
                                              classPickerData =
                                              await getPicker("mInClassPicker");
                                            }
                                          }
                                          classPicker(context, type);
                                          setState(() {});
                                        },
                                        child: ListTile(
                                          title: Text(
                                            "分类",
                                            style: TextStyle(
                                                color: Colors.black45),
                                          ),
                                          subtitle: Text(
                                            (type == 0)
                                                ? "$classInSelectText"
                                                : "$classOutSelectText",
                                            //显示已选择的分类
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 20,
                                            ),
                                          ),
                                          leading: Icon(
                                            Icons.apps,
                                            color: Theme
                                                .of(context)
                                                .primaryColor,
                                          ),
                                          trailing: IconButton(
                                            icon: Icon(
                                              Icons.dehaze,
                                            ),
                                            onPressed: () async { //点击编辑按钮跳转到自定义界面
                                              FocusScope.of(context).requestFocus(blankNode);
                                              classPickerData =
                                              (tab.text == "支出")
                                                  ?
                                              await getPicker("mOutClassPicker")
                                                  : await getPicker(
                                                  "mInClassPicker");
                                              if (classPickerData == null) {
                                                if (tab.text == "支出") {
                                                  await setPicker(
                                                      "mOutClassPicker",
                                                      OutClassPickerData);
                                                  classPickerData =
                                                  await getPicker(
                                                      "mOutClassPicker");
                                                }
                                                else if (tab.text == "收入") {
                                                  await setPicker(
                                                      "mInClassPicker",
                                                      InClassPickerData);
                                                  classPickerData =
                                                  await getPicker(
                                                      "mInClassPicker");
                                                }
                                              }
                                              Navigator.pushNamed(
                                                  context, "/editClassPicker",
                                                  arguments: editClassPickerArguments(
                                                      classPickerData,
                                                      tab.text));
                                              classInSelectText = '未选择,未选择';
                                              classOutSelectText = '未选择,未选择';
                                              setState(() { });
                                            },
                                          ),
                                        ),
                                      ),
                                      Divider(
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),

                                ),

                                //以下选择账户(转出账户)
                                InkWell(
                                  onTap: () async {
                                    FocusScope.of(context).requestFocus(blankNode);
                                    accountPickerData =
                                    await getPicker("maccountPicker");
                                    if (accountPickerData == null) {
                                      await setPicker(
                                          "maccountPicker", AccountPickerData);
                                      accountPickerData =
                                      await getPicker("maccountPicker");
                                    }
                                    accountPickerOut(context); //点击按钮弹出滚动选择框
                                    setState(() {});
                                  },
                                  child: ListTile(
                                    title: Text(
                                      accountTitle,
                                      style: TextStyle(color: Colors.black45),
                                    ),
                                    subtitle: Text(
                                      "$accountOutSelectText",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 20,
                                      ),
                                    ),
                                    leading: Icon(
                                      Icons.account_balance_wallet,
                                      color: Theme
                                          .of(context)
                                          .primaryColor,
                                    ),
                                    trailing: IconButton(
                                      //这是对account picker进行编辑的按钮
                                      icon: Icon(
                                        Icons.dehaze,
                                      ),
                                      onPressed: () async {
                                        FocusScope.of(context).requestFocus(blankNode);
                                        accountPickerData =
                                        await getPicker("maccountPicker");
                                        if (accountPickerData == null) {
                                          await setPicker(
                                              "maccountPicker",
                                              AccountPickerData);
                                          accountPickerData =
                                          await getPicker("maccountPicker");
                                        }
                                        Navigator.pushNamed(
                                            context, "/editAccountPicker",
                                            arguments: editAccountPickerArguments(
                                                accountPickerData));
                                        accountInSelectText = '未选择';
                                        accountOutSelectText = '未选择';
                                        setState(() { });
                                      },
                                    ),
                                  ),
                                ),
                                //以下选择转入账户
                                Visibility(
                                  visible: (tab.text == "转账"), //只有选择“转账”才会显示
                                  maintainInteractivity: false,
                                  maintainSize: false,
                                  child: InkWell(
                                    onTap: () async {
                                      FocusScope.of(context).requestFocus(blankNode);
                                      accountPickerData =
                                      await getPicker("maccountPicker");
                                      if (accountPickerData == null) {
                                        await setPicker(
                                            "maccountPicker",
                                            AccountPickerData);
                                        accountPickerData =
                                        await getPicker("maccountPicker");
                                      }
                                      accountPickerIn(context); //点击按钮弹出滚动选择框
                                      setState(() {});
                                    },
                                    child: ListTile(
                                      title: Text(
                                        "转入账户",
                                        style: TextStyle(color: Colors.black45),
                                      ),
                                      subtitle: Text(
                                        "$accountInSelectText",
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 20,
                                        ),
                                      ),
                                      leading: Icon(
                                        Icons.arrow_forward_ios,
                                        color: Theme
                                            .of(context)
                                            .primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: Colors.black26,
                                ),
                                //以下选择成员
                                InkWell(
                                  onTap: () async {
                                    FocusScope.of(context).requestFocus(blankNode);
                                    memberPickerData =
                                    await getPicker("mmemberPicker");
                                    if (memberPickerData == null) {
                                      await setPicker(
                                          "mmemberPicker", MemberPickerData);
                                      memberPickerData =
                                      await getPicker("mmemberPicker");
                                    }
                                    memberPicker(context);
                                  },
                                  child: ListTile(
                                    title: Text(
                                      "成员",
                                      style: TextStyle(color: Colors.black45),
                                    ),
                                    subtitle: Text(
                                      "$memberSelectText",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 20,
                                      ),
                                    ),
                                    leading: Icon(
                                      Icons.account_circle,
                                      color: Theme
                                          .of(context)
                                          .primaryColor,
                                    ),
                                    trailing: IconButton(
                                      //这是对account picker进行编辑的按钮
                                      icon: Icon(
                                        Icons.dehaze,
                                      ),
                                      onPressed: () async {
                                        FocusScope.of(context).requestFocus(blankNode);
                                        memberPickerData =
                                        await getPicker("mmemberPicker");
                                        if (memberPickerData == null) {
                                          await setPicker(
                                              "mmemberPicker",
                                              MemberPickerData);
                                          memberPickerData =
                                          await getPicker("mmemberPicker");
                                        }
                                        Navigator.pushNamed(
                                            context, "/editMemberPicker",
                                            arguments: editMemberPickerArguments(
                                                memberPickerData)).then((value) => null);
                                        memberSelectText = '未选择';
                                        setState(() { });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //以下输入备注
                          Card(
                            margin: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            elevation: 2.0,
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(8.0))),
                            child: TextField(
                              autofocus: false,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: "备注",
                                labelStyle: TextStyle(
                                  fontWeight: FontWeight.w300,
                                  fontSize: 16,
                                ),
                                hintText: "请输入备注 ",
                                hintStyle:
                                TextStyle(
                                    color: Colors.black12, fontSize: 15.0),
                                //prefixIcon: Icon(Icons.attach_money),
                                //suffixText: " 元   ",
                                suffixStyle: TextStyle(
                                    color: Colors.black45,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                                // prefixIcon: Icon(
                                //   Icons.border_color,
                                //   color: Theme.of(context).primaryColor,
                                // ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      start: 16, end: 32),
                                  child: Icon(
                                    //Icons.arrow_forward_ios,
                                    Icons.border_color,
                                    color: Theme
                                        .of(context)
                                        .primaryColor,
                                  ),
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                                //wordSpacing: 1.5,
                                height: 1.5,
                              ),
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(99)
                              ],
                              maxLines: 3,
                              keyboardType: TextInputType.name,
                              textInputAction: TextInputAction.done,
                              onChanged: (input) {
                                //print("$money");
                                remark = input;
                              },
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ));
                }).toList()),
          ),
        ),
      );
    }


  }

  classPicker(BuildContext context, int type) {
    Picker(
        adapter: PickerDataAdapter<String>(
            pickerdata:
            JsonDecoder().convert(classPickerData)), //json:string to list
        changeToFirst: true,
        hideHeader: false,
        selectedTextStyle: TextStyle(color: Theme.of(context).primaryColor),
        onConfirm: (Picker picker, List value) {
          setState(() {
            //页面刷新，显示出用户的选项
            classSelect = value;
            if(type==0) {
              classInSelectText = removeBrackets(picker.adapter.text);//用户选中的收入分类
            }
            else if(type==1) {
              classOutSelectText = removeBrackets(picker.adapter.text);//用户选中的支出分类
            }
            //print(classSelectText.split(",")[0]);
          });
          //print(JsonDecoder().convert(ClassPickerData));
          //print(picker.adapter.text);
        }).showModal(this.context); //_scaffoldKey.currentState);
  }

  accountPickerOut(BuildContext context) {
    List accountPickerDataTemp = JsonDecoder()
        .convert(accountPickerData);
    if(type==2) {
      accountPickerDataTemp.remove(accountInSelectText);
    }
    Picker(
        adapter: PickerDataAdapter<String>(
            pickerdata: accountPickerDataTemp), //传入可选项，json:string to list
        changeToFirst: true,
        hideHeader: false,
        selectedTextStyle: TextStyle(color: Theme.of(context).primaryColor),
        onConfirm: (Picker picker, List value) {
          setState(() {
            accountSelectOut = value;
            accountOutSelectText = removeBrackets(picker.adapter.text) ;//用户选中的账户
          });
        }).showModal(this.context); //_scaffoldKey.currentState);
  }

  //选择转入账户
  accountPickerIn(BuildContext context) {
    List accountPickerDataTemp = JsonDecoder()
        .convert(accountPickerData);

    accountPickerDataTemp.remove(accountOutSelectText);
    Picker(
        adapter: PickerDataAdapter<String>(
            pickerdata: accountPickerDataTemp), //传入可选项，json:string to list
        changeToFirst: true,
        hideHeader: false,
        selectedTextStyle: TextStyle(color: Theme.of(context).primaryColor),
        onConfirm: (Picker picker, List value) {
          setState(() {
            accountSelectIn = value;
            accountInSelectText = removeBrackets(picker.adapter.text);//用户选中的账户
          });
          print(value.toString());
          print(picker.adapter.text);
        }).showModal(this.context); //_scaffoldKey.currentState);
  }

  //选择成员
  memberPicker(BuildContext context) {
    Picker(
        adapter: PickerDataAdapter<String>(
            pickerdata: JsonDecoder()
                .convert(memberPickerData)), //传入可选项，json:string to list
        changeToFirst: true,
        hideHeader: false,
        selectedTextStyle: TextStyle(color: Theme.of(context).primaryColor),
        onConfirm: (Picker picker, List value) {
          setState(() {
            memberSelect = value;
            memberSelectText = removeBrackets(picker.adapter.text);//用户选中的成员
          });
          print(value.toString());
          print(picker.adapter.text);
        }).showModal(this.context);
  }

  String accountTitleController(String type) {
    if (type == "转账") {
      return "转出账户";
    } else {
      return "账户";
    }
  }

  void billConfirm () async {  //点击确认键的逻辑（数据合法性和写入数据库）
    writeCurrentBill ();
    removeDraft();
    print("金额：$currentbill.value100   分类：${currentbill.category1} ${currentbill.category2}");
    print("账户：${currentbill.accountOut} ${currentbill.accountIn}    成员：${currentbill.member}");
    print("日期：${currentbill.date}   备注：${currentbill.title}   记账类型：${currentbill.type}");
    if (isLeagal() ){
      Toast.show("记账成功", context);
      //var bill =
      await BillsDatabaseService.db.addBillInDB(currentbill);
      Navigator.of(context).pop();  //记账成功后退出记账界面
      //  Navigator.of(context).pushReplacement(
      //      MaterialPageRoute(builder: (BuildContext context) => NavigationHomeScreen()));
    } else {
      if(currentbill.value100 < 1) {Toast.show("请输入金额", context);}
      else if (!(type==2 || currentbill.category1!="未选择")) {Toast.show("请选择分类", context);}
      else if (currentbill.accountOut=="未选择") {Toast.show("请选择账户", context);}
      else if (!(type!=2 || currentbill.accountIn!="未选择")) {Toast.show("请选择账户", context);}
      else if (currentbill.value100 > 99999999) {Toast.show("金额过大", context);}
      //Toast.show("不合法！", context);
    }
  }

  bool isLeagal() {  //判断输入是否合法
    return currentbill.value100 > 0 //金额
        && (type==2 || currentbill.category1!="未选择")  //收入支出时要填分类
        && currentbill.accountOut!="未选择"  //必填账户
        && (type!=2 || currentbill.accountIn!="未选择")
        && currentbill.value100 <= 99999999
    ;  //转账时必填转入账户
  }

  writeCurrentBill () {
    currentbill.title = remark;
    currentbill.date = dateSelect;
    currentbill.type = type;
    currentbill.accountIn = (type==2)?accountInSelectText:accountOutSelectText; //不是转账时，转出账户和转入账户相同
    currentbill.accountOut = accountOutSelectText;
    currentbill.category1 = (type==2)?"其他":(type==0)?classInSelectText.split(",")[0]:classOutSelectText.split(",")[0]; //转账时无分类，因此赋默认值
    currentbill.category2 = (type==2)?"转账":(type==0)?classInSelectText.split(",")[1].substring(1):classOutSelectText.split(",")[1].substring(1);
    currentbill.member = memberSelectText;
    currentbill.value100 = moneyInput;
  }

  draftToCurrentBill() async {
    bool isDraft = await isDraftSet();
    print("tag1");
    if (isDraft) {
      currentbill = await getDraft();
      print("tag2");
      if(currentbill.type==0) {classInSelectText = "${currentbill.category1},${currentbill.category2}";}
      else if(currentbill.type==1) {classOutSelectText = "${currentbill.category1},${currentbill.category2}";}
      accountInSelectText = "${currentbill.accountIn}";
      accountOutSelectText = "${currentbill.accountOut}";
      memberSelectText = "${currentbill.member}";
      remark = "${currentbill.title}";
      moneyInput = currentbill.value100;
      dateSelect = currentbill.date;
      String toInsert =(currentbill.value100 > 99)?
      currentbill.value100.toString().substring(0, currentbill.value100.toString().length-2)
          + '.'
          + currentbill.value100.toString().substring(currentbill.value100.toString().length-2, currentbill.value100.toString().length):
      (currentbill.value100 > 9) ? '0.' + currentbill.value100.toString() :'0.0' + currentbill.value100.toString();
      moneyController = new TextEditingController(text: toInsert);
      _tabController = TabController(length: tabs.length, vsync: this, initialIndex: currentbill.type);
    } else {
      moneyController = new TextEditingController();
      _tabController = TabController(length: tabs.length, vsync: this, initialIndex: 1);
    }
    print("tag3");

    isInit = true;
    print("tag4");
    setState(() { });
  }

  //退出时询问是否保存草稿
  Widget isSaveDraft () {
    return AlertDialog(
        content: Text('是否保存草稿？'),
        title: Text('提示'), actions: <Widget>[
      RaisedButton(
        child: Text('是'),
        onPressed: () {
          currentbill.title = remark;
          currentbill.date = dateSelect;
          currentbill.type = type;
          currentbill.accountIn = (type == 2)
              ? accountInSelectText
              : "未选择"; //保存草稿时，支出和收入类型时，此项无保存必要
          currentbill.accountOut = accountOutSelectText;
          currentbill.category1 =
          (type == 2) ? "其他" : (type == 0) ? classInSelectText
              .split(",")[0] : classOutSelectText.split(
              ",")[0]; //转账时无分类，因此赋默认值
          currentbill.category2 =
          (type == 2) ? "转账" : (type == 0) ? classInSelectText
              .split(",")[1] : classOutSelectText.split(
              ",")[1];
          currentbill.member = memberSelectText;
          currentbill.value100 = moneyInput;
          setDraft(currentbill);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          // Navigator.of(context).pushReplacement(MaterialPageRoute(
          //     builder: (BuildContext context) => NavigationHomeScreen()));
        },
      ),
      RaisedButton(
        child: Text('否'),
        onPressed: () {
          removeDraft();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          // Navigator.of(context).pushReplacement(MaterialPageRoute(
          //     builder: (BuildContext context) => NavigationHomeScreen()));
        },
      ),
      RaisedButton(
        child: Text('取消'),
        onPressed: () {
          removeDraft();
          Navigator.of(context).pop();

        },
      )
    ]);
  }




  String removeBrackets(String value) {  //去除字符串两端的括号
    value = value.substring(1,value.length-1);
    return value;
  }
}

//限制金额只能输入符合规格的格式
class MoneyInputFormatter extends TextInputFormatter {
  static final RegExp regExp =
  RegExp("\^(([1-9]\\d{0,5})|([0]))(\\.(\\d){0,2})?\$");
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // TODO: implement formatEditUpdate
    return oldValue.text.length > newValue.text.length ||
        regExp.hasMatch(newValue.text.toString())
        ? newValue
        : oldValue;
    //
  }
}
