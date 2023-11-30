part of hive;

/// Type adapters can be implemented to support non primitive values.
@immutable
abstract class TypeAdapter<T> extends BaseTypeAdapter<T> {
  /// Is called when a value has to be decoded.
  @override
  T read(BinaryReader reader);

  /// Is called when a value has to be encoded.
  @override
  void write(BinaryWriter writer, T obj);
}
