import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';


class FirebaseHelper {

  String? getCurrentUserName() {
    String? userName;
    // Get current user name from firebaseAuth actual instance
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
      userName = user.displayName;
    }

    debugPrint('Current user name: $userName');
    return userName;
  }

  String? getCurrentUserEmail() {
    String? userEmail;
    // Get current user email from firebaseAuth actual instance
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
      userEmail = user.email;
    }

    debugPrint('Current user e-mail: $userEmail');
    return userEmail;
  }

  String? getCurrentUserProfileURL() {
    String? URL;
    // Get current user email from firebaseAuth actual instance
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
      URL = user.photoURL;
    }

    debugPrint('Current user profile: $URL');
    return URL;
  }

  String? getCurrentUserUID() {
    String? UID;
    // Get current user email from firebaseAuth actual instance
    User? user = FirebaseAuth.instance.currentUser;
    if(user != null){
      UID = user.uid;
    }

    debugPrint('Current user UID: $UID');
    return UID;
  }

  Future<bool> isLoggedIn() async {
    // Verify if has current user in this instance
    bool logged = false;
    await FirebaseAuth.instance.authStateChanges().listen((User? user){
      if (user == null) {
        debugPrint('User is currently signed out!');
      } else {
        logged = true;
        debugPrint('User is signed in!');
        String name = user.displayName!;
        debugPrint('Current user: $name');
      }
    });
    return logged;
  }

  Future<bool> isVerified() async {
    return await FirebaseAuth.instance.currentUser?.emailVerified ?? false;
  }

  Future<void> linkDefaultProfileIcon() async {
    String iconURL = "https://ui-avatars.com/api/?name=${(await getCurrentUserName() as String).replaceAll(" ", "+")}&background=64C27B&size=128&uppercase=false";
    updateUserProfileURL(iconURL);
  }

  Future<String?> createUser(String name, String email, String password, String? photoURL) async {
    String? error;
    try {
      // Create a user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      //set the user name and photo URL
      await userCredential.user?.updateDisplayName(name);
      if (photoURL != null) {
        await userCredential.user?.updatePhotoURL(photoURL);
      } else {
        String iconURL = "https://ui-avatars.com/api/?name=${(await getCurrentUserName() as String).replaceAll(" ", "+")}&background=64C27B&size=128&uppercase=false";
        await userCredential.user?.updatePhotoURL(iconURL);
      }

      // Get the user ID of the newly created user
      String id = await userCredential.user?.uid ?? "Unknown ID";
      String userName = await userCredential.user?.displayName ?? "Unknown user name";

      // Debug log for the saved user ID
      debugPrint('User created successfully: $id, $userName');
    } on FirebaseAuthException catch (e){
      if (e.code == 'email-already-in-use'){
        error = "Email em uso";
      } else if (e.code == 'invalid-email'){
        error = "Email inválido";
      } else if (e.code == 'network-request-failed'){
        error = "Erro de rede, tente novamente mais tarde";
      } else if (e.code == 'weak-password'){
        error = "Senha fraca";
      } else if (e.code == 'network-request-failed'){
        error = "Erro de rede, tente novamente mais tarde";
      } else if (e.code == 'channel-error'){
        error = "Preencha todos os parâmetros";
      } else {
        error = e.code;
      }
      debugPrint('Error on singIn: $error');
    } catch (e) {
      // Handle errors (e.g., email already in use, invalid password)
      debugPrint('Error on singIn: $e');
    }
    return error;
  }

  Future<String?> login(String email, String password) async {
    String? error;
    try {
      // Create a user with email and password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      // Get the user ID of the newly created user
      String id = userCredential.user?.uid ?? "Unknown ID";
      String userName = userCredential.user?.displayName ?? "Unknown user name";

      // Debug log for the saved user ID
      debugPrint('User logged successfully: $id, $userName');
    } on FirebaseAuthException catch (e){
      if (e.code == 'invalid-email'){
        error = "Email inválido";
      } else if (e.code == 'user-disabled'){
        error = "Usuário correspondente ao e-mail foi desabilitado";
      } else if (e.code == 'network-request-failed'){
        error = "Erro de rede, tente novamente mais tarde";
      } else if (e.code == 'user-not-found'){
        error = "E-mail não encontrado";
      } else if (e.code == 'network-request-failed'){
        error = "Erro de rede, tente novamente mais tarde";
      } else if (e.code == 'INVALID_LOGIN_CREDENTIAL'){
        error = "E-mail ou senha incorretos";
      } else if (e.code == 'invalid-credential'){
        error = "E-mail ou senha incorretos";
      } else if (e.code == 'channel-error'){
        error = "Preencha todos os parâmetros";
      } else {
        error = e.code;
      }
      debugPrint('Error logging in: $error');
    } catch (e) {
      // Handle errors (e.g., email already in use, invalid password)
      debugPrint('Error logging in: $e');
      error = e.toString();
    }
    return error;
  }

  Future<void> verifyEmail(String email) async {
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();
  }

  Future<String?> resetPassword(String email) async {
    String? error;
    // Verify user email from firebaseAuth actual instance
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      debugPrint('Error in reset: $e');
      error = e.toString();
    } catch (e) {
      // Handle errors (e.g., email already in use, invalid password)
      debugPrint('Error in reset: $e');
      error = e.toString();
    }
    return error;
  }

  Future<void> logOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint("Erro ao fazer logout: ${e.toString()}");
    }
  }


  Future<String?> updateUserName(String nome) async {
    String? error;
    try{
      await FirebaseAuth.instance.currentUser?.updateDisplayName(nome);
      await linkDefaultProfileIcon();
    } catch (e) {
      debugPrint("Erro ao fazer atualizar nome de usuário: ${e.toString()}");
      error = e.toString();
    }
    return error;
  }

  Future<void> updateUserEmail(String nome) async {
    try{
      await FirebaseAuth.instance.currentUser?.updateDisplayName(nome);
    } catch (e) {
      debugPrint("Erro ao fazer atualizar nome de usuário: ${e.toString()}");
    }
  }

  Future<void> updateUserProfileURL(String URL) async {
    try{
      await FirebaseAuth.instance.currentUser?.updatePhotoURL(URL);
    } catch (e) {
      debugPrint("Erro ao fazer atualizar foto de perfil: ${e.toString()}");
    }
  }

  Future<String?> updateUserPassword(String email, String oldPassword, String newPassword) async {
    String? error;
    try {
      // Current user instance
      final user = FirebaseAuth.instance.currentUser!;

      // Creating credential to reauthenticate
      final credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Atualizar a senha
      await user.updatePassword(newPassword);

      debugPrint("Senha atualizada com sucesso.");
    } on FirebaseAuthException catch (e) {
      // Lidar com erros do Firebase
      if (e.code == 'wrong-password') {
        debugPrint("A senha antiga está incorreta.");
        error = "A senha antiga está incorreta.";
      } else if (e.code == 'user-not-found') {
        debugPrint("Usuário não encontrado.");
        error = "Usuário não encontrado.";
      } else {
        debugPrint("Erro ao atualizar a senha: ${e.message}");
        error = "Erro ao atualizar a senha: ${e.message}";
      }
    } catch (e) {
      // Lidar com outros erros
      debugPrint("Erro inesperado: ${e.toString()}");
      error = "Erro inesperado: ${e.toString()}";
    }
    return error;
  }
}
