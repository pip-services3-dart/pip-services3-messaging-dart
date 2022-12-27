import 'dart:convert';

import 'package:pip_services3_messaging/src/queues/queues.dart';
import 'package:test/test.dart';

void main() {
  group('MessageEnvelop', () {
    test('From/To JSON', () {
      var message = MessageEnvelope('123', 'Test', 'This is a test message');
      var json = jsonEncode(message.toJSON());

      var message2 = MessageEnvelope.fromJSON(json)!;
      expect(message.message_id, message2.message_id);
      expect(message.correlation_id, message2.correlation_id);
      expect(message.message_type, message2.message_type);
      expect(message.message.toString(), message2.message.toString());
    });
  });
}
