sealed class AppFailure {
  final String message;
  const AppFailure(this.message);
}

class NetworkFailure extends AppFailure {
  const NetworkFailure() : super('Brak połączenia z internetem.');
}

class ServerFailure extends AppFailure {
  const ServerFailure(super.message);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure(super.message);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure(super.message);
}
