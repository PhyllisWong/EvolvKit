//
//  Mocks.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import SwiftyJSON
import PromiseKit
@testable import EvolvKit

class Mocks: XCTestCase { }

class AllocationStoreMock: AllocationStoreProtocol {
  
  let testCase: XCTestCase
  
  init (testCase: XCTestCase) {
    self.testCase = testCase
  }
  
  var expectGetExpectation: XCTestExpectation?
  var expectSetExpectation : XCTestExpectation?
  
  private var mockedGet: (String) -> [JSON]? = { _ in
    XCTFail("unexpected call to get")
    return []
  }
  
  private var mockedSet: (String, [JSON]) -> Void = { _,_  in
    XCTFail("unexpected call to set")
  }
  
  
  @discardableResult
  func expectGet(_ mocked: @escaping (_ uid: String) -> [JSON]?) -> XCTestExpectation {
    self.expectGetExpectation = self.testCase.expectation(description: "expect get")
    self.mockedGet = mocked
    return expectGetExpectation!
  }
  
  func expectSet(_ mocked: @escaping (_ uid: String, _ allocations: [JSON]) -> Void) -> XCTestExpectation {
    self.expectGetExpectation = self.testCase.expectation(description: "expect set")
    self.mockedSet = mocked
    return expectGetExpectation!
  }
  
  // conform to protocol
  func get(uid: String) -> [JSON]? {
    self.expectGetExpectation?.fulfill()
    return mockedGet(uid)
  }
  
  func set(uid: String, allocations: [JSON]) {
    self.expectGetExpectation?.fulfill()
    return mockedSet(uid, allocations)
  }
}


class HttpClientMock: HttpProtocol {
  func get(url: URL) -> Promise<String> {
    fatalError()
  }
  
  func sendEvents(url: URL) {
    fatalError()
  }
}

class ExecutionMock<T>: Execution<T> {
  
  override func executeWithDefault() {
    
  }
  
  override func executeWithAllocation(rawAllocations: [JSON]) throws {
    
  }
}

class ExecutionQueueMock : ExecutionQueue { }

class ConfigMock: EvolvConfig { }

class ClientHttpMock: HttpProtocol {
  func get(url: URL) -> Promise<String> {
    fatalError()
  }
  
  func sendEvents(url: URL) {
    fatalError()
  }
}
