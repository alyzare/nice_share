import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/session_model.dart';

class SessionsCubit extends Cubit<List<SessionModel>> {
  SessionsCubit() : super(List.unmodifiable([]));
}
