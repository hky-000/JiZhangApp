import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../data/model.dart';

//账单数据库服务
class BillsDatabaseService {
  String path;

  BillsDatabaseService._();

  static final BillsDatabaseService db = BillsDatabaseService._();

  Database _database;

  //获得数据库
  Future<Database> get database async {
    if (_database != null) return _database;
    //if null then init
    _database = await init();
    return _database;
  }

  //初始化
  init() async {
    String path = await getDatabasesPath();
    path = join(path, 'bills.db');
    print("Entered path $path");

    return await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              'CREATE TABLE Bills (_id INTEGER PRIMARY KEY, title TEXT, date INTEGER, type INTEGER, accountIn TEXT, accountOut TEXT, category1 TEXT, category2 TEXT, member TEXT, value100 INTEGER);');
          print('New table created at $path');
        });
  }

  //获得所有数据
  Future<List<BillsModel>> getBillsFromDB() async {
    final db = await database;
    List<BillsModel> billsList = [];
    List<Map> maps = await db.query('Bills', columns: [
      '_id',
      'title',
      'date',
      'type',
      'accountIn',
      'accountOut',
      'category1',
      'category2',
      'member',
      'value100'
    ]);
    if (maps.length > 0) {
      maps.forEach((map) {
        billsList.add(BillsModel.fromMap(map));
      });
    }
    return billsList;
  }

  Future<List<BillsModel>> getBillsFromDBByDate(
      DateTime dateStart, DateTime dateEnd) async {
    final db = await database;
    List<BillsModel> billsList = [];
    List<Map> maps = await db.query('Bills',
        columns: [
          '_id',
          'title',
          'date',
          'type',
          'accountIn',
          'accountOut',
          'category1',
          'category2',
          'member',
          'value100'
        ],
        where: 'date >= ? AND date <= ?',
        whereArgs: [
          dateStart.millisecondsSinceEpoch,
          dateEnd.millisecondsSinceEpoch
        ]);
    if (maps.length > 0) {
      maps.forEach((map) {
        billsList.add(BillsModel.fromMap(map));
      });
    }
    return billsList;
  }

//根据账户筛选账单
  Future<List<BillsModel>> getBillsFromDBByAccount(
      String accountIn, String accountOut) async {
    final db = await database;
    List<BillsModel> billsList = [];
    List<Map> maps = await db.query('Bills',
        columns: [
          '_id',
          'title',
          'date',
          'type',
          'accountIn',
          'accountOut',
          'category1',
          'category2',
          'member',
          'value100'
        ],
        where: 'accountIn = ? AND accountOut = ?',
        whereArgs: [accountIn, accountOut]);
    if (maps.length > 0) {
      maps.forEach((map) {
        billsList.add(BillsModel.fromMap(map));
      });
    }
    return billsList;
  }

//根据一级分类筛选
  Future<List<BillsModel>> getBillsFromDBByCate1(String category1) async {
    final db = await database;
    List<BillsModel> billsList = [];
    List<Map> maps = await db.query('Bills',
        columns: [
          '_id',
          'title',
          'date',
          'type',
          'accountIn',
          'accountOut',
          'category1',
          'category2',
          'member',
          'value100'
        ],
        where: 'category1 = ?',
        whereArgs: [category1]);
    if (maps.length > 0) {
      maps.forEach((map) {
        billsList.add(BillsModel.fromMap(map));
      });
    }
    return billsList;
  }

//根据二级分类筛选
  Future<List<BillsModel>> getBillsFromDBByCate2(
      String category1, String category2) async {
    final db = await database;
    List<BillsModel> billsList = [];
    List<Map> maps = await db.query('Bills',
        columns: [
          '_id',
          'title',
          'date',
          'type',
          'accountIn',
          'accountOut',
          'category1',
          'category2',
          'member',
          'value100'
        ],
        where: 'category1 = ? AND category2 = ?',
        whereArgs: [category1, category2]);
    if (maps.length > 0) {
      maps.forEach((map) {
        billsList.add(BillsModel.fromMap(map));
      });
    }
    return billsList;
  }

//根据成员筛选
  Future<List<BillsModel>> getBillsFromDBByMember(String member) async {
    final db = await database;
    List<BillsModel> billsList = [];
    List<Map> maps = await db.query('Bills',
        columns: [
          '_id',
          'title',
          'date',
          'type',
          'accountIn',
          'accountOut',
          'category1',
          'category2',
          'member',
          'value100'
        ],
        where: 'member = ?',
        whereArgs: [member]);
    if (maps.length > 0) {
      maps.forEach((map) {
        billsList.add(BillsModel.fromMap(map));
      });
    }
    return billsList;
  }

  //根据ID更新数据
  updateBillInDB(BillsModel updatedBill) async {
    final db = await database;
    await db.update('Bills', updatedBill.toMap(),
        where: '_id = ?', whereArgs: [updatedBill.id]);
    print(
        'Bill updated: ${updatedBill.title} ${updatedBill.value100} ${updatedBill.date}');
  }

  updateMemberInDB(String memberToBeUpdated, String memberNewName) async {
    print ("Will update member: $memberToBeUpdated to $memberNewName");
    final db = await database;
    int count = await db.rawUpdate('UPDATE Bills SET member = ? WHERE member = ?', [memberNewName, memberToBeUpdated]);
    print("updated: $count");
  }

  updateAccountInDB(String accountToBeUpdated, String accountNewName) async {
    print ("Will update member: $accountToBeUpdated to $accountNewName");
    final db = await database;
    int count = await db.rawUpdate('UPDATE Bills SET accountIn = ? WHERE accountIn = ?', [accountNewName, accountToBeUpdated]);
    count += await db.rawUpdate('UPDATE Bills SET accountOut = ? WHERE accountOut = ?', [accountNewName, accountToBeUpdated]);
    print("updated: $count");
  }

  deleteAccountInDB(String accountToBeDeleted) async {
    final db = await database;
    int count = await db.delete('Bills', where: 'accountIn = ? OR accountOut = ?', whereArgs: [accountToBeDeleted, accountToBeDeleted]);
    print("deleted: $count");
  }


  //清空数据
  deleteBillAllInDB() async {
    final db = await database;
    await db.delete('Bills');
    print('All bills deleted');
  }

  //根据BillsModel删除数据
  deleteBillInDB(BillsModel billToDelete) async {
    final db = await database;
    await db.delete('Bills', where: '_id = ?', whereArgs: [billToDelete.id]);
    print('Bill deleted');
  }

  //根据ID删除数据
  deleteBillIdInDB(int id) async {
    final db = await database;
    await db.delete('Bills', where: '_id = ?', whereArgs: [id]);
    print('Bill deleted');
  }

  updateCategory1InDB(String category1ToBeUpdated, String category1NewName) async {
    final db = await database;
    int count = await db.rawUpdate('UPDATE Bills SET category1 = ? WHERE category1 = ?', [category1NewName, category1ToBeUpdated]);
    print("updated: $count");
  }

  updateCategory2InDB(String category2ToBeUpdated, String category2NewName, String fatherCategory) async {
    final db = await database;
    int count = await db.rawUpdate('UPDATE Bills SET category2 = ? WHERE category2 = ? AND category1 = ?', [category2NewName, category2ToBeUpdated, fatherCategory]);
    print("updated: $count");
  }

  deleteCategory1InDB(String category1ToBeDeleted) async {
    final db = await database;
    int count = await db.delete('Bills', where: 'category1 = ?', whereArgs: [category1ToBeDeleted]);
    print("deleted: $count");
  }

  deleteCategory2InDB(String category2ToBeDeleted, String fatherCategory) async {
    final db = await database;
    print(category2ToBeDeleted);
    print(fatherCategory);
    int count = await db.delete('Bills', where: 'category2 = ? AND category1 = ?', whereArgs: [category2ToBeDeleted.toString(), fatherCategory.toString()]);
    print("deleted: $count");
  }

  queryCategory2InDB(String category1, String category2) async {

  }

  //添加一条数据
  Future<BillsModel> addBillInDB(BillsModel newBill) async {
    final db = await database;
    if (newBill.title.trim().isEmpty) newBill.title = 'Untitled Bill';
    int id = await db.transaction((transaction) {
      transaction.rawInsert(
          'INSERT into Bills(title, date, type, accountIn, accountOut, category1, category2, member, value100) VALUES ("${newBill.title}", "${newBill.date.millisecondsSinceEpoch}", "${newBill.type}", "${newBill.accountIn}", "${newBill.accountOut}", "${newBill.category1}", "${newBill.category2}", "${newBill.member}", "${newBill.value100}");');
    });
    newBill.id = id;
    print(
        'Bill added: ${newBill.title} ${newBill.value100} ${newBill.date} type is: ${newBill.type}');
    return newBill;
  }

//根据账户获得数据


}
