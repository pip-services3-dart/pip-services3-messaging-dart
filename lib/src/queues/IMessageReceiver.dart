
import 'dart:async';
import './IMessageQueue.dart';
import './MessageEnvelope.dart';

/// Callback interface to receive incoming messages.
/// 
/// ### Example ###
/// 
///     class MyMessageReceiver implements IMessageReceiver {
///       Future receiveMessage(MessageEnvelop envelope, IMessageQueue queue) async {
///           print("Received message: " + envelop.getMessageAsString());
///       }
///     }
/// 
///     var messageQueue =  MemoryMessageQueue();
///     messageQueue.listen("123", MyMessageReceiver());
/// 
///     await messageQueue.open("123")
///     
///     messageQueue.send("123", MessageEnvelop(null, "mymessage", "ABC")); // Output in console: "ABC"
///     
 
abstract class IMessageReceiver {
    
    /// Receives incoming message from the queue.
    /// 
    /// - [envelope]  an incoming message
    /// - [queue]     a queue where the message comes from
    /// Return        Future that receives error or null for success.
    /// 
    /// See [MessageEnvelope]
    /// See [IMessageQueue]
     
    Future receiveMessage(MessageEnvelope envelope, IMessageQueue queue);
}