import 'package:sqflite/sqflite.dart';
import 'Database.dart';

UsersDB db = UsersDB();

Future<List<Map>> getUserData(String userId) async {
  List<Map> response =
      await db.readData("SELECT * FROM Users WHERE ID = '${userId}'");
  return response;
}

Future<void> deleteUser() async {
  await db.deleteData("DELETE FROM Users");
}

Future<void> insertUser(String ID, String firstName, String lastName,
    String phone, String emailDB) async {
  await db.insertData('''
            INSERT INTO Users (ID,firstName,lastName,phone,email)
             VALUES ('$ID','$firstName','$lastName','$phone','$emailDB')
                      ''');
}

Future<void> updateUser(String ID, String firstName, String lastName,
    String phone, String emailDB) async {
  await db.updateData('''
                    UPDATE Users
                    SET 'firstName' = '$firstName','lastName' = '$lastName' , 'phone' = '$phone'
                    WHERE ID = '${ID}'    
                    ''');
}
