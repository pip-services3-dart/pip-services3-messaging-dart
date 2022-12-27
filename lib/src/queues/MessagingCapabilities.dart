/// Data object that contains supported capabilities of a message queue.
/// If certain capability is not supported a queue will throw NotImplemented exception.

class MessagingCapabilities {
  bool _canMessageCount = false;
  bool _canSend = false;
  bool _canReceive = false;
  bool _canPeek = false;
  bool _canPeekBatch = false;
  bool _canRenewLock = false;
  bool _canAbandon = false;
  bool _canDeadLetter = false;
  bool _canClear = false;

  /// Creates a new instance of the capabilities object.
  ///
  /// - [canMessageCount]   true if queue supports reading message count.
  /// - [canSend]           true if queue is able to send messages.
  /// - [canReceive]        true if queue is able to receive messages.
  /// - [canPeek]           true if queue is able to peek messages.
  /// - [canPeekBatch]      true if queue is able to peek multiple messages in one batch.
  /// - [canRenewLock]      true if queue is able to renew message lock.
  /// - [canAbandon]        true if queue is able to abandon messages.
  /// - [canDeadLetter]     true if queue is able to send messages to dead letter queue.
  /// - [canClear]          true if queue can be cleared.
  MessagingCapabilities(
      bool canMessageCount,
      bool canSend,
      bool canReceive,
      bool canPeek,
      bool canPeekBatch,
      bool canRenewLock,
      bool canAbandon,
      bool canDeadLetter,
      bool canClear) {
    _canMessageCount = canMessageCount;
    _canSend = canSend;
    _canReceive = canReceive;
    _canPeek = canPeek;
    _canPeekBatch = canPeekBatch;
    _canRenewLock = canRenewLock;
    _canAbandon = canAbandon;
    _canDeadLetter = canDeadLetter;
    _canClear = canClear;
  }

  /// Informs if the queue is able to read number of messages.
  ///
  /// Returns true if queue supports reading message count.
  bool get canMessageCount {
    return _canMessageCount;
  }

  /// Informs if the queue is able to send messages.
  ///
  /// Returns true if queue is able to send messages.
  bool get canSend {
    return _canSend;
  }

  /// Informs if the queue is able to receive messages.
  ///
  /// Returns true if queue is able to receive messages.
  bool get canReceive {
    return _canReceive;
  }

  /// Informs if the queue is able to peek messages.
  ///
  /// Returns true if queue is able to peek messages.
  bool get canPeek {
    return _canPeek;
  }

  /// Informs if the queue is able to peek multiple messages in one batch.
  ///
  /// Returns true if queue is able to peek multiple messages in one batch.
  bool get canPeekBatch {
    return _canPeekBatch;
  }

  /// Informs if the queue is able to renew message lock.
  ///
  /// Returns true if queue is able to renew message lock.
  bool get canRenewLock {
    return _canRenewLock;
  }

  /// Informs if the queue is able to abandon messages.
  ///
  /// Returns true if queue is able to abandon.
  bool get canAbandon {
    return _canAbandon;
  }

  /// Informs if the queue is able to send messages to dead letter queue.
  ///
  /// Returns true if queue is able to send messages to dead letter queue.
  bool get canDeadLetter {
    return _canDeadLetter;
  }

  /// Informs if the queue can be cleared.
  ///
  /// Returns true if queue can be cleared.
  bool get canClear {
    return _canClear;
  }
}
