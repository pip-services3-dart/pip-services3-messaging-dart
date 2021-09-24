import '../../pip_services3_messaging.dart';

/// Creates message queue componens.
///
/// [IMessageQueue]
abstract class IMessageQueueFactory {
  /// Creates a message queue component and assigns its name.
  /// - [name] a name of the created message queue.

  IMessageQueue createQueue(String name);
}
