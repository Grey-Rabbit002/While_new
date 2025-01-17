// import 'dart:developer';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:com.example.while_app/resources/components/message/models/chat_user.dart';
// import 'package:com.example.while_app/view_model/providers/auth_provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class UserDataProvider with ChangeNotifier {
//   UserDataProvider(this.ref) {
//     _initData();
//   }
//   ChatUser _userData = ChatUser.empty();
//   final auth = FirebaseAuth.instance.currentUser;
//   String id = 'auth.uid';
//   ChatUser? get userData => _userData;

//   final ChangeNotifierProviderRef ref;
//   void _initData() {
//     log('user id ');
//     final data = ref.watch(currentUserProvider);

//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(auth!.uid)
//         .snapshots()
//         .listen((snapshot) {
//       if (snapshot.exists) {
//         _userData = ChatUser.fromJson(snapshot.data()!);
//         notifyListeners();
//       }
//     });

//     // Listen to changes in the 'following' subcollection
//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(auth!.uid)
//         .collection('following')
//         .snapshots()
//         .listen((snapshot) async {
//       // If there's a change in the count, update the user data
//       if (snapshot.docChanges.isNotEmpty) {
//         _userData.following = snapshot.docs.length;
//         log('updated following');
//         await updateUserData(_userData);
//       }
//     });

//     // Listen to changes in the 'follower' subcollection
//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(auth!.uid)
//         .collection('follower')
//         .snapshots()
//         .listen((snapshot) async {
//       // If there's a change in the count, update the user data
//       if (snapshot.docChanges.isNotEmpty) {
//         _userData.follower = snapshot.docs.length;
//         await updateUserData(_userData);
//       }
//     });
//   }

//   Future<void> updateUserData(ChatUser updatedUser) async {
//     try {
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(auth!.uid)
//           .set(updatedUser.toJson());
//       _userData = updatedUser; // Update local data
//       notifyListeners(); // Notify listeners of the change
//     } catch (e) {
//       log('Error updating user data: $e');
//       // Handle exceptions
//     }
//   }
// }

// final userDataProvider = ChangeNotifierProvider<UserDataProvider>((ref) {
//   log('UserDataProvider');
//   return UserDataProvider(ref);
// });

import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.example.while_app/data/model/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserDataProvider with ChangeNotifier {
  final Ref ref;
  late final StreamSubscription<DocumentSnapshot> _userSubscription;
  late final StreamSubscription<QuerySnapshot> _followingSubscription;
  late final StreamSubscription<QuerySnapshot> _followerSubscription;
  bool _isDisposed = false;

  UserDataProvider(this.ref) {
    _initData();
  }

  ChatUser _userData = ChatUser.empty();
  ChatUser? get userData => _userData;

  void _initData() {
    final auth = FirebaseAuth.instance.currentUser;
    if (auth != null) {
      // User data subscription
      _userSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(auth.uid)
          .snapshots()
          .listen((snapshot) {
        _userUpdateListener(snapshot);
      });

      // Following subscription
      _followingSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(auth.uid)
          .collection('following')
          .snapshots()
          .listen(_followingUpdateListener);

      // Follower subscription
      _followerSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(auth.uid)
          .collection('follower')
          .snapshots()
          .listen(_followerUpdateListener);
    }
  }

  void _userUpdateListener(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.exists && !_isDisposed) {
      _userData = ChatUser.fromJson(snapshot.data()!);
      _safeNotifyListeners();
    }
  }

  void _followingUpdateListener(QuerySnapshot snapshot) {
    if (!_isDisposed) {
      _userData.following = snapshot.docs.length;
      _safeNotifyListeners();
    }
  }

  void _followerUpdateListener(QuerySnapshot snapshot) {
    if (!_isDisposed) {
      _userData.follower = snapshot.docs.length;
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _userSubscription.cancel();
    _followingSubscription.cancel();
    _followerSubscription.cancel();
    super.dispose();
  }

  Future<void> updateUserData(ChatUser updatedUser) async {
    final auth = FirebaseAuth.instance.currentUser;
    if (auth != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(auth.uid)
            .set(updatedUser.toJson());
        _userData = updatedUser;
        _safeNotifyListeners();
      } catch (e) {
        log('Error updating user data: $e');
      }
    }
  }
}

final userDataProvider =
    ChangeNotifierProvider.autoDispose<UserDataProvider>((ref) {
  log('userDataProvider');
  return UserDataProvider(ref);
});
