import 'package:test/test.dart';
import 'package:pip_services3_messaging/pip_service3_messaging.dart';
import './MessageQueueFixture.dart';

void main() {
  group('MemoryMessageQueue', () {
    MemoryMessageQueue queue;
    MessageQueueFixture fixture;

    setUpAll(() async {
      queue = MemoryMessageQueue('TestQueue');
      fixture = MessageQueueFixture(queue);
      await queue.open(null);
    });

    tearDownAll(() async {
      await queue.close(null);
    });

    setUp(() async {
      await queue.clear(
        null,
      );
    });

    test('Send Receive Message', () async {
      await fixture.testSendReceiveMessage();
    });

    test('Receive Send Message', () async {
      await fixture.testReceiveSendMessage();
    });

    test('Receive And Complete Message', () async {
      await fixture.testReceiveCompleteMessage();
    });

    test('Receive And Abandon Message', () async {
      await fixture.testReceiveAbandonMessage();
    });

    test('Send Peek Message', () async {
      await fixture.testSendPeekMessage();
    });

    test('Peek No Message', () async {
      await fixture.testPeekNoMessage();
    });

    test('Move To Dead Message', () async {
      await fixture.testMoveToDeadMessage();
    });

    test('On Message', () async {
      await fixture.testOnMessage();
    });
  });
}
