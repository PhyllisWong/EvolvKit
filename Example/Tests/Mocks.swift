//
//  Mocks.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import Alamofire
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
  var expectPutExpectation : XCTestExpectation?
  
  private var mockedGet: (String) -> [JSON] = { _ in
    XCTFail("unexpected call to get")
    return []
  }
  
  private var mockedPut: (String, [JSON]) -> Void = { _,_  in
    XCTFail("unexpected call to set")
  }
  
  
  @discardableResult
  func expectGet(_ mocked: @escaping (_ uid: String) -> [JSON]) -> XCTestExpectation {
    self.expectGetExpectation = self.testCase.expectation(description: "expect get")
    self.mockedGet = mocked
    return expectGetExpectation!
  }

  func expectPut(_ mocked: @escaping (_ uid: String, _ allocations: [JSON]) -> Void) -> XCTestExpectation {
    self.expectPutExpectation = self.testCase.expectation(description: "expect put")
    self.mockedPut = mocked
    return expectPutExpectation!
  }
  
  // conform to protocol
   @discardableResult
  func get(uid: String) -> [JSON] {
    self.expectGetExpectation?.fulfill()
    return mockedGet(uid)
  }

  func put(uid: String, allocations: [JSON]) {
    self.expectGetExpectation?.fulfill()
    return mockedPut(uid, allocations)
  }
}


class HttpClientMock: HttpProtocol {
  @discardableResult
  func get(url: URL) -> Promise<String> {
    return Promise<String> { resolver -> Void in
      
      Alamofire.request(url)
        .validate()
        .responseString { response in
          switch response.result {
          case .success( _):
            
            if let responseString = response.result.value {
              
              resolver.fulfill(responseString)
            }
          case .failure(let error):
            
            resolver.reject(error)
          }
      }
    }
  }
  
  func sendEvents(url: URL) {
    let headers = [
      "Content-Type": "application/json",
      "Host" : "participants.evolv.ai"
    ]
    
    Alamofire.request(url,
                      method      : .get,
                      parameters  : nil,
                      encoding    : JSONEncoding.default ,
                      headers     : headers).responseData { dataResponse in
                        
                        
                        if dataResponse.response?.statusCode == 202 {
                          print("All good over here!")
                        } else {
                          print("Something really bad happened")
                        }
    }
  }
}

class ExecutionQueueMock : ExecutionQueue {
  
  var executeAllWithValuesFromAllocationsWasCalled = false
  var executeAllWithValuesFromDefaultsWasCalled = false
  
  override func executeAllWithValuesFromAllocations(allocations: [JSON]) {
    self.count -= 1
    executeAllWithValuesFromAllocationsWasCalled = true
  }
  
  override func executeAllWithValuesFromDefaults() {
    self.count -= 1
    executeAllWithValuesFromDefaultsWasCalled = true
  }
}

class ExecutionMock<T>: Execution<T> {
  
  override func executeWithDefault() {}
  
  override func executeWithAllocation(rawAllocations: [JSON]) throws {}
}



class ConfigMock: EvolvConfig { }

class ClientHttpMock: HttpProtocol {
  func get(url: URL) -> Promise<String> {
    fatalError()
  }
  
  func sendEvents(url: URL) {
    fatalError()
  }
}
