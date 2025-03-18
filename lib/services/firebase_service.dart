import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<List<Map<String, dynamic>>> getArtikel() async {
    try {
      final QuerySnapshot querySnapshot =
          await _firestore.collection('artikel').get();
      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching articles: $e');
      throw Exception('Failed to load articles');
    }
  }

  static Stream<QuerySnapshot> getArtikelStream() {
    return _firestore.collection('artikel').snapshots();
  }

  static Stream<QuerySnapshot> getKartuSastraStream() {
    return _firestore.collection('kartu_sastra').snapshots();
  }
}
