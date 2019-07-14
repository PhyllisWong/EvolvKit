import XCTest
import SwiftyJSON
@testable import EvolvKit

class Tests: XCTestCase {
  
  var allocationStoreMock: AllocationStoreMock!
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.allocationStoreMock = AllocationStoreMock(testCase: self)
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
  
  func testSubscribe() {
    
    let subscriptionKey = "foo.bar"
    let defaultValue = "FooBar"
    let applyFunction: (String) -> Void = { value in }
    
    let p = EvolvParticipant.ini
    
    
    self.allocationStoreMock.expectGet { (<#String#>) -> [JSON]? in
      <#code#>
    }
    
    
    
    let client: EvolvClientImpl! = nil
    client.subscribe(key: subscriptionKey, defaultValue: defaultValue, function: applyFunction)
    
    
  }
  
  func testEvolvParticipant() {
    let p = EvolvParticipant.builder().build()
    
    XCTAssertEqual(p.getUserId(), "test_user")
  }
  
}


class AllocationStoreMock: AllocationStoreProtocol {
  
  let testCase: XCTestCase
  
  var expectGetExpectation: XCTestExpectation?
  private var mockedGet: (String) -> [JSON]? = { _ in
    XCTFail("unexpected call to get")
    return []
  }
  
  func expectGet(_ mocked: @escaping (_ uid: String) -> [JSON]?) -> XCTestExpectation {
    self.expectGetExpectation = self.testCase.expectation(description: "expect get")
    self.mockedGet = mocked
  }
  
  
  
  
  func get(uid: String) -> [JSON]? {
    return mockedGet(uid)
  }
  
  func set(uid: String, allocations: [JSON]) {
    <#code#>
  }
  
  
}
