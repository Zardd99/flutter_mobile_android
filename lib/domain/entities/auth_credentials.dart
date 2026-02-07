class AuthCredentials {
  final String email;
  final String password;

  AuthCredentials({required this.email, required this.password});
}

class RegisterData {
  final String name;
  final String email;
  final String password;
  final String role;

  RegisterData({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
}

class ChangePasswordData {
  final String currentPassword;
  final String newPassword;

  ChangePasswordData({
    required this.currentPassword,
    required this.newPassword,
  });
}
