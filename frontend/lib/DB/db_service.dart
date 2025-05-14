/// This file contains the functionality that assists in the access and manipulation of the
/// database. This includes the ability to add a user, update a user, and get a user.
/// 
/// This file is not required to access the db but is used to assist.
///
/// Authors: Zach Eanes and Alex Charlot
/// Date: 04/14/2025
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:SLAMM/DB/users.dart';

const String usersCollectionRef = "Users";

class DbService {
  /// creates a new instance of the db
  final _firestore = FirebaseFirestore.instance;
  /// creates a variable that will reference the users collection in the db
  late final CollectionReference _usersRef;

  /// uses instance of the db service and sets the users collection reference
  DbService() {
    _usersRef = _firestore.collection("Users").withConverter<Users>(
        fromFirestore: (snapshots, _) => Users.fromJson(
              snapshots.data()!,
            ),
        toFirestore: (Users, _) => Users.toJson());
  }


  /// gets the users collection reference using the [userid] that is unique to each user 
  Stream<DocumentSnapshot> getUser(userid) {
    return _usersRef.doc(userid).snapshots();
  }

  /// adds a user to the users collection using the [user] object that is passed in
  void addUser(Users user) async {
    _usersRef.add(user);
  }

  /// updates the users field in the users collection using the [uid] that is unique to each user
  /// and the [field] that is being updated. The [data] is the new data that is being added to the 
  /// field
  void updateArray (String uid, String field, String data,) async {
    _usersRef.doc(uid).update({
      field : FieldValue.arrayUnion([data]),
    });
  }
}
