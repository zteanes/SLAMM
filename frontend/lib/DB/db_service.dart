import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/DB/users.dart';

const String usersCollectionRef = "Users";

class DbService {
  final _firestore = FirebaseFirestore.instance;

  late final CollectionReference _usersRef;

  DbService() {
    _usersRef = _firestore.collection("Users").withConverter<Users>(
        fromFirestore: (snapshots, _) => Users.fromJson(
              snapshots.data()!,
            ),
        toFirestore: (Users, _) => Users.toJson());
  }

  Stream<QuerySnapshot> getUsers() {
    return _usersRef.snapshots();
  }

  void addUser(Users user) async {
    _usersRef.add(user);
  }
}
