import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nice_share/core/models/peer_model.dart';

part 'permission_state.dart';

class PermissionCubit extends Cubit<Map<PeerModel, PermissionState>> {
  final _map = <PeerModel, PermissionState>{};
  final _askingController = StreamController<PeerModel>.broadcast();

  PermissionCubit([Map<Uint8List, String?>? peersMap]) : super({}) {
    if (peersMap == null) return;
    _map.addAll(
      peersMap.map(
        (key, value) => MapEntry(
          PeerModel(ip: InternetAddress.fromRawAddress(key), name: value),
          PermissionState.granted,
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _askingController.close();
    return super.close();
  }

  @override
  void onChange(Change<Map<PeerModel, PermissionState>> change) {
    final currentAsking = change.currentState.entries
        .where((element) => element.value == .asking)
        .map((e) => e.key)
        .toSet();
    final nextAsking = change.nextState.entries
        .where((element) => element.value == .asking)
        .map((e) => e.key)
        .toSet();

    final newAsking = nextAsking.difference(currentAsking);
    for (final peer in newAsking) {
      _askingController.add(peer);
    }

    super.onChange(change);
  }

  Stream<PeerModel> get permissionRequests => _askingController.stream;

  Future<bool> askPermission(PeerModel peer) async {
    final status = _map[peer]?.status;

    if (status == true) return true;

    _map[peer] = .asking;
    emit(.unmodifiable(_map));
    final answer = await stream
        .firstWhere((e) => e[peer] != .asking)
        .then((value) {
          return value[peer]?.status;
        })
        .timeout(
          .new(seconds: 10),
          onTimeout: () {
            abortPermission(peer);
            return false;
          },
        );
    return answer ?? false;
  }

  void setResult({required PeerModel peer, required bool result}) {
    if (_map[peer] == .asking) {
      _map[peer] = result ? .granted : .denied;
      emit(.unmodifiable(_map));
    }
  }

  void abortPermission(PeerModel peer) {
    _map.remove(peer);
    emit(.unmodifiable(_map));
  }
}
