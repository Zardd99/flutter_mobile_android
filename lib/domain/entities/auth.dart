export 'auth_credentials.dart';

class AuthCredentials {
  final String email;
  final String password;

  AuthCredentials({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
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

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'password': password, 'role': role};
  }
}

class UpdateProfileData {
  final String? name;
  final String? phone;

  const UpdateProfileData({this.name, this.phone});

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (phone != null) json['phone'] = phone;
    return json;
  }
}

class ChangePasswordData {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordData({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'currentPassword': currentPassword, 'newPassword': newPassword};
  }
}
