/// Defines an interface for message queue connections
abstract class IMessageQueueConnection {
  /// Reads a list of registered queue names.
  /// If connection doesn't support this function returnes an empty list.
  /// Кeturns a list with registered queue names.
  Future<List<String>> readQueueNames();

  /// Creates a message queue.
  /// If connection doesn't support this function it exists without error.
  /// - [name] the name of the queue to be created.
  Future<void> createQueue(String name);

  /// Deletes a message queue.
  /// If connection doesn't support this function it exists without error.
  /// - [name] the name of the queue to be deleted.
  Future<void> deleteQueue(String name);
}
