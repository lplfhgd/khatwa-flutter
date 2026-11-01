import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/linked_child_model.dart';

class LinkedChildStorage {
  LinkedChildStorage({
    FlutterSecureStorage? storage,
  }) : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _parentIdKey = 'linked_parent_id';
  static const _childIdKey = 'linked_child_id';
  static const _childNameKey = 'linked_child_name';

  Future<void> save(LinkedChildModel child) async {
    await Future.wait([
      _storage.write(
        key: _parentIdKey,
        value: child.parentId,
      ),
      _storage.write(
        key: _childIdKey,
        value: child.childId,
      ),
      _storage.write(
        key: _childNameKey,
        value: child.childName,
      ),
    ]);
  }

  Future<LinkedChildModel?> read() async {
    final values = await Future.wait([
      _storage.read(key: _parentIdKey),
      _storage.read(key: _childIdKey),
      _storage.read(key: _childNameKey),
    ]);

    final parentId = values[0];
    final childId = values[1];
    final childName = values[2];

    if (parentId == null ||
        parentId.isEmpty ||
        childId == null ||
        childId.isEmpty ||
        childName == null ||
        childName.isEmpty) {
      return null;
    }

    return LinkedChildModel(
      parentId: parentId,
      childId: childId,
      childName: childName,
    );
  }

  Future<void> clear() async {
    await Future.wait([
      _storage.delete(key: _parentIdKey),
      _storage.delete(key: _childIdKey),
      _storage.delete(key: _childNameKey),
    ]);
  }
}
