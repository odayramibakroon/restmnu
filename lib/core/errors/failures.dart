import 'package:equatable/equatable.dart';

import 'error_messages.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  ServerFailure([String? message])
    : super(message ?? ErrorMessages.message(AppErrorKey.server));
}

class LocationFailure extends Failure {
  LocationFailure([String? message])
    : super(message ?? ErrorMessages.message(AppErrorKey.location));
}

class WhatsAppFailure extends Failure {
  WhatsAppFailure([String? message])
    : super(message ?? ErrorMessages.message(AppErrorKey.whatsappSend));
}

class StorageFailure extends Failure {
  StorageFailure([String? message])
    : super(message ?? ErrorMessages.message(AppErrorKey.storage));
}
