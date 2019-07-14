import XCTest
import SwiftyJSON
import PromiseKit
@testable import EvolvKit

class Tests: XCTestCase {
  
  var allocationStoreMock: AllocationStoreMock!
  var httpClientMock : HttpClientMock!
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.allocationStoreMock = AllocationStoreMock(testCase: self)
    self.httpClientMock = HttpClientMock()
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testExample() {
    // This is an example of a functional test case.
    XCTAssert(true, "Pass")
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure() {
      // Put the code you want to measure the time of here.
    }
  }
  
  func testSubscribe_AllocationStoreIsEmpty_SubscriptionKeyIsValid_() {
    let subscriptionKey = "foo.bar"
    let defaultValue = "FooBar"
    let applyFunction: (String) -> Void = { value in
      
      XCTAssertEqual(<#T##expression1: Equatable##Equatable#>, <#T##expression2: Equatable##Equatable#>)
    }
    
    let participantId = "id"
    
    let participant = EvolvParticipant(userId: participantId, sessionId: "sid", userAttributes: [
      "userId": "id",
      "sessionId": "sid"
    ])
    
    self.allocationStoreMock.expectGet { uid -> [JSON]? in
      XCTAssertEqual(uid, participantId)
      
      return nil
    }
    
    /*
     mock the allocationStatus
     mock executeWithAllocation eith from store or API
     mock executeWithDefault
     */
    
    let config = EvolvConfig("https", "test.evolv.ai", "v1", "test_env", self.allocationStoreMock, self.httpClientMock)
    let emitter = EventEmitter(config: config, participant: participant)
    let promise = Promise<[JSON]>.pending().promise
    let allocator = Allocator(config: config, participant: participant)
    
    let client = EvolvClientImpl(config, emitter, promise, allocator, false, participant)
    client.subscribe(key: subscriptionKey, defaultValue: defaultValue, function: applyFunction)
    
    self.waitForExpectations(timeout: 5)
  }
  
  func testSubscribe_AllocationStoreIsNotEmpty_SubscriptionKeyIsValid_() {
    let subscriptionKey = "foo.bar"
    let defaultValue = "FooBar"
    let applyFunction: (String) -> Void = { value in
      XCTAssertEqual(<#T##expression1: Equatable##Equatable#>, <#T##expression2: Equatable##Equatable#>)
    }
    
    let participantId = "id"
    
    let participant = EvolvParticipant(userId: participantId, sessionId: "sid", userAttributes: [
      "userId": "id",
      "sessionId": "sid"
      ])
    
    self.allocationStoreMock.expectGet { uid -> [JSON]? in
      XCTAssertEqual(uid, participantId)
      
      let myStoredAllocation = "[{\"uid\":\"\(participantId)\",\"eid\":\"experiment_1\",\"cid\":\"candidate_3\",\"genome\":{\"ui\":{\"layout\":\"option_1\",\"buttons\":{\"checkout\":{\"text\":\"Begin Secure Checkout\",\"color\":\"#f3b36d\"},\"info\":{\"text\":\"Product Specifications\",\"color\":\"#f3b36d\"}}},\"search\":{\"weighting\":3.5}},\"excluded\":true}]"
      let dataFromString = myStoredAllocation.data(using: String.Encoding.utf8, allowLossyConversion: false)!
      let allocations = try! JSON(data: dataFromString).arrayValue
      
      return allocations
    }
    
    
    let config = EvolvConfig("https", "test.evolv.ai", "v1", "test_env", self.allocationStoreMock, self.httpClientMock)
    let emitter = EventEmitter(config: config, participant: participant)
    let promise = Promise<[JSON]>.pending().promise
    let allocator = Allocator(config: config, participant: participant)
    
    let client = EvolvClientImpl(config, emitter, promise, allocator, false, participant)
    client.subscribe(key: subscriptionKey, defaultValue: defaultValue, function: applyFunction)
    
    self.waitForExpectations(timeout: 5)
  }
  
  func testEvolvParticipant() {
    let p = EvolvParticipant.builder().build()
    p.setUserId(userId: "test_user")
    XCTAssertEqual(p.getUserId(), "test_user")
  }
  
}

class ExecutionMock<T>: Execution<T> {
  
  override func executeWithDefault() {
    
  }
  
  override func executeWithAllocation(rawAllocations: [JSON]) throws {
    
  }
}

// TODO: finish creating mocks

class HttpClientMock: HttpProtocol {
  func get(url: URL) -> Promise<String> {
    fatalError()
  }
  
  func sendEvents(url: URL) {
    fatalError()
  }
}


class AllocationStoreMock: AllocationStoreProtocol {
  
  let testCase: XCTestCase
  
  init (testCase: XCTestCase) {
    self.testCase = testCase
  }
  
  var expectGetExpectation: XCTestExpectation?
  private var mockedGet: (String) -> [JSON]? = { _ in
    XCTFail("unexpected call to get")
    return []
  }
  
  @discardableResult
  func expectGet(_ mocked: @escaping (_ uid: String) -> [JSON]?) -> XCTestExpectation {
    self.expectGetExpectation = self.testCase.expectation(description: "expect get")
    self.mockedGet = mocked
    return expectGetExpectation!
  }
  
  // conform to protocol
  
  func get(uid: String) -> [JSON]? {
    self.expectGetExpectation?.fulfill()
    return mockedGet(uid)
  }
  
  func set(uid: String, allocations: [JSON]) {
    fatalError()
  }
  
  
}
