//  @module queues 
//  @hidden 
// var async = require('async');

// import { IReferenceable } from 'pip-services3-commons-node';
// import { IConfigurable } from 'pip-services3-commons-node';
// import { IReferences } from 'pip-services3-commons-node';
// import { ConfigParams } from 'pip-services3-commons-node';
// import { NameResolver } from 'pip-services3-commons-node';
// import { CompositeLogger } from 'pip-services3-components-node';
// import { CompositeCounters } from 'pip-services3-components-node';
// import { ConnectionResolver } from 'pip-services3-components-node';
// import { CredentialResolver } from 'pip-services3-components-node';
// import { ConnectionParams } from 'pip-services3-components-node';
// import { CredentialParams } from 'pip-services3-components-node';

// import { IMessageQueue } from './IMessageQueue';
// import { IMessageReceiver } from './IMessageReceiver';
// import { MessagingCapabilities } from './MessagingCapabilities';
// import { MessageEnvelope } from './MessageEnvelope';

// 
// /// Abstract message queue that is used as a basis for specific message queue implementations.
// /// 
// /// ### Configuration parameters ###
// /// 
// /// - name:                        name of the message queue
// /// - connection(s):
// ///   - discovery_key:             key to retrieve parameters from discovery service
// ///   - protocol:                  connection protocol like http, https, tcp, udp
// ///   - host:                      host name or IP address
// ///   - port:                      port number
// ///   - uri:                       resource URI or connection string with all parameters in it
// /// - credential(s):
// ///   - store_key:                 key to retrieve parameters from credential store
// ///   - username:                  user name
// ///   - password:                  user password
// ///   - access_id:                 application access id
// ///   - access_key:                application secret key
// /// 
// /// ### References ###
// /// 
// /// - <code>\*:logger:\*:\*:1.0</code>           (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/log.ilogger.html ILogger]] components to pass log messages
// /// - <code>\*:counters:\*:\*:1.0</code>         (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/count.icounters.html ICounters]] components to pass collected measurements
// /// - <code>\*:discovery:\*:\*:1.0</code>        (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/connect.idiscovery.html IDiscovery]] components to discover connection(s)
// /// - <code>\*:credential-store:\*:\*:1.0</code> (optional) [[https://rawgit.com/pip-services-node/pip-services3-components-node/master/doc/api/interfaces/auth.icredentialstore.html ICredentialStore]] componetns to lookup credential(s)
//  
// export abstract class MessageQueue implements IMessageQueue, IReferenceable, IConfigurable {
//     protected _logger: CompositeLogger = new CompositeLogger();
//     protected _counters: CompositeCounters = new CompositeCounters();
//     protected _connectionResolver: ConnectionResolver = new ConnectionResolver();
//     protected _credentialResolver: CredentialResolver = new CredentialResolver();

//     protected _name: string;
//     protected _capabilities: MessagingCapabilities;

//     
//     /// Creates a new instance of the message queue.
//     /// 
//     /// - name  (optional) a queue name
//      
// 	public constructor(name?: string) {
//         this._name = name;
// 	}
    
//     
//     /// Gets the queue name
//     /// 
//     /// @returns the queue name.
//      
//     public getName(): string { return this._name; }

//     
//     /// Gets the queue capabilities
//     /// 
//     /// @returns the queue's capabilities object.
//      
//     public getCapabilities(): MessagingCapabilities { return this._capabilities; }

//     
//     /// Configures component by passing configuration parameters.
//     /// 
//     /// - config    configuration parameters to be set.
//      
//     public configure(config: ConfigParams): void {
//         this._name = NameResolver.resolve(config, this._name);
//         this._logger.configure(config);
//         this._connectionResolver.configure(config);
//         this._credentialResolver.configure(config);
//     }

//     
// 	/// Sets references to dependent components.
// 	/// 
// 	/// - references 	references to locate the component dependencies. 
//      
//     public setReferences(references: IReferences): void {
//         this._logger.setReferences(references);
//         this._counters.setReferences(references);
//         this._connectionResolver.setReferences(references);
//         this._credentialResolver.setReferences(references);
//     }

//     
// 	/// Checks if the component is opened.
// 	/// 
// 	/// @returns true if the component has been opened and false otherwise.
//      
//     public abstract isOpen(): boolean;

//     
// 	/// Opens the component.
// 	/// 
// 	/// - correlationId 	(optional) transaction id to trace execution through call chain.
//     /// - callback 			callback function that receives error or null no errors occured.
//      
//     public open(correlationId: string, callback?: (err: any) => void): void {
//         let connection: ConnectionParams;
//         let credential: CredentialParams;

//         async.series([
//             (callback) => {
//                 this._connectionResolver.resolve(correlationId, (err: any, result: ConnectionParams) => {
//                     connection = result;
//                     callback(err);
//                 });
//             },
//             (callback) => {
//                 this._credentialResolver.lookup(correlationId, (err: any, result: CredentialParams) => {
//                     credential = result;
//                     callback(err);
//                 });
//             }
//         ])

//         this.openWithParams(correlationId, connection, credential, callback);
//     }

//     
//     /// Opens the component with given connection and credential parameters.
//     /// 
//     /// - correlationId     (optional) transaction id to trace execution through call chain.
//     /// - connection        connection parameters
//     /// - credential        credential parameters
//     /// - callback 			callback function that receives error or null no errors occured.
//      
//     protected abstract openWithParams(correlationId: string,
//         connection: ConnectionParams, credential: CredentialParams,
//         callback: (err: any) => void): void;

//     
// 	/// Closes component and frees used resources.
// 	/// 
// 	/// - correlationId 	(optional) transaction id to trace execution through call chain.
//     /// - callback 			callback function that receives error or null no errors occured.
//      
//     public abstract close(correlationId: string, callback: (err: any) => void): void;

//     
// 	/// Clears component state.
// 	/// 
// 	/// - correlationId 	(optional) transaction id to trace execution through call chain.
//     /// - callback 			callback function that receives error or null no errors occured.
//      
//     public abstract clear(correlationId: string, callback: (err: any) => void): void;

//     
//     /// Reads the current number of messages in the queue to be delivered.
//     /// 
//     /// - callback      callback function that receives number of messages or error.
//      
//     public abstract readMessageCount(callback: (err: any, count: number) => void): void;

//     
//     /// Sends a message into the queue.
//     /// 
//     /// - correlationId     (optional) transaction id to trace execution through call chain.
//     /// - envelope          a message envelop to be sent.
//     /// - callback          (optional) callback function that receives error or null for success.
//      
//     public abstract send(correlationId: string, envelope: MessageEnvelope, callback?: (err: any) => void): void;

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
//     public sendAsObject(correlationId: string, messageType: string, message: any, callback?: (err: any) => void): void {
//         var envelope = new MessageEnvelope(correlationId, messageType, message);
//         this.send(correlationId, envelope, callback);
//     }

//     
//     /// Peeks a single incoming message from the queue without removing it.
//     /// If there are no messages available in the queue it returns null.
//     /// 
//     /// - correlationId     (optional) transaction id to trace execution through call chain.
//     /// - callback          callback function that receives a message or error.
//      
//     public abstract peek(correlationId: string, callback: (err: any, result: MessageEnvelope) => void): void;

//     
//     /// Peeks multiple incoming messages from the queue without removing them.
//     /// If there are no messages available in the queue it returns an empty list.
//     /// 
//     /// - correlationId     (optional) transaction id to trace execution through call chain.
//     /// - messageCount      a maximum number of messages to peek.
//     /// - callback          callback function that receives a list with messages or error.
//      
//     public abstract peekBatch(correlationId: string, messageCount: number, callback: (err: any, result: MessageEnvelope[]) => void): void;

//     
//     /// Receives an incoming message and removes it from the queue.
//     /// 
//     /// - correlationId     (optional) transaction id to trace execution through call chain.
//     /// - waitTimeout       a timeout in milliseconds to wait for a message to come.
//     /// - callback          callback function that receives a message or error.
//      
//     public abstract receive(correlationId: string, waitTimeout: number, callback: (err: any, result: MessageEnvelope) => void): void;

//     
//     /// Renews a lock on a message that makes it invisible from other receivers in the queue.
//     /// This method is usually used to extend the message processing time.
//     /// 
//     /// - message       a message to extend its lock.
//     /// - lockTimeout   a locking timeout in milliseconds.
//     /// - callback      (optional) callback function that receives an error or null for success.
//      
//     public abstract renewLock(message: MessageEnvelope, lockTimeout: number, callback?: (err: any) => void): void;

//     
//     /// Permanently removes a message from the queue.
//     /// This method is usually used to remove the message after successful processing.
//     /// 
//     /// - message   a message to remove.
//     /// - callback  (optional) callback function that receives an error or null for success.
//      
//     public abstract complete(message: MessageEnvelope, callback?: (err: any) => void): void;

//     
//     /// Returnes message into the queue and makes it available for all subscribers to receive it again.
//     /// This method is usually used to return a message which could not be processed at the moment
//     /// to repeat the attempt. Messages that cause unrecoverable errors shall be removed permanently
//     /// or/and send to dead letter queue.
//     /// 
//     /// - message   a message to return.
//     /// - callback  (optional) callback function that receives an error or null for success.
//      
//     public abstract abandon(message: MessageEnvelope, callback?: (err: any) => void): void;

//     
//     /// Permanently removes a message from the queue and sends it to dead letter queue.
//     /// 
//     /// - message   a message to be removed.
//     /// - callback  (optional) callback function that receives an error or null for success.
//      
//     public abstract moveToDeadLetter(message: MessageEnvelope, callback?: (err: any) => void): void;

//     
//     /// Listens for incoming messages and blocks the current thread until queue is closed.
//     /// 
//     /// - correlationId     (optional) transaction id to trace execution through call chain.
//     /// - receiver          a receiver to receive incoming messages.
//     /// 
//     /// See [[IMessageReceiver]]
//     /// See [[receive]]
//      
//     public abstract listen(correlationId: string, receiver: IMessageReceiver): void;

//     
//     /// Ends listening for incoming messages.
//     /// When this method is call [[listen]] unblocks the thread and execution continues.
//     /// 
//     /// - correlationId     (optional) transaction id to trace execution through call chain.
//      
//     public abstract endListen(correlationId: string): void;

//     
//     /// Listens for incoming messages without blocking the current thread.
//     /// 
//     /// - correlationId     (optional) transaction id to trace execution through call chain.
//     /// - receiver          a receiver to receive incoming messages.
//     /// 
//     /// See [[listen]]
//     /// See [[IMessageReceiver]]
//      
//     public beginListen(correlationId: string, receiver: IMessageReceiver): void {
//         setImmediate(() => {
//             this.listen(correlationId, receiver);
//         });
//     }

//     
//     /// Gets a string representation of the object.
//     /// 
//     /// @returns a string representation of the object.
//      
//     public toString(): string {
//         return "[" + this.getName() + "]";
//     }

// }