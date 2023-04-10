// Copyright © 2023, Oracle and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

import Foundation
import Combine
import XCTest 

internal enum PublisherToBlockingError: Error {
    case didNotThrowAnyError
    case didNotThrowExpectedError
}

/// Extension to Publisher allowing for simpler testing.
/// Functionality is similar to RxSwifts toBlocking() method
extension Publisher {
    
    /// Usage:
    /// For publishers that DO complete:
    ///     let result = try myPublisher.waitForCompletion()
    ///     XCTAssertEqual(result, [0, 2])
    ///
    /// For publishers that do NOT complete:
    ///     Get the first 2 published values
    ///     let result = try current.prefix(2).waitForCompletion()
    public func waitForCompletion(
        timeout: TimeInterval = 10.0,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> [Output] {
        
        let expectation = XCTestExpectation(
                                description: "waiting for publisher to complete"
                          )
        var completion: Subscribers.Completion<Failure>?
        var output = [Output]()
        
        let subscription = self.collect()
            .sink(receiveCompletion: { receiveCompletion in
                completion = receiveCompletion
                expectation.fulfill()
            }, receiveValue: { value in
                output = value
            })
        
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        subscription.cancel()
        
        switch try XCTUnwrap(completion, "Publisher never completed", file: file, line: line) {
        case let .failure(error):
            throw error
            
        case .finished:
            return output
        }
    }
    
    /// Similar to RxSwift's toBlocking().first() implementation
    /// Usage:
    ///     let current = CurrentValueSubject<Int, Never>(0)
    ///     current.value = 2
    ///     let result = try current.waitForFirstOutput()
    ///     XCTAssertEqual(result, 2)
    ///
    public func waitForFirstOutput(
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Output {
        return try XCTUnwrap(prefix(1).waitForCompletion(file: file, line: line).first, "", file: file, line: line)
    }
    
    public func waitForError(
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> Failure {
        
        do {
            _ = try prefix(1).waitForCompletion(file: file, line: line).first
            throw PublisherToBlockingError.didNotThrowAnyError
            
        } catch {
            if error is Failure {
                return error as! Self.Failure
            } else {
                throw PublisherToBlockingError.didNotThrowExpectedError
            }
        }
    }
}
