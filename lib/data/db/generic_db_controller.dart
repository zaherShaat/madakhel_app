/// Generic CRUD interface for all repositories.
///
/// This defines the contract that all repositories must follow.
/// Each concrete repository (IncomeTypeRepository, TransactionRepository)
/// extends this and implements specific CRUD operations for its model.
abstract class DbController<T> {
  /// Create a new record
  Future<int> create(T item);

  /// Read a record by ID
  Future<T?> getById(int id);

  /// Read all records
  Future<List<T>> getAll();

  /// Update an existing record
  Future<void> update(T item);

  /// Delete a record by ID
  Future<void> deleteById(int id);
}
