/// Thrown when one or more theme configuration validation rules fail.
///
/// This exception aggregates all validation errors to provide a comprehensive
/// diagnostic report to the client rather than failing on the first error.
class ValidationException implements Exception {
  /// The list of validation error messages.
  final List<String> errors;

  /// Creates a [ValidationException] with the collected [errors].
  ///
  /// The list is made unmodifiable to prevent callers from mutating
  /// diagnostic state after the exception is constructed.
  ValidationException(List<String> errors) : errors = List.unmodifiable(errors);

  @override
  String toString() {
    return 'ValidationException: The configuration contains the following errors:\n'
        '${errors.map((e) => '  - $e').join('\n')}';
  }
}
