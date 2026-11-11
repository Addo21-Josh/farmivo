/// Generic repository contract standardizing CRUD operations across the data layer.
abstract class BaseRepository<T, ID> {
  /// Fetches all active entities from the local database.
  Future<List<T>> getAll();

  /// Emits a reactive stream of all active entities whenever database changes occur.
  Stream<List<T>> watchAll();

  /// Fetches a single entity by its unique identifier.
  Future<T?> getById(ID id);

  /// Persists a new entity to the database.
  Future<void> create(T entity);

  /// Updates an existing entity in the database.
  Future<void> update(T entity);

  /// Deletes or voids an entity by its identifier.
  Future<void> delete(ID id);
}
