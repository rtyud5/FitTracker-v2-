abstract class AuthGateway {
  Future<AuthGatewayLoginResult> login({
    required String username,
    required String password,
  });

  Future<AuthGatewayRegisterResult> register({
    required String username,
    required String password,
    required Map<String, dynamic> localProfile,
  });

  Future<void> logout();
}

class AuthGatewayLoginResult {
  final bool isSuccess;
  final String? message;
  final String? userId;
  final String? username;
  final Map<String, dynamic>? userData;

  const AuthGatewayLoginResult({
    required this.isSuccess,
    this.message,
    this.userId,
    this.username,
    this.userData,
  });
}

class AuthGatewayRegisterResult {
  final bool isSuccess;
  final String? message;
  final String? userId;
  final String? username;

  const AuthGatewayRegisterResult({
    required this.isSuccess,
    this.message,
    this.userId,
    this.username,
  });
}
