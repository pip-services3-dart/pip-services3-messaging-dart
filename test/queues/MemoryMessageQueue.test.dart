// import 'package:test/test.dart';
// import 'package:pip_services3_messaging/pip_service3_messaging.dart';
// import './MessageQueueFixture.dart';

// void main(){
// group('MemoryMessageQueue', ()  {
//     MemoryMessageQueue queue ;
//     MessageQueueFixture fixture;

//     setUpAll(() async {
//         queue = MemoryMessageQueue('TestQueue');
//         fixture = MessageQueueFixture(queue);
//         await queue.open(null);
//     });

//     tearDownAll(() async  {
//         await queue.close(null, );
//     });

//     setUp(() async {
//         await queue.clear(null, );
//     });

//     test('Send Receive Message', ()  {
//         fixture.testSendReceiveMessage();
//     });

//     test('Receive Send Message', ()  {
//         fixture.testReceiveSendMessage();
//     });

//     test('Receive And Complete Message', ()  {
//         fixture.testReceiveCompleteMessage();
//     });

//     test('Receive And Abandon Message', ()  {
//         fixture.testReceiveAbandonMessage();
//     });

//     test('Send Peek Message', ()  {
//         fixture.testSendPeekMessage();
//     });

//     test('Peek No Message', ()  {
//         fixture.testPeekNoMessage();
//     });

//     test('Move To Dead Message', ()  {
//         fixture.testMoveToDeadMessage();
//     });

//     test('On Message', ()  {
//         fixture.testOnMessage();
//     });

// });
// }