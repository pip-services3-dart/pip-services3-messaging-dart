import 'dart:async';

import 'package:pip_services3_commons/pip_services3_commons.dart';

import './MessagingCapabilities.dart';
import './MessageEnvelope.dart';
import './IMessageReceiver.dart';

/// Interface for asynchronous message queues.
///
/// Not all queues may implement all the methods.
/// Attempt to call non-supported method will result in NotImplemented exception.
/// To verify if specific method is supported consult with [MessagingCapabilities].
///
/// See [MessageEnvelop]
/// See [MessagingCapabilities]

abstract class IMessageQueue implements IOpenable, IClosable {
  /// Gets the queue name
  ///
  /// Returns the queue name.
  String getName();

  /// Gets the queue capabilities
  ///
  /// Returns the queue's capabilities object.
  MessagingCapabilities getCapabilities();

  /// Reads the current number of messages in the queue to be delivered.
  ///
  /// Return      Future that receives number of messages
  /// Throws error.
  Future<int> readMessageCount();

  /// Sends a message into the queue.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [envelope]          a message envelop to be sent.
  /// Return                Future that receives null for success.
  /// Throws error
  Future send(String correlationId, MessageEnvelope envelope);

  /// Sends an object into the queue.
  /// Before sending the object is converted into JSON string and wrapped in a [MessageEnvelop].
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [messageType]       a message type
  /// - [value]             an object value to be sent
  /// Return          (optional) Future that receives null for success.
  /// Throws error
  ///
  /// See [[send]]
  Future sendAsObject(String correlationId, String messageType, value);

  /// Peeks a single incoming message from the queue without removing it.
  /// If there are no messages available in the queue it returns null.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// Return          Future that receives a message 
  /// Throws error.
  Future<MessageEnvelope> peek(String correlationId);

  /// Peeks multiple incoming messages from the queue without removing them.
  /// If there are no messages available in the queue it returns an empty list.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [messageCount]      a maximum number of messages to peek.
  /// Return                Future that receives a list with messages
  /// Throws error.
  Future<List<MessageEnvelope>> peekBatch(
      String correlationId, int messageCount);

  /// Receives an incoming message and removes it from the queue.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [waitTimeout]       a timeout in milliseconds to wait for a message to come.
  /// Return                Future that receives a message
  /// Throw error.
  Future<MessageEnvelope> receive(String correlationId, int waitTimeout);

  /// Renews a lock on a message that makes it invisible from other receivers in the queue.
  /// This method is usually used to extend the message processing time.
  ///
  /// - [message]       a message to extend its lock.
  /// - [lockTimeout]   a locking timeout in milliseconds.
  /// Return            Future that receives an null for success.
  /// Throws error
  Future renewLock(MessageEnvelope message, int lockTimeout);

  /// Permanently removes a message from the queue.
  /// This method is usually used to remove the message after successful processing.
  ///
  /// - [message]   a message to remove.
  /// Return        Future that receives null for success.
  /// Throws error
  Future complete(MessageEnvelope message);

  /// Returnes message into the queue and makes it available for all subscribers to receive it again.
  /// This method is usually used to return a message which could not be processed at the moment
  /// to repeat the attempt. Messages that cause unrecoverable errors shall be removed permanently
  /// or/and send to dead letter queue.
  ///
  /// - [message]  a message to return.
  /// Return       Future that receives null for success.
  /// Throws error
  Future abandon(MessageEnvelope message);

  /// Permanently removes a message from the queue and sends it to dead letter queue.
  ///
  /// - [message]   a message to be removed.
  /// Return        Future that receives null for success.
  /// Throws error
  Future moveToDeadLetter(MessageEnvelope message);

  /// Listens for incoming messages and blocks the current thread until queue is closed.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [receiver]          a receiver to receive incoming messages.
  ///
  /// See [IMessageReceiver]
  /// See [receive] method
  void listen(String correlationId, IMessageReceiver receiver);

  /// Listens for incoming messages without blocking the current thread.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [receiver]          a receiver to receive incoming messages.
  ///
  /// See [listen] method
  /// See [IMessageReceiver]
  void beginListen(String correlationId, IMessageReceiver receiver);

  /// Ends listening for incoming messages.
  /// When this method is call [[listen]] unblocks the thread and execution continues.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  void endListen(String correlationId);
}
