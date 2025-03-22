import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:SLAMM/DB/users.dart';

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

  Stream<DocumentSnapshot> getUser(userid) {
    return _usersRef.doc(userid).snapshots();
  }

  void addUser(Users user) async {
    _usersRef.add(user);
  }
}
