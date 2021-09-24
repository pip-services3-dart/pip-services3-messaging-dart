import './MessageEnvelope.dart';

/// Data object used to store and lock incoming messages
/// in [MemoryMessageQueue].
///
/// See [MemoryMessageQueue]
class LockedMessage {
  /// The incoming message.
  MessageEnvelope? message;

  /// The expiration time for the message lock.
  /// If it is null then the message is not locked.
  DateTime? expirationTime;

  /// The lock timeout in milliseconds.
  int? timeout;
}
