import 'dart:async';

import 'package:pip_services3_commons/pip_services3_commons.dart';
import 'package:pip_services3_messaging/src/test/test.dart';
import 'package:test/test.dart';
import 'package:pip_services3_messaging/pip_services3_messaging.dart';

class TestMessageReciver implements IMessageReceiver {
  late MessageEnvelope message;

  @override
  Future receiveMessage(MessageEnvelope envelope, IMessageQueue queue) {
    message = envelope;
    return Future.value(null);
  }
}

class MessageQueueFixture {
  IMessageQueue _queue;

  MessageQueueFixture(IMessageQueue queue) : _queue = queue;

  Future testSendReceiveMessage() async {
    var envelope1 = MessageEnvelope('123', 'Test', 'Test message');
    MessageEnvelope envelope2;

    await _queue.send(null, envelope1);

    var count = await _queue.readMessageCount();
    expect(count > 0, isTrue);

    var result = await _queue.receive(null, 10000);
    envelope2 = result!;
    expect(envelope2, isNotNull);
    expect(envelope1.message_type, envelope2.message_type);
    expect(envelope1.message, envelope2.message);
    expect(envelope1.correlation_id, envelope2.correlation_id);
  }

  Future testReceiveSendMessage() async {
    var envelope1 = MessageEnvelope('123', 'Test', 'Test message');
    MessageEnvelope envelope2;

    await Future.delayed(Duration(milliseconds: 500), () async {
      await _queue.send(null, envelope1);
    });

    var result = await _queue.receive(null, 10000);
    envelope2 = result!;

    expect(envelope2, isNotNull);
    expect(envelope1.message_type, envelope2.message_type);
    expect(envelope1.message, envelope2.message);
    expect(envelope1.correlation_id, envelope2.correlation_id);
  }

  Future testReceiveCompleteMessage() async {
    var envelope1 = MessageEnvelope('123', 'Test', 'Test message');
    MessageEnvelope envelope2;

    await _queue.send(null, envelope1);

    var count = await _queue.readMessageCount();
    expect(count > 0, isTrue);

    var result = await _queue.receive(null, 10000);
    envelope2 = result!;

    expect(envelope2, isNotNull);
    expect(envelope1.message_type, envelope2.message_type);
    expect(envelope1.message, envelope2.message);
    expect(envelope1.correlation_id, envelope2.correlation_id);

    await _queue.complete(envelope2);
    expect(envelope2.getReference(), isNull);
  }

  Future testReceiveAbandonMessage() async {
    var envelope1 = MessageEnvelope('123', 'Test', 'Test message');
    MessageEnvelope envelope2;

    await _queue.send(null, envelope1);

    var result = await _queue.receive(null, 10000);
    envelope2 = result!;

    expect(envelope2, isNotNull);
    expect(envelope1.message_type, envelope2.message_type);
    expect(envelope1.message, envelope2.message);
    expect(envelope1.correlation_id, envelope2.correlation_id);

    await _queue.abandon(envelope2);

    result = await _queue.receive(null, 10000);
    envelope2 = result!;

    expect(envelope2, isNotNull);
    expect(envelope1.message_type, envelope2.message_type);
    expect(envelope1.message, envelope2.message);
    expect(envelope1.correlation_id, envelope2.correlation_id);
  }

  Future testSendPeekMessage() async {
    var envelope1 = MessageEnvelope('123', 'Test', 'Test message');
    MessageEnvelope envelope2;

    await _queue.send(null, envelope1);

    var result = await _queue.peek(null);
    envelope2 = result!;

    expect(envelope2, isNotNull);
    expect(envelope1.message_type, envelope2.message_type);
    expect(envelope1.message, envelope2.message);
    expect(envelope1.correlation_id, envelope2.correlation_id);
  }

  Future testPeekNoMessage() async {
    var result = await _queue.peek(null);
    expect(result, isNull);
  }

  Future testMoveToDeadMessage() async {
    var envelope1 = MessageEnvelope('123', 'Test', 'Test message');
    MessageEnvelope envelope2;

    await _queue.send(null, envelope1);

    var result = await _queue.receive(null, 10000);
    envelope2 = result!;

    expect(envelope2, isNotNull);
    expect(envelope1.message_type, envelope2.message_type);
    expect(envelope1.message, envelope2.message);
    expect(envelope1.correlation_id, envelope2.correlation_id);

    await _queue.moveToDeadLetter(envelope2);
  }

  Future testOnMessage() async {
    var envelope1 = MessageEnvelope('123', 'Test', 'Test message');
    MessageEnvelope envelope2;
    var reciver = TestMessageReciver();
    _queue.beginListen(null, reciver);

    await Future.delayed(Duration(milliseconds: 1000), () {});
    await _queue.send(null, envelope1);

    await Future.delayed(Duration(milliseconds: 1000), () {});

    envelope2 = reciver.message;
    expect(envelope2, isNotNull);
    expect(envelope1.message_type, envelope2.message_type);
    expect(envelope1.message, envelope2.message);
    expect(envelope1.correlation_id, envelope2.correlation_id);

    _queue.endListen(null);
  }

  Future testSendAsObject() async {
    var messageReceiver = TestMessageReceiver();
    var testObj = {
      'id': IdGenerator.nextLong(),
      'name': RandomString.nextString(20, 50)
    };

    _queue.beginListen(null, messageReceiver);

    await Future.delayed(Duration(milliseconds: 1000), () {});

    //  send array of strings
    await _queue.sendAsObject('123', 'messagetype', ['string1', 'string2']);

    await Future.delayed(Duration(milliseconds: 1000), () {});

    expect(1, messageReceiver.messageCount);
    var envelope = messageReceiver.messages[0];
    expect(envelope, isNotNull);
    expect('messagetype', envelope.message_type);
    expect('123', envelope.correlation_id);

    /// realize setAsObject with Object type for dart!
    var message =
        envelope.getMessageAsJson(); // envelope.getMessageAs<string[]>();
    expect(message is List, isTrue);
    expect(message, containsAll(['string1', 'string2']));

    // send string
    await messageReceiver.clear(null);
    await _queue.sendAsObject('123', 'messagetype', 'string2');

    await Future.delayed(Duration(milliseconds: 1000), () {});

    expect(1, messageReceiver.messageCount);
    envelope = messageReceiver.messages[0];
    expect(envelope, isNotNull);
    expect('messagetype', envelope.message_type);
    expect('123', envelope.correlation_id);

    var message2 = envelope.getMessageAsString();
    expect('string2', message2);

    // // send object
    // await messageReceiver.clear(null);
    // await this._queue.sendAsObject('123', 'messagetype', testObj);

    // await new Promise<void>((resolve, reject) => setTimeout(resolve, 1000));

    // expect(1, messageReceiver.messageCount);
    // envelope = messageReceiver.messages[0];
    // assert.isNotNull(envelope);
    // expect('messagetype', envelope.message_type);
    // expect('123', envelope.correlation_id);

    // var message3 = envelope.getMessageAs<any>();
    // assert.isNotNull(message);
    // expect(testObj.id, message3.id);
    // expect(testObj.name, message3.name);

    _queue.endListen(null);
  }
}
