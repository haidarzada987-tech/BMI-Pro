import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'storage_service.dart';

final unitProvider =
    StateNotifierProvider<UnitNotifier, String>((_) => UnitNotifier());

class UnitNotifier extends StateNotifier<String> {
  UnitNotifier() : super(StorageService.getUnit());

  Future<void> change(String value) async {
    state = value;
    await StorageService.saveUnit(value);
  }
}
