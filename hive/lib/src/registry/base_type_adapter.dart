part of hive;

/// Type adapters can be implemented to support non primitive values.
@immutable
abstract class BaseTypeAdapter<T> {
  /// Called for type registration
  int get typeId;

  /// Is called when a value has to be decoded.
  dynamic read(BinaryReader reader);

  /// Is called when a value has to be encoded.
  dynamic write(BinaryWriter writer, T obj);
}
