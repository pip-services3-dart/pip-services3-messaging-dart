import 'dart:convert';
import 'package:pip_services3_commons/pip_services3_commons.dart';

/// Allows adding additional information to messages. A correlation id, message id, and a message type
/// are added to the data being sent/received. Additionally, a [MessageEnvelope] can reference a lock token.
///
/// Side note: a MessageEnvelope's message is stored as string, so strings are converted
/// using utf8 conversions.
class MessageEnvelope {
  var _reference;
  // The unique business transaction id that is used to trace calls across components.
  String? correlation_id;
  // The message's auto-generated ID.
  String message_id;
  // String value that defines the stored message's type.
  String? message_type;
  // The time at which the message was sent.
  DateTime? sent_time;
  // The stored message.
  String? message;

  /// Creates a new MessageEnvelope, which adds a correlation id, message id, and a type to the
  /// data being sent/received.
  ///
  /// - [correlationId]     (optional) transaction id to trace execution through call chain.
  /// - [messageType]       a string value that defines the message's type.
  /// - [message]           the data being sent/received.
  MessageEnvelope(String? correlationId, String? messageType, message)
      : correlation_id = correlationId,
        message_type = messageType,
        message_id = IdGenerator.nextLong() {
    if (message is Map || message is List) {
      setMessageAsJson(message);
    } else {
      this.message = message;
    }
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
  /// - [value] the string to set.
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
    return json.decode(temp!);
  }

  /// Stores the given value as a JSON string.
  ///
  /// - [value]     the value to convert to JSON and store in
  ///                  this message.
  ///
  /// See [getMessageAsJson]
  void setMessageAsJson(dynamic value) {
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
        ? message!.substring(0, message!.length > 50 ? 50 : message!.length)
        : '---';
    builder += ']';
    return builder;
  }

  /// Converts this MessageEnvelop to a JSON string.
  /// The message payload is passed as string
  /// Returns A JSON encoded representation is this object.
  Map<String, dynamic> toJSON() {
    var payload = message != null ? message.toString() : null;
    var json = {
      'message_id': message_id,
      'correlation_id': correlation_id,
      'message_type': message_type,
      'sent_time': StringConverter.toString2(sent_time ?? DateTime.now()),
      'message': payload
    };
    return json;
  }

  /// Converts a JSON string into a MessageEnvelop
  /// The message payload is passed as string
  /// - [value] a JSON encoded string
  /// Returns a decoded Message Envelop.
  static MessageEnvelope? fromJSON(String? value) {
    if (value == null) return null;

    var json = jsonDecode(value);
    if (json == null) return null;

    var message =
        MessageEnvelope(json['correlation_id'], json['message_type'], null);
    message.message_id = json['message_id'];
    message.message = json['message'];
    message.sent_time = DateTimeConverter.toNullableDateTime(json['sent_time']);

    return message;
  }

  /// Converts a JSON string into a MessageEnvelop
  /// The message payload is passed as string
  /// - [value] a JSON encoded string
  void fromJson(String? value) {
    if (value == null) return null;

    var json = jsonDecode(value);
    if (json == null) return null;

    correlation_id = json['correlation_id'];
    message_type = json['message_type'];
    message_id = json['message_id'];
    message = json.message != null ? json['message'] : null;
    sent_time = DateTimeConverter.toNullableDateTime(json.sent_time);
  }
}
