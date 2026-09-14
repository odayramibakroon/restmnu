import 'package:equatable/equatable.dart';
import '../../domain/entities/restaurant_config.dart';
import '../../domain/entities/branch.dart';

abstract class RestaurantState extends Equatable {
  const RestaurantState();

  @override
  List<Object?> get props => [];
}

class RestaurantInitial extends RestaurantState {}

class RestaurantLoading extends RestaurantState {}

class RestaurantLoaded extends RestaurantState {
  final RestaurantConfig config;
  final List<Branch> branches;

  const RestaurantLoaded({required this.config, required this.branches});

  @override
  List<Object?> get props => [config, branches];
}

class RestaurantError extends RestaurantState {
  final String message;
  const RestaurantError(this.message);

  @override
  List<Object?> get props => [message];
}
