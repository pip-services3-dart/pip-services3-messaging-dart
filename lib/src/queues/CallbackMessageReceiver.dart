import '../../pip_services3_messaging.dart';

/// Wraps message callback into IMessageReceiver
class CallbackMessageReceiver implements IMessageReceiver {
  final Future<void> Function(MessageEnvelope envelope, IMessageQueue queue)
      _callback;

  /// Creates an instance of the CallbackMessageReceiver.
  /// - [callback] a callback function that shall be wrapped into IMessageReceiver
  CallbackMessageReceiver(
      Future<void> Function(MessageEnvelope envelope, IMessageQueue queue)
          callback)
      : _callback = callback;

  /// Receives incoming message from the queue.
  ///
  /// - [envelope]  an incoming message
  /// - [queue]     a queue where the message comes from
  ///
  /// See [MessageEnvelope]
  /// See [IMessageQueue]
  @override
  Future receiveMessage(MessageEnvelope envelope, IMessageQueue queue) async {
    await _callback(envelope, queue);
  }
}
