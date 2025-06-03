import 'package:redux/redux.dart';
import "package:firebase_auth/firebase_auth.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import "../../models/root_state.dart";
import "../actions/auth_actions.dart";
import "../../services/firebase_service.dart";
import 'package:google_sign_in/google_sign_in.dart';

void authMiddleware(
  Store<RootState> store,
  dynamic action,
  NextDispatcher next,
) {
  if (action is StartLogin) {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: action.email,
          password: action.password,
        )
        .then((credential) async {
          final user = credential.user;
          if (user == null) {
            store.dispatch(AuthFailure("User not found"));
            return;
          }
          if (!user.emailVerified) {
            store.dispatch(AuthFailure("Please verify your email"));
            await FirebaseAuth.instance.signOut();
            return;
          }
          final role = await getUserRole(user.uid);
          store.dispatch(AuthSuccess(user.uid, role.toString()));
        })
        .catchError((error) {
          store.dispatch(AuthFailure(error.message ?? "Login failed"));
        });
  }
  // 👨‍🎓 Student Signup
  else if (action is StartStudentSignup) {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: action.email,
          password: action.password,
        )
        .then((credential) async {
          final uid = credential.user!.uid;
          await credential.user!.sendEmailVerification();

          await FirebaseFirestore.instance.collection("students").doc(uid).set({
            "uid": uid,
            "email": action.email,
            "fullName": action.fullName,
            "phone": action.phone,
            "createdAt": Timestamp.now(),
          });
          if (action.onSuccess != null) {
            action.onSuccess!();
          }
        })
        .catchError((error) {
          store.dispatch(AuthFailure(error.message ?? "Signup failed"));

          // Call onFailure callback if provided
          if (action.onFailure != null) {
            action.onFailure!(error.message ?? "Signup failed");
          }
        });
  }
  // 👨‍🏫 Teacher Signup
  else if (action is StartTeacherSignup) {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: action.email,
          password: action.password,
        )
        .then((credential) async {
          final uid = credential.user!.uid;
          await credential.user!.sendEmailVerification();
          await FirebaseFirestore.instance.collection("teachers").doc(uid).set({
            "uid": uid,
            "email": action.email,
            "fullName": action.fullName,
            "phone": action.phone,
            "coachingName": action.coachingName,
            "coachingAddress": action.coachingAddress,
            "teacherImageUrl": action.teacherImageUrl,
            "coachingImageUrl": action.coachingImageUrl,
            "isApproved": false,
            "createdAt": Timestamp.now(),
          });

          store.dispatch(AuthSuccess(uid, "teacher"));
          if (action.onSuccess != null) {
            action.onSuccess!();
          }
        })
        .catchError((error) {
          store.dispatch(AuthFailure(error.message ?? "Signup failed"));

          // Call onFailure callback if provided
          if (action.onFailure != null) {
            action.onFailure!(error.message ?? "Signup failed");
          }
        });
  } else if (action is LogoutRequestAction) {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    // Sign out from both Firebase and Google
    FirebaseAuth.instance
        .signOut()
        .then((_) async {
          try {
            // Disconnect Google if signed in
            if (await googleSignIn.isSignedIn()) {
              await googleSignIn.signOut();
            }
            store.dispatch(LogoutSuccessAction());
          } catch (e) {
            store.dispatch(
              AuthFailure("Google Sign-Out error: ${e.toString()}"),
            );
          }
        })
        .catchError((error) {
          store.dispatch(AuthFailure(error.toString()));
        });
  } else if (action is StartGoogleSignIn) {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final FirebaseAuth auth = FirebaseAuth.instance;

    googleSignIn
        .signIn()
        .then((GoogleSignInAccount? account) async {
          if (account == null) {
            store.dispatch(AuthFailure("Google Sign-In canceled"));
            return;
          }

          final GoogleSignInAuthentication authData =
              await account.authentication;

          final OAuthCredential credential = GoogleAuthProvider.credential(
            accessToken: authData.accessToken,
            idToken: authData.idToken,
          );

          final UserCredential userCredential = await auth.signInWithCredential(
            credential,
          );
          final user = userCredential.user;

          if (user == null) {
            store.dispatch(AuthFailure("Google sign-in failed"));
            return;
          }

          // Firestore write if new user
          final userDoc = FirebaseFirestore.instance
              .collection("students")
              .doc(user.uid);
          final docSnapshot = await userDoc.get();

          if (!docSnapshot.exists) {
            await userDoc.set({
              "uid": user.uid,
              "email": user.email,
              "fullName": user.displayName,
              "photoURL": user.photoURL,
              "isGoogle": true,
              "createdAt": Timestamp.now(),
            });
          }

          final role = await getUserRole(user.uid);
          store.dispatch(AuthSuccess(user.uid, role.toString()));
        })
        .catchError((error) {
          final errorMessage = error is FirebaseAuthException
              ? error.message
              : "Google Sign-In error";
          store.dispatch(AuthFailure(errorMessage ?? "Unknown error"));
        });
  }
  next(action);
}
