import 'dart:async';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_components/pip_services3_components.dart';
import './IMessageQueue.dart';
import './IMessageReceiver.dart';
import './MessagingCapabilities.dart';
import './MessageEnvelope.dart';

/// Abstract message queue that is used as a basis for specific message queue implementations.
///
/// ### Configuration parameters ###
///
/// - [name]:                        name of the message queue
/// - [connection(s)]:
///   - [discovery_key]:             key to retrieve parameters from discovery service
///   - [protocol]:                  connection protocol like http, https, tcp, udp
///   - [host]:                      host name or IP address
///   - [port]:                      port number
///   - [uri]:                       resource URI or connection string with all parameters in it
/// - [credential(s)]:
///   - [store_key]:                 key to retrieve parameters from credential store
///   - [username]:                  user name
///   - [password]:                  user password
///   - [access_id]:                 application access id
///   - [access_key]:                application secret key
///
/// ### References ###
///
/// - \*:logger:\*:\*:1.0           (optional) [ILogger](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ILogger-class.html) components to pass log messages
/// - \*:counters:\*:\*:1.0         (optional) [ICounters](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ICounters-class.html) components to pass collected measurements
/// - \*:discovery:\*:\*:1.0        (optional) [IDiscovery](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/IDiscovery-class.html) components to discover connection(s)
/// - \*:credential-store:\*:\*:1.0 (optional) [ICredentialStore](https://pub.dev/documentation/pip_services3_components/latest/pip_services3_components/ICredentialStore-class.html) componetns to lookup credential(s)

abstract class MessageQueue
    implements IMessageQueue, IReferenceable, IConfigurable {
  var logger = CompositeLogger();
  var counters = CompositeCounters();
  var connectionResolver = ConnectionResolver();
  var credentialResolver = CredentialResolver();

  String name = '';
  MessagingCapabilities capabilities = MessagingCapabilities(
      false, false, false, false, false, false, false, false, false);

  /// Creates a new instance of the message queue.
  ///
  /// - [name]  (optional) a queue name
  /// - [capabilities] (optional) a capabilities of this message queue
  MessageQueue([String? name, MessagingCapabilities? capabilities]) {
    this.name = name ?? this.name;
    this.capabilities = capabilities ?? this.capabilities;
  }

  /// Gets the queue name
  ///
  /// Returns the queue name.
  @override
  String getName() {
    return name;
  }

  /// Gets the queue capabilities
  ///
  /// Returns the queue's capabilities object.
  @override
  MessagingCapabilities getCapabilities() => capabilities;

  /// Configures component by passing configuration parameters.
  ///
  /// - [config]    configuration parameters to be set.
  @override
  void configure(ConfigParams config) {
    name = NameResolver.resolve(config, name) ?? name;
    logger.configure(config);
    connectionResolver.configure(config);
    credentialResolver.configure(config);
  }

  /// Sets references to dependent components.
  ///
  /// - [references] 	references to locate the component dependencies.
  @override
  void setReferences(IReferences references) {
    logger.setReferences(references);
    counters.setReferences(references);
    connectionResolver.setReferences(references);
    credentialResolver.setReferences(references);
  }

  /// Checks if the component is opened.
  ///
  /// Returns true if the component has been opened and false otherwise.
  @override
  bool isOpen();

  /// Opens the component.
  ///
  /// - [correlationId] 	(optional) transaction id to trace execution through call chain.
  /// Return 			Future that receives null no errors occured.
  /// Trows error
  @override
  Future open(String? correlationId) async {
    var connection = await connectionResolver.resolve(correlationId);
    var credential = await credentialResolver.lookup(correlationId);

    return openWithParams(correlationId, connection, credential);
  }

  /// Opens the component with given connection and credential parameters.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [connection]        connection parameters
  /// - [credential]        credential parameters
  /// Return 			Future that receives null no errors occured.
  /// Trows error
  Future openWithParams(String? correlationId, ConnectionParams? connection,
      CredentialParams? credential);

  /// Checks if the queue has been opened and throws an exception is it's not.
  /// - [correlationId] (optional) transaction id to trace execution through call chain.
  void checkOpen(String? correlationId) {
    if (!isOpen()) {
      throw InvalidStateException(
          correlationId, 'NOT_OPENED', 'The queue is not opened');
    }
  }

  /// Closes component and frees used resources.
  ///
  /// - correlationId 	(optional) transaction id to trace execution through call chain.
  /// Return 			      Future that receives  null no errors occured.
  /// Throws error
  @override
  Future close(String? correlationId);

  /// Clears component state.
  ///
  /// - [correlationId] 	(optional) transaction id to trace execution through call chain.
  /// Return 			Future that receives  null no errors occured.
  /// Throws error
  Future clear(String? correlationId);

  /// Reads the current number of messages in the queue to be delivered.
  ///
  /// Return      Future that receives number of messages or error.
  /// Throws error
  @override
  Future<int> readMessageCount();

  /// Sends a message into the queue.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [envelope]          a message envelop to be sent.
  /// Return          (optional) Future that receives  null for success.
  /// Throws error
  @override
  Future send(String? correlationId, MessageEnvelope envelope);

  /// Sends an object into the queue.
  /// Before sending the object is converted into JSON string and wrapped in a [MessageEnvelope].
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [messageType]       a message type
  /// - [value]             an object value to be sent
  /// Return          (optional) Future that receives  null for success.
  /// Throws error
  ///
  /// See [send]
  @override
  Future sendAsObject(String? correlationId, String messageType, message) {
    var envelope = MessageEnvelope(correlationId, messageType, message);
    return send(correlationId, envelope);
  }

  /// Peeks a single incoming message from the queue without removing it.
  /// If there are no messages available in the queue it returns null.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// Return          Future that receives a message or error.
  /// Throws errors
  @override
  Future<MessageEnvelope?> peek(String? correlationId);

  /// Peeks multiple incoming messages from the queue without removing them.
  /// If there are no messages available in the queue it returns an empty list.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [messageCount]      a maximum number of messages to peek.
  /// Return          Future that receives a list with messages
  /// Throws error.
  @override
  Future<List<MessageEnvelope?>> peekBatch(
      String? correlationId, int messageCount);

  /// Receives an incoming message and removes it from the queue.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [waitTimeout]       a timeout in milliseconds to wait for a message to come.
  /// Return          Future that receives a message
  /// Throws error.
  @override
  Future<MessageEnvelope?> receive(String? correlationId, int waitTimeout);

  /// Renews a lock on a message that makes it invisible from other receivers in the queue.
  /// This method is usually used to extend the message processing time.
  ///
  /// - [message]       a message to extend its lock.
  /// - [lockTimeout]   a locking timeout in milliseconds.
  /// Return      (optional) Future that receives an null for success.
  /// Throws error
  @override
  Future renewLock(MessageEnvelope message, int lockTimeout);

  /// Permanently removes a message from the queue.
  /// This method is usually used to remove the message after successful processing.
  ///
  /// - [message]   a message to remove.
  /// Return  (optional) Future that receives an  null for success.
  /// Trows error
  @override
  Future complete(MessageEnvelope message);

  /// Returnes message into the queue and makes it available for all subscribers to receive it again.
  /// This method is usually used to return a message which could not be processed at the moment
  /// to repeat the attempt. Messages that cause unrecoverable errors shall be removed permanently
  /// or/and send to dead letter queue.
  ///
  /// - [message]   a message to return.
  /// Return  (optional) Future that receives an null for success.
  /// Throows error
  @override
  Future abandon(MessageEnvelope message);

  /// Permanently removes a message from the queue and sends it to dead letter queue.
  ///
  /// - [message]   a message to be removed.
  /// Return  (optional) Future that receives an  null for success.
  /// Throw errors
  @override
  Future moveToDeadLetter(MessageEnvelope message);

  /// Listens for incoming messages and blocks the current thread until queue is closed.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [receiver]          a receiver to receive incoming messages.
  ///
  /// See [IMessageReceiver]
  /// See [receive]
  @override
  void listen(String? correlationId, IMessageReceiver receiver);

  /// Ends listening for incoming messages.
  /// When this method is call [listen] unblocks the thread and execution continues.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  @override
  void endListen(String? correlationId);

  /// Listens for incoming messages without blocking the current thread.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [receiver]          a receiver to receive incoming messages.
  ///
  /// See [listen]
  /// See [IMessageReceiver]
  @override
  void beginListen(String? correlationId, IMessageReceiver receiver) {
    // setImmediate(() => {
    Future.delayed(Duration(milliseconds: 0), () {
      listen(correlationId, receiver);
    });
    // });
  }

  /// Gets a string representation of the object.
  ///
  /// Returns a string representation of the object.
  @override
  String toString() {
    return '[' + getName() + ']';
  }
}
