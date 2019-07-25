import XCTest
import SwiftyJSON
import PromiseKit
@testable import EvolvKit

class ClientImplTest: XCTestCase {
  
  var mockConfig : EvolvConfig!
  var mockExecutionQueue : ExecutionQueue!
  var mockHttpClient : HttpClientMock!
  var mockAllocationStore: AllocationStoreMock!
  var mockEventEmitter : EventEmitter!
  var mockAllocator : Allocator!
  
  private let participant = EvolvParticipant(userId: "test_user", sessionId: "test_session", userAttributes: [
    "userId": "test_user",
    "sessionId": "test_session"
    ])
  
  private let environmentId = "test_env"
  private let rawAllocation = "[{\"uid\":\"test_uid\",\"sid\":\"test_sid\",\"eid\":\"test_eid\",\"cid\":\"test_cid\",\"genome\":{\"search\":{\"weighting\":{\"distance\":2.5,\"dealer_score\":2.5}},\"pages\":{\"all_pages\":{\"header_footer\":[\"blue\",\"white\"]},\"testing_page\":{\"megatron\":\"none\",\"header\":\"white\"}},\"algorithms\":{\"feature_importance\":false}},\"excluded\":false}]"
  private var testValue: Double = 0.0
  
  override func setUp() {
    self.mockHttpClient = HttpClientMock()
    self.mockAllocationStore = AllocationStoreMock(testCase: self)
    self.mockConfig = EvolvConfig("https", "test.evolv.ai", "v1", self.environmentId, self.mockAllocationStore, self.mockHttpClient)
    self.mockExecutionQueue = ExecutionQueueMock()
    self.mockEventEmitter = EmitterMock(config: self.mockConfig, participant: self.participant)
    self.mockAllocator = AllocatorMock(config: self.mockConfig, participant: self.participant)
  }
  
  override func tearDown() {
    if let _ = mockHttpClient {
      mockHttpClient = nil
    }
    if let _ = mockConfig {
      mockConfig = nil
    }
    if let _ = mockAllocationStore {
      mockAllocationStore = nil
    }
    if let _ = mockExecutionQueue {
      mockExecutionQueue = nil
    }
    if let _ = mockEventEmitter {
      mockEventEmitter = nil
    }
    if let _ = mockAllocator {
      mockAllocator = nil
    }
  }
  
  func testSubscribeStoreNotEmptySubscriptionKey_Valid() {
    let subscriptionKey = "search.weighting.distance"
    let defaultValue: Double = 0.001
    
    let expectation = XCTestExpectation(description: "yo testing")
    
    self.mockAllocationStore.expectGet { uid -> [JSON] in
      XCTAssertEqual(uid, self.participant.getUserId())
      let allocations = AllocationsTest().parseRawAllocations(raw: self.rawAllocation)
      return allocations
    }
    
    let config = EvolvConfig("https", "test.evolv.ai", "v1", "test_env", self.mockAllocationStore, self.mockHttpClient)
    let emitter = EventEmitter(config: config, participant: participant)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    
    let promise = Promise { resolver in
      resolver.fulfill(allocations)
    }
    
    // FIXME: this is failing, why????
    let applyFunction: (Double) -> Void = { value in
      XCTAssertNotEqual(defaultValue, value)
      expectation.fulfill()
      
    }
    
    let client = EvolvClientImpl(config, emitter, promise, mockAllocator, false, participant)
    client.subscribe(key: subscriptionKey, defaultValue: defaultValue, function: applyFunction)
    
    self.waitForExpectations(timeout: 8)
  }
  
  func testSubscribeStoreNotEmptySubscriptionKey_Invalid() {
    let subscriptionKey = "search.weighting.distance.bubbles"
    let defaultValue: Double = 0.001
    let participantId = "id"
    let expectation = XCTestExpectation(description: "Async block executed")
    
    let participant = EvolvParticipant(userId: participantId, sessionId: "sid", userAttributes: [
      "userId": "id",
      "sessionId": "sid"
      ])
    
    self.mockAllocationStore.expectGet { uid -> [JSON] in
      XCTAssertEqual(uid, participant.getUserId())
      expectation.fulfill()
      let allocations = AllocationsTest().parseRawAllocations(raw: self.rawAllocation)
      return allocations
    }
    
    let config = EvolvConfig("https", "test.evolv.ai", "v1", "test_env", self.mockAllocationStore, self.mockHttpClient)
    let emitter = EventEmitter(config: config, participant: participant)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    
    let promise = Promise { resolver in
      resolver.fulfill(allocations)
    }
    
    let applyFunction: (Double) -> Void = { value in
      XCTAssertEqual(defaultValue, value)
      expectation.fulfill()
    }
    
    let client = EvolvClientImpl(config, emitter, promise, mockAllocator, false, participant)
    client.subscribe(key: subscriptionKey, defaultValue: defaultValue, function: applyFunction)
    
    // fails exceeding the timeout. Why???
    self.waitForExpectations(timeout: 8)
  }
  
  func testEmitEventWithScore() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let promise = Promise { resolver in
      resolver.fulfill(allocations)
    }
    
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
    let key = "testKey"
    let score = 1.3
    client.emitEvent(key: key, score: score)
    
    XCTAssertTrue(client.emitEventWithScoreWasCalled)
  }
  
  func testEmitEvent() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let promise = Promise { resolver in
      resolver.fulfill(allocations)
    }
    
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
    let key = "testKey"
    client.emitEvent(key: key)
    
    XCTAssertTrue(client.emitEventWasCalled)
  }
  
  func testConfirmEventSandBagged() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    
    XCTAssertEqual(mockAllocator.getAllocationStatus(), Allocator.AllocationStatus.FETCHING)
    
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let promise = Promise { resolver in
      resolver.fulfill(allocations)
    }
    
    let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
    client.confirm(allocator: allocator)
    
    XCTAssertTrue(allocator.sandbagConfirmationWasCalled)
  }
  
  func testConfirmEvent() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let promise = Promise { resolver in
      resolver.fulfill(allocations)
    }
    
    let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
    
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
    let emitter = EmitterMock(config: self.mockConfig, participant: self.participant)
    client.confirm(eventEmitter: emitter, allocations: allocations)
    allocator.allocationStatus = Allocator.AllocationStatus.RETRIEVED
    
    XCTAssertEqual(allocator.getAllocationStatus(), Allocator.AllocationStatus.RETRIEVED)
    XCTAssertTrue(emitter.confirmWithAllocationsWasCalled)
  }
  
  func testContaminateEventSandBagged() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let promise = Promise { resolver in
      resolver.fulfill(allocations)
    }
    
    let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
    allocator.allocationStatus = Allocator.AllocationStatus.FETCHING
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
    client.contaminate(allocator: allocator)
    
    XCTAssertEqual(allocator.getAllocationStatus(), Allocator.AllocationStatus.FETCHING)
    XCTAssertTrue(allocator.sandbagContamationWasCalled)
  }
  
  func testContaminateEvent() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let promise = Promise { resolver in
      resolver.fulfill(allocations)
    }
    
    let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
    
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, mockAllocator, false, self.participant)
    let emitter = EmitterMock(config: self.mockConfig, participant: self.participant)
    client.contaminate(eventEmitter: emitter, allocations: allocations)
    allocator.allocationStatus = Allocator.AllocationStatus.RETRIEVED
    
    XCTAssertEqual(allocator.getAllocationStatus(), Allocator.AllocationStatus.RETRIEVED)
    XCTAssertTrue(emitter.confirmWithAllocationsWasCalled)
  }
  
  func testSubscribeNoPreviousAllocationsWithFetchingState() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let promise = Promise { resolver in
      resolver.fulfill(allocations)
    }
    
    let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
    allocator.allocationStatus = Allocator.AllocationStatus.FETCHING
    
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, allocator, false, self.participant)
    
    let expectedTestValue: Double = 2.5
    let defaultValue: Double = 10.01
    
    func updateValue(value: Double) {
      self.testValue = value
    }
    
    client.subscribe(key: "search.weighting.distance", defaultValue: defaultValue, function: updateValue)
    
    XCTAssertEqual(expectedTestValue, self.testValue)
    self.testValue = 0.0
  }
  
  func testSubscribeNoPreviousAllocationsWithRetrievedState() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let promise = Promise { resolver in
      resolver.fulfill(allocations)
    }
    
    let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
    allocator.allocationStatus = Allocator.AllocationStatus.RETRIEVED
    
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, allocator, false, self.participant)
    
    let expectedTestValue: Double = 0.0
    let defaultValue: Double = 10.01
    
    XCTAssertEqual(expectedTestValue, self.testValue)
    
    let expected: Double = 2.5
    func updateValue(value: Double) {
      self.testValue = value
    }
    
    client.subscribe(key: "search.weighting.distance", defaultValue: defaultValue, function: updateValue)
    XCTAssertEqual(expected, self.testValue)
    self.testValue = 0.0
  }
  
  func testSubscribeNoPreviousAllocationsWithFailedState() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let promise = Promise { resolver in
      resolver.fulfill(allocations)
    }
    
    let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
    allocator.allocationStatus = Allocator.AllocationStatus.FAILED
    
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, allocator, false, self.participant)
    
    let expectedTestValue: Double = 0.0
    let defaultValue: Double = 10.01
    
    XCTAssertEqual(expectedTestValue, self.testValue)
    
    let expected: Double = 2.5
    func updateValue(value: Double) {
      self.testValue = value
    }
    
    client.subscribe(key: "search.weighting.distance", defaultValue: defaultValue, function: updateValue)
    XCTAssertNotEqual(expected, self.testValue)
    self.testValue = 0.0
  }
  
  func testSubscribeNoPreviousAllocationsWithRetrievedStateThrowsError() {
    let actualConfig = EvolvConfig.builder(environmentId, mockHttpClient).build()
    let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(self.mockConfig, actualConfig,
                                                                            mockExecutionQueue, mockHttpClient,
                                                                            mockAllocationStore)
    let allocations = AllocationsTest().parseRawAllocations(raw: rawAllocation)
    let promise = Promise { resolver in
      resolver.fulfill(allocations)
    }
    
    let allocator = AllocatorMock(config: mockConfig, participant: self.participant)
    allocator.allocationStatus = Allocator.AllocationStatus.FAILED
    
    let client = ClientImplMock(mockConfig, mockEventEmitter, promise, allocator, false, self.participant)
    
    let expectedTestValue: Double = 0.0
    let defaultValue: Double = 10.01
    
    XCTAssertEqual(expectedTestValue, self.testValue)
    
    let expected: Double = 2.5
    func updateValue(value: Double) {
      self.testValue = value
    }
    
    client.subscribe(key: "not.a.valid.key", defaultValue: defaultValue, function: updateValue)
    XCTAssertNotEqual(expected, self.testValue)
    self.testValue = 0.0
  }
  
}

