//
//  WatchCommander.swift
//  WatchCommander
//
//  Created by Jon Shier on 10/5/17.
//  Copyright © 2017 Jon Shier. All rights reserved.
//

import WatchConnectivity

public class WatchCommander {
    
    let session: WatchSession
    
    public init(session: WatchSession = WCSession.default) {
        self.session = session
    }
    
    public func send<M: MessageConvertible, Payload>(_ convertible: M, completionHandler: @escaping (_ result: Result<Reply<Payload>>) -> Void) {
        do {
            let data = try PropertyListEncoder().encode(convertible.asMessage())
            session.sendMessageData(data, replyHandler: { (data) in
                let result = Result { try PropertyListDecoder().decode(Reply<Payload>.self, from: data) }
                completionHandler(result)
            }, errorHandler: { (error) in
                completionHandler(.failure(error))
            })
        } catch {
            completionHandler(.failure(error))
        }
    }
    
}

public protocol WatchSession {
//    var delegate: WCSessionDelegate? { get set }
//    var activationState: WCSessionActivationState { get }
//
//    func activate()
    typealias DataReplyHandler = (_ data: Data) -> Void
    typealias ErrorHandler = (_ error: Error) -> Void
    func sendMessageData(_: Data, replyHandler: DataReplyHandler?, errorHandler: ErrorHandler?)
    
}

extension WCSession: WatchSession { }

public struct Message<Payload: Codable, Action: RawRepresentable & Codable>: Codable {
    
    public let payload: Payload
    public let action: Action
    
    public init(payload: Payload, action: Action) {
        self.payload = payload
        self.action = action
    }
    
}

public protocol MessageConvertible {
    
    associatedtype Payload: Codable
    associatedtype Action: RawRepresentable, Codable
    
    func asMessage() throws -> Message<Payload, Action>
    
}

extension Message: MessageConvertible {

    public func asMessage() throws -> Message {
        return self
    }
    
}

public struct Reply<Payload: Codable>: Codable {
    
    public let payload: Payload
    
    public init(payload: Payload) {
        self.payload = payload
    }
    
}

public protocol ReplyConvertible {
    
    associatedtype Payload: Codable
    
    func asReply() throws -> Reply<Payload>
    
}

extension String: ReplyConvertible {
    
    public func asReply() throws -> Reply<String> {
        return Reply(payload: self)
    }
    
}
