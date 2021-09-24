import 'dart:async';

import 'package:pip_services3_commons/pip_services3_commons.dart';

import '../../pip_services3_messaging.dart';

/// Message queue that caches received messages in memory to allow peek operations
/// that may not be supported by the undelying queue.
///
/// This queue is users as a base implementation for other queues
abstract class CachedMessageQueue extends MessageQueue implements ICleanable {
  bool _autoSubscribe = false;
  var _messages = <MessageEnvelope?>[];
  IMessageReceiver? _receiver;

  /// Creates a new instance of the persistence component.
  ///
  /// - [name]  (optional) a queue name
  /// - [capabilities] (optional) a capabilities of this message queue
  CachedMessageQueue(String? name, MessagingCapabilities? capabilities)
      : super(name, capabilities);

  /// Configures component by passing configuration parameters.
  ///
  /// - [config] configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    super.configure(config);

    _autoSubscribe =
        config.getAsBooleanWithDefault('options.autosubscribe', _autoSubscribe);
  }

  /// Opens the component.
  ///
  /// - [correlationId] (optional) transaction id to trace execution through call chain.
  @override
  Future open(String? correlationId) async {
    if (isOpen()) {
      return;
    }

    try {
      if (_autoSubscribe) {
        await subscribe(correlationId);
      }

      logger.debug(correlationId, 'Opened queue ' + getName());
    } catch (ex) {
      await close(correlationId);
    }
  }

  /// Closes component and frees used resources.
  ///
  /// - [correlationId] (optional) transaction id to trace execution through call chain.
  @override
  Future close(String? correlationId) async {
    if (!isOpen()) {
      return Future.value(null);
    }

    try {
      // Unsubscribe from the broker
      await unsubscribe(correlationId);
    } finally {
      _messages = [];
      _receiver = null;
    }
  }

  /// Subscribes to the message broker.
  ///
  /// - [correlationId] (optional) transaction id to trace execution through call chain.
  Future subscribe(String? correlationId);

  /// Unsubscribes from the message broker.
  ///
  /// - [correlationId] (optional) transaction id to trace execution through call chain.
  Future unsubscribe(String? correlationId);

  /// Clears component state.
  ///
  /// - [correlationId] (optional) transaction id to trace execution through call chain.
  @override
  Future<void> clear(String? correlationId) async {
    _messages = [];
  }

  /// Reads the current number of messages in the queue to be delivered.
  ///
  /// Returns a number of messages in the queue.
  @override
  Future<int> readMessageCount() async {
    return _messages.length;
  }

  /// Peeks a single incoming message from the queue without removing it.
  /// If there are no messages available in the queue it returns null.
  ///
  /// - [correlationId] (optional) transaction id to trace execution through call chain.
  /// Returns a peeked message or `null`.
  @override
  Future<MessageEnvelope?> peek(String? correlationId) async {
    checkOpen(correlationId);

    // Subscribe to topic if needed
    await subscribe(correlationId);

    // Peek a message from the top
    MessageEnvelope? message;
    if (_messages.isNotEmpty) {
      message = _messages[0];
    }

    if (message != null) {
      logger.trace(message.correlation_id, 'Peeked message %s on %s',
          [message, getName()]);
    }

    return message;
  }

  /// Peeks multiple incoming messages from the queue without removing them.
  /// If there are no messages available in the queue it returns an empty list.
  ///
  /// - [correlationId] (optional) transaction id to trace execution through call chain.
  /// - [messageCount] a maximum number of messages to peek.
  /// Returns a list with peeked messages.
  @override
  Future<List<MessageEnvelope?>> peekBatch(
      String? correlationId, int messageCount) async {
    checkOpen(correlationId);

    // Subscribe to topic if needed
    await subscribe(correlationId);

    // Peek a batch of messages
    var messages = _messages.getRange(0, messageCount).toList();

    logger.trace(correlationId, 'Peeked %d messages on %s',
        [messages.length, getName()]);

    return messages;
  }

  /// Receives an incoming message and removes it from the queue.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [waitTimeout]       a timeout in milliseconds to wait for a message to come.
  /// Returns a received message or `null`.
  @override
  Future<MessageEnvelope?> receive(
      String? correlationId, int waitTimeout) async {
    checkOpen(correlationId);

    // Subscribe to topic if needed
    await subscribe(correlationId);

    var checkIntervalMs = 100;
    var elapsedTime = 0;

    // Get message the the queue
    var message = _messages.isNotEmpty ? _messages.removeAt(0) : null;

    while (elapsedTime < waitTimeout && message == null) {
      // Wait for a while
      await Future.delayed(Duration(milliseconds: checkIntervalMs), () {});
      elapsedTime += checkIntervalMs;

      // Get message the the queue
      message = _messages.isNotEmpty ? _messages.removeAt(0) : null;
    }

    return message;
  }

  /// Sends a message to a receiver.
  ///
  /// - [receiver] receiver of the message.
  /// - [message] message to be sent.
  Future sendMessageToReceiver(
      IMessageReceiver? receiver, MessageEnvelope? message) async {
    var correlationId = message != null ? message.correlation_id : null;
    if (message == null || receiver == null) {
      logger.warn(correlationId, 'Message was skipped.');
      return;
    }

    try {
      await _receiver!.receiveMessage(message, this);
    } catch (ex) {
      logger.error(
          correlationId, ex as Exception, 'Failed to process the message');
    }
  }

  /// Listens for incoming messages and blocks the current thread until queue is closed.
  ///
  /// - [correlationId] (optional) transaction id to trace execution through call chain.
  /// - [receiver] a receiver to receive incoming messages.
  ///
  /// See [IMessageReceiver]
  /// See [receive]
  @override
  void listen(String? correlationId, IMessageReceiver receiver) {
    if (!isOpen()) {
      return;
    }

    var listenFunc = () async {
      // Subscribe to topic if needed
      await subscribe(correlationId);

      logger.trace(null, 'Started listening messages at %s', [getName()]);

      // Resend collected messages to receiver
      while (isOpen() && _messages.isNotEmpty) {
        var message = _messages.isNotEmpty ? _messages.removeAt(0) : null;
        if (message != null) {
          await sendMessageToReceiver(receiver, message);
        }
      }

      // Set the receiver
      if (isOpen()) {
        _receiver = receiver;
      }
    };
    listenFunc();
  }

  /// Ends listening for incoming messages.
  /// When this method is call [listen] unblocks the thread and execution continues.
  ///
  /// - [correlationId] (optional) transaction id to trace execution through call chain.
  @override
  void endListen(String? correlationId) {
    _receiver = null;
  }
}
