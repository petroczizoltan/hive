part of hive;

typedef ConstructorType = dynamic Function(List<dynamic> parameters);

/// Annotate classes with [HiveType] to generate a `TypeAdapter`.
@optionalTypeArgs
class HiveType<T> {
  /// The typeId of the annotated class.
  final int typeId;

  /// The name of the generated adapter.
  final String? adapterName;

  /// Optional unnamed constructor override.
  ///
  /// Should return the class it annotates either sync or async.
  ///
  /// E.g.:
  ///
  /// ```dart
  /// @HiveType(constructor: Foo.test)
  /// class Foo {
  ///     static Foo test() {
  ///         // ...
  ///     }
  /// }
  ///
  /// @HiveType(constructor: Bar.test)
  /// class Bar {
  ///     static Future<Bar> test() {
  ///         // ...
  ///     }
  /// }
  /// ```
  final ConstructorType? constructor;

  /// If [adapterName] is not set, it'll be `"YourClass" + "Adapter"`.
  /// 
  /// Use [constructor] to use another function to create the instance
  /// instead of the unnamed constructor.
  const HiveType({
    required this.typeId,
    this.adapterName,
    this.constructor,
  });
}
