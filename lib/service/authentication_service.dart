import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.idTokenChanges();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String?> signIn({required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return "Signed in";
    } on FirebaseAuthException catch (e) {
      print(e.code);
      String mymsgerror;
      if (e.code == 'user-not-found') {
        mymsgerror = 'ไม่พบบัญชีผู้ใช้นี้';
      } else if (e.code == 'wrong-password') {
        mymsgerror = 'รหัสผ่านไม่ถูกต้อง';
      } else {
        mymsgerror = 'เกิดข้อผิดพลาด: ${e.message}';
      }
      Fluttertoast.showToast(msg: mymsgerror, gravity: ToastGravity.TOP);
      return null;
    }
  }

  Future<String?> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return "Signed up";
    } on FirebaseAuthException catch (e) {
      print(e.code);
      String mymsgerror = 'เกิดข้อผิดพลาด: ${e.message}';
      Fluttertoast.showToast(msg: mymsgerror, gravity: ToastGravity.TOP);
      return null;
    }
  }
}