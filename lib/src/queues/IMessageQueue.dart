//  @module queues 
// import { IOpenable } from 'pip-services3-commons-node';
// import { IClosable } from 'pip-services3-commons-node';

// import { MessagingCapabilities } from './MessagingCapabilities';
// import { MessageEnvelope } from './MessageEnvelope';
// import { IMessageReceiver } from './IMessageReceiver';

// 
// /// Interface for asynchronous message queues.
// /// 
// /// Not all queues may implement all the methods.
// /// Attempt to call non-supported method will result in NotImplemented exception.
// /// To verify if specific method is supported consult with [[MessagingCapabilities]].
// /// 
// /// See [[MessageEnvelop]]
// /// See [[MessagingCapabilities]]
//  
// export interface IMessageQueue extends IOpenable, IClosable {
//     
//     /// Gets the queue name
//     /// 
//     /// @returns the queue name.
//      
//     getName(): string;

//     
//     /// Gets the queue capabilities
//     /// 
//     /// @returns the queue's capabilities object.
//      
// 	getCapabilities(): MessagingCapabilities;
    
//     
//     /// Reads the current number of messages in the queue to be delivered.
//     /// 
//     /// - callback      callback function that receives number of messages or error.
//      
//     readMessageCount(callback: (err: any, count: number) => void): void;

//     
//     /// Sends a message into the queue.
//     /// 
//     /// - correlationId     (optional) transaction id to trace execution through call chain.
//     /// - envelope          a message envelop to be sent.
//     /// - callback          (optional) callback function that receives error or null for success.
//      
//     send(correlationId: string, envelope: MessageEnvelope, callback?: (err: any) => void): void;

//     
//     /// Sends an object into the queue.
//     /// Before sending the object is converted into JSON string and wrapped in a [[MessageEnvelop]].
//     /// 
//     /// - correlationId     (optional) transaction id to trace execution through call chain.
//     /// - messageType       a message type
//     /// - value             an object value to be sent
//     /// - callback          (optional) callback function that receives error or null for success.
//     /// 
//     /// See [[send]]
//      
//     sendAsObject(correlationId: string, messageType: string, value: any, callback?: (err: any) => void): void;

//     
//     /// Peeks a single incoming message from the queue without removing it.
//     /// If there are no messages available in the queue it returns null.
//     /// 
//     /// - correlationId     (optional) transaction id to trace execution through call chain.
//     /// - callback          callback function that receives a message or error.
//      
//     peek(correlationId: string, callback: (err: any, result: MessageEnvelope) => void): void;

//     
//     /// Peeks multiple incoming messages from the queue without removing them.
//     /// If there are no messages available in the queue it returns an empty list.
//     /// 
//     /// - correlationId     (optional) transaction id to trace execution through call chain.
//     /// - messageCount      a maximum number of messages to peek.
//     /// - callback          callback function that receives a list with messages or error.
//      
//     peekBatch(correlationId: string, messageCount: number, callback: (err: any, result: MessageEnvelope[]) => void): void;

//     
//     /// Receives an incoming message and removes it from the queue.
//     /// 
//     /// - correlationId     (optional) transaction id to trace execution through call chain.
//     /// - waitTimeout       a timeout in milliseconds to wait for a message to come.
//     /// - callback          callback function that receives a message or error.
//      
//     receive(correlationId: string, waitTimeout: number, callback: (err: any, result: MessageEnvelope) => void): void;

//     
//     /// Renews a lock on a message that makes it invisible from other receivers in the queue.
//     /// This method is usually used to extend the message processing time.
//     /// 
//     /// - message       a message to extend its lock.
//     /// - lockTimeout   a locking timeout in milliseconds.
//     /// - callback      (optional) callback function that receives an error or null for success.
//      
//     renewLock(message: MessageEnvelope, lockTimeout: number, callback?: (err: any) => void): void;

//     
//     /// Permanently removes a message from the queue.
//     /// This method is usually used to remove the message after successful processing.
//     /// 
//     /// - message   a message to remove.
//     /// - callback  (optional) callback function that receives an error or null for success.
//      
//     complete(message: MessageEnvelope, callback?: (err: any) => void): void;

//     
//     /// Returnes message into the queue and makes it available for all subscribers to receive it again.
//     /// This method is usually used to return a message which could not be processed at the moment
//     /// to repeat the attempt. Messages that cause unrecoverable errors shall be removed permanently
//     /// or/and send to dead letter queue.
//     /// 
//     /// - message   a message to return.
//     /// - callback  (optional) callback function that receives an error or null for success.
//      
//     abandon(message: MessageEnvelope, callback?: (err: any) => void): void; 

//     
//     /// Permanently removes a message from the queue and sends it to dead letter queue.
//     /// 
//     /// - message   a message to be removed.
//     /// - callback  (optional) callback function that receives an error or null for success.
//      
//     moveToDeadLetter(message: MessageEnvelope, callback?: (err: any) => void): void;

//     
//     /// Listens for incoming messages and blocks the current thread until queue is closed.
//     /// 
//     /// - correlationId     (optional) transaction id to trace execution through call chain.
//     /// - receiver          a receiver to receive incoming messages.
//     /// 
//     /// See [[IMessageReceiver]]
//     /// See [[receive]]
//      
//     listen(correlationId: string, receiver: IMessageReceiver): void;

//     
//     /// Listens for incoming messages without blocking the current thread.
//     /// 
//     /// - correlationId     (optional) transaction id to trace execution through call chain.
//     /// - receiver          a receiver to receive incoming messages.
//     /// 
//     /// See [[listen]]
//     /// See [[IMessageReceiver]]
//      
//     beginListen(correlationId: string, receiver: IMessageReceiver): void;

//     
//     /// Ends listening for incoming messages.
//     /// When this method is call [[listen]] unblocks the thread and execution continues.
//     /// 
//     /// - correlationId     (optional) transaction id to trace execution through call chain.
//      
//     endListen(correlationId: string): void;
// }