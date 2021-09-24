import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../../pip_services3_messaging.dart';

class TestMessageReceiver implements IMessageReceiver, ICleanable {
  var _messages = <MessageEnvelope>[];

  /// Gets the list of received messages.
  List<MessageEnvelope> get messages => _messages;

  /// Gets the received message count.
  int get messageCount => _messages.length;

  /// Clears component state.
  ///
  /// - [correlationId] 	(optional) transaction id to trace execution through call chain.
  /// Return 			        Future that receives null no errors occured.
  /// Throws error
  @override
  Future clear(String? correlationId) async {
    _messages = [];
  }

  /// Receives incoming message from the queue.
  ///
  /// - [envelope]  an incoming message
  /// - [queue]     a queue where the message comes from
  /// Return        Future that receives null for success.
  /// Throws error
  ///
  /// See [MessageEnvelope]
  /// See [IMessageQueue]
  @override
  Future receiveMessage(MessageEnvelope envelope, IMessageQueue queue) async {
    _messages.add(envelope);
  }
}
