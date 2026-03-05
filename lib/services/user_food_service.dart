import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserFoodService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  UserFoodService({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
  })  : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw StateError('User not logged in');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _foods =>
      _db.collection('users').doc(_uid).collection('foods');

  Future<List<Map<String, dynamic>>> getFoods(String category) async {
    final snap = await _foods
        .where('category', isEqualTo: category)
        .orderBy('name')
        .get();

    return snap.docs
        .map((d) => {'id': d.id, ...d.data()})
        .toList(growable: false);
  }

  Future<void> addFood(String category, String name) async {
    await _foods.add({
      'category': category,
      'name': name,
      'enabled': true,
      'weight': 1,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateFoodName(String id, String name) async {
    await _foods.doc(id).update({
      'name': name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> setEnabled(String id, bool enabled) async {
    await _foods.doc(id).update({
      'enabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteFood(String id) async {
    await _foods.doc(id).delete();
  }

  Future<List<String>> getEnabledFoodNames(String category) async {
    final all = await getFoods(category);
    return all
        .where((f) => (f['enabled'] ?? true) == true)
        .map((f) => (f['name'] ?? '').toString())
        .where((name) => name.trim().isNotEmpty)
        .toList();
  }
}