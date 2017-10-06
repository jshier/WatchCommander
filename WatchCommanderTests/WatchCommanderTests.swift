//
//  WatchCommanderTests.swift
//  WatchCommanderTests
//
//  Created by Jon Shier on 10/5/17.
//  Copyright © 2017 Jon Shier. All rights reserved.
//

import XCTest
import WatchCommander

class WatchCommanderTests: XCTestCase {

    
    func testSendingMessageSucceedsWithAppropriateData() {
        // Given
        let replyMessage = "success"
        let expectedReplyData = try! PropertyListEncoder().encode(replyMessage.asReply())
        let message: Message<String, Action> = Message(payload: "string", action: Action.first)
        let expectedMessageData = try! PropertyListEncoder().encode(message)
        let testSession = TestableWatchSession(replyData: expectedReplyData)
        let commander = WatchCommander(session: testSession)
        var messageResult: Result<Reply<String>>? = nil
        
        // When
        weak var expect = expectation(description: "message replied")
        commander.send(message) { (result: Result<Reply<String>>) in
            messageResult = result
            expect?.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        
        // Then
        XCTAssertTrue(messageResult?.isSuccess == true)
        XCTAssertEqual(messageResult?.value?.payload, "success")
        XCTAssertEqual(testSession.replyData, expectedReplyData)
        XCTAssertEqual(testSession.sentData, expectedMessageData)
    }
    
    
}

final class TestableWatchSession: WatchSession {
    let replyData: Data
    var sentData: Data?
    
    init(replyData: Data) {
        self.replyData = replyData
    }
    
    func sendMessageData(_ data: Data, replyHandler: WatchSession.DataReplyHandler?, errorHandler: WatchSession.ErrorHandler?) {
        sentData = data
        replyHandler?(replyData)
    }
}

enum Action: String, Codable {
    case first
}
