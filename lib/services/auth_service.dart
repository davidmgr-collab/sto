
class AuthService {
  bool login(String email, String password) {
    return email.trim().toLowerCase() == 'admin@gmail.com' &&
        password == '1234';
  }
}
