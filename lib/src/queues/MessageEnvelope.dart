import 'dart:convert';
import 'package:pip_services3_commons/pip_services3_commons.dart';

/// Allows adding additional information to messages. A correlation id, message id, and a message type
/// are added to the data being sent/received. Additionally, a MessageEnvelope can reference a lock token.
///
/// Side note: a MessageEnvelope's message is stored as string, so strings are converted
/// using utf8 conversions.
class MessageEnvelope {
  var _reference;
  // The unique business transaction id that is used to trace calls across components.
  String correlation_id;
  // The message's auto-generated ID.
  String message_id;
  // String value that defines the stored message's type.
  String message_type;
  // The time at which the message was sent.
  DateTime sent_time;
  // The stored message.
  String message;

  /// Creates a new MessageEnvelope, which adds a correlation id, message id, and a type to the
  /// data being sent/received.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [messageType]       a string value that defines the message's type.
  /// - [message]           the data being sent/received.
  MessageEnvelope(String correlationId, String messageType, message) {
    correlation_id = correlationId;
    message_type = messageType;
    this.message = message;
    message_id = IdGenerator.nextLong();
  }

  /// Returns the lock token that this MessageEnvelope references.
  dynamic getReference() {
    return _reference;
  }

  /// Sets a lock token reference for this MessageEnvelope.
  ///
  /// - [value]     the lock token to reference.
  void setReference(value) {
    _reference = value;
  }

  /// Returns the information stored in this message as a UTF-8 encoded string.
  String getMessageAsString() {
    return message ?? '';
  }

  /// Stores the given string.
  ///
  /// - [value]     the string to set. Will be converted to
  ///                  a buffer, using UTF-8 encoding.
  void setMessageAsString(String value) {
    message = value;
  }

  /// Returns the value that was stored in this message
  ///          as a JSON string.
  ///
  /// See [setMessageAsJson]
  dynamic getMessageAsJson() {
    if (message == null) return null;
    var temp = message;
    return json.decode(temp);
  }

  /// Stores the given value as a JSON string.
  ///
  /// - [value]     the value to convert to JSON and store in
  ///                  this message.
  ///
  /// See [getMessageAsJson]
  void setMessageAsJson(Map<String, dynamic> value) {
    if (value == null) {
      message = null;
    } else {
      message = json.encode(value);
    }
  }

  /// Convert's this MessageEnvelope to a string, using the following format:
  ///
  /// "[<correlation_id>,<message_type>,<message.toString>]".
  ///
  /// If any of the values are null, they will be replaced with ---.
  ///
  /// Returns the generated string.
  @override
  String toString() {
    var builder = '[';
    builder += correlation_id ?? '---';
    builder += ',';
    builder += message_type ?? '---';
    builder += ',';
    builder += message != null
        ? message.substring(0, message.length > 50 ? 50 : message.length)
        : '---';
    builder += ']';
    return builder;
  }
}
