import 'dart:async';

import 'package:hive/hive.dart';
import 'package:hive/src/backend/storage_backend.dart';
import 'package:hive/src/binary/frame.dart';
import 'package:hive/src/box/box_base_impl.dart';
import 'package:hive/src/hive_impl.dart';
import 'package:hive/src/object/hive_object.dart';

/// Not part of public API
class AsyncBoxImpl<E> extends BoxBaseImpl<E> implements AsyncBox<E> {
  /// Not part of public API
  AsyncBoxImpl(
    HiveImpl hive,
    String name,
    KeyComparator? keyComparator,
    CompactionStrategy compactionStrategy,
    StorageBackend backend,
  ) : super(hive, name, keyComparator, compactionStrategy, backend);

  @override
  final bool lazy = false;

  @override
  Iterable<Future<E>> get values {
    checkOpen();

    final values = keystore.getValues();

    return values.map((value) {
      if (value is! Future<E>) {
        return Future.value(value as E);
      }

      return value;
    });
  }

  @override
  Iterable<Future<E>> valuesBetween({dynamic startKey, dynamic endKey}) {
    checkOpen();

    final values = keystore.getValuesBetween(startKey, endKey);

    return values.map((value) {
      if (value is! Future<E>) {
        return Future.value(value as E);
      }

      return value;
    });
  }

  @override
  Future<E>? get(dynamic key, {E? defaultValue}) {
    checkOpen();

    var frame = keystore.get(key);
    if (frame != null) {
      if (frame.value is! Future<E>) {
        return Future.value(frame.value as E);
      }

      return frame.value as Future<E>?;
    } else {
      if (defaultValue != null && defaultValue is HiveObjectMixin) {
        defaultValue.init(key, this);
      }
      return Future.value(defaultValue);
    }
  }

  @override
  Future<E>? getAt(int index) {
    checkOpen();

    final value = keystore.getAt(index)?.value;

    if (value == null) {
      return null;
    }

    if (value is! Future<E>) {
      return Future.value(value as E);
    }

    return value;
  }

  @override
  Future<void> putAll(Map<dynamic, E> kvPairs) async {
    var frames = <Frame>[];
    for (var key in kvPairs.keys) {
      dynamic value = kvPairs[key];

      if (value is Future) {
        value = await value;
      }

      frames.add(Frame(key, value));
    }

    return _writeFrames(frames);
  }

  @override
  Future<void> deleteAll(Iterable<dynamic> keys) {
    var frames = <Frame>[];
    for (var key in keys) {
      if (keystore.containsKey(key)) {
        frames.add(Frame.deleted(key));
      }
    }

    return _writeFrames(frames);
  }

  Future<void> _writeFrames(List<Frame> frames) async {
    checkOpen();

    if (!keystore.beginTransaction(frames)) return;

    try {
      await backend.writeFrames(frames);
      keystore.commitTransaction();
    } catch (e) {
      keystore.cancelTransaction();
      rethrow;
    }

    await performCompactionIfNeeded();
  }

  @override
  Map<dynamic, E> toMap() {
    var map = <dynamic, E>{};
    for (var frame in keystore.frames) {
      map[frame.key] = frame.value as E;
    }
    return map;
  }

  @override
  Future<void> flush() async {
    await backend.flush();
  }
}
