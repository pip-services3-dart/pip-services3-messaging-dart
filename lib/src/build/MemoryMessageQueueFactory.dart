import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../../pip_services3_messaging.dart';

/// Creates [MemoryMessageQueue] components by their descriptors.
/// Name of created message queue is taken from its descriptor.
///
/// See [Factory](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/Factory-class.html)
/// See [MemoryMessageQueue]
///
class MemoryMessageQueueFactory extends MessageQueueFactory {
  static final MemoryQueueDescriptor =
      Descriptor('pip-services', 'message-queue', 'memory', '*', '1.0');

  /// Create a new instance of the factory.
  MemoryMessageQueueFactory() : super() {
    register(MemoryMessageQueueFactory.MemoryQueueDescriptor,
        (locator) => createQueue(locator?.getName()));
  }

  /// Creates a message queue component and assigns its name.
  /// - [name] a name of the created message queue.
  @override
  IMessageQueue createQueue(String name) {
    var queue = MemoryMessageQueue(name);

    if (config_ != null) {
      queue.configure(config_!);
    }
    if (references_ != null) {
      queue.setReferences(references_!);
    }

    return queue;
  }
}
