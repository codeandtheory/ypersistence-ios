//
//  DispatchQueue+executeOnMainTests.swift
//  YPersistence
//
//  Created by Mark Pospesel on 12/3/21.
//  Copyright © 2023 Y Media Labs. All rights reserved.
//

import XCTest
@testable import YPersistence

final class DispatchQueueExecuteOnMainTests: XCTestCase {
    func testMain() {
        var executed = false

        // given we call from the main thread
        DispatchQueue.executeOnMain {
            executed = true
        }

        // we expect the code to be executed immediately
        XCTAssertTrue(executed, "Code was not executed synchronously")
    }

    func testBackground() {
        var executed = false
        var wasExecutedImmediately = false
        let expectation = self.expectation(description: "executeOnMain")

        // given we call from a background thread
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.executeOnMain {
                executed = true
                expectation.fulfill()
            }

            wasExecutedImmediately = (executed == true)
        }

        // and we allow executeOnMain 2 seconds to complete
        wait(for: [expectation], timeout: 2)

        // we expect the code to be executed but not immediately
        XCTAssertTrue(executed, "Code was not executed")
        XCTAssertFalse(wasExecutedImmediately, "Code was executed immediately")
    }
}
