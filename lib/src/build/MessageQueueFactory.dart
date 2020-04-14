import 'package:pip_services3_components/pip_services3_components.dart';
import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../queues/MemoryMessageQueue.dart';

/// Creates [MemoryMessageQueue] components by their descriptors.
/// Name of created message queue is taken from its descriptor.
///
/// See [Factory]
/// See [MemoryMessageQueue]

class MessageQueueFactory extends Factory {
  static final descriptor =
      Descriptor('pip-services', 'factory', 'message-queue', 'default', '1.0');
  static final MemoryQueueDescriptor =
      Descriptor('pip-services', 'message-queue', 'memory', '*', '1.0');

  /// Create a new instance of the factory.

  MessageQueueFactory() : super() {
    register(MessageQueueFactory.MemoryQueueDescriptor, (locator) {
      return MemoryMessageQueue(locator.getName());
    });
  }
}
