//
//  AllocatorTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/16/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import SwiftyJSON
import PromiseKit
@testable import EvolvKit

class AllocatorTest: XCTestCase {
  
  private let environmentId: String = "test_12345"
  private let rawAllocation: String = "[{\"uid\":\"test_uid\",\"sid\":\"test_sid\",\"eid\":\"test_eid\",\"cid\":\"test_cid\",\"genome\":{\"search\":{\"weighting\":{\"distance\":2.5,\"dealer_score\":2.5}},\"pages\":{\"all_pages\":{\"header_footer\":[\"blue\",\"white\"]},\"testing_page\":{\"megatron\":\"none\",\"header\":\"white\"}},\"algorithms\":{\"feature_importance\":false}},\"excluded\":false}]"
  
  private var mockConfig: EvolvConfig!
  private var mockExecutionQueue: ExecutionQueue!
  private var mockHttpClient : HttpClientMock!
  private var mockAllocationStore : AllocationStoreMock!
  
  override func setUp() {
    mockExecutionQueue = ExecutionQueueMock()
    mockHttpClient = HttpClientMock()
    mockAllocationStore = AllocationStoreMock(testCase: self)
    mockConfig = ConfigMock("https", "test_domain", "test_v", "test_eid", mockAllocationStore, mockHttpClient)
  }
  
  override func tearDown() {
    if let _ = mockHttpClient {
      mockHttpClient = nil
    }
    if let _ = mockAllocationStore {
      mockAllocationStore = nil
    }
    if let _ = mockExecutionQueue {
      mockExecutionQueue = nil
    }
    if let _ = mockConfig {
      mockConfig = nil
    }
  }
  
  func parseRawAllocations(raw: String) -> [JSON] {
    var allocations = [JSON]()
    if let dataFromString = raw.data(using: String.Encoding.utf8, allowLossyConversion: false) {
      allocations = try! JSON(data: dataFromString).arrayValue
    }
    return allocations
  }
  
  func setUpMockedEvolvConfigWithMockedClient(mockedConfig: EvolvConfig, actualConfig: EvolvConfig,
                                               mockExecutionQueue: ExecutionQueue, mockHttpClient: HttpProtocol,
                                               mockAllocationStore: AllocationStoreProtocol) -> EvolvConfig {
    
    return EvolvConfig(actualConfig.getHttpScheme(), actualConfig.getDomain(),
                                             actualConfig.getVersion(), actualConfig.getEnvironmentId(),
                                             mockAllocationStore, mockHttpClient)
  }
  
  func createAllocationsUrl(config: EvolvConfig, participant: EvolvParticipant) -> URL {
    var components = URLComponents()
    components.scheme = config.getHttpScheme()
    components.host = config.getDomain()
    components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/allocations"
    components.queryItems = [
      URLQueryItem(name: "uid", value: "\(participant.getUserId())")
    ]
    
    guard let url = components.url else { return URL(string: "")! }
    return url
  }
  
  func createConfirmationUrl(config: EvolvConfig, allocation: [JSON], participant: EvolvParticipant) -> URL {
    var components = URLComponents()
    components.scheme = config.getHttpScheme()
    components.host = config.getDomain()
    components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/events"
    components.queryItems = [
      URLQueryItem(name: "uid", value: "\(participant.getUserId())"),
      URLQueryItem(name: "sid", value: "\(participant.getSessionId())"),
      URLQueryItem(name: "eid", value: "\(allocation[0]["eid"].stringValue)"),
      URLQueryItem(name: "cid", value: "\(allocation[0]["cid"].stringValue)"),
      URLQueryItem(name: "type", value: "confirmation")
    ]
    
    guard let url = components.url else { return URL(string: "")! }
    print("URL: \(url)")
    return url
  }
  
  func createContaminationUrl(config: EvolvConfig, allocation: [JSON], participant: EvolvParticipant) -> URL {
    var components = URLComponents()
    components.scheme = config.getHttpScheme()
    components.host = config.getDomain()
    components.path = "/\(config.getVersion())/\(config.getEnvironmentId())/events"
    components.queryItems = [
      URLQueryItem(name: "uid", value: "\(participant.getUserId())"),
      URLQueryItem(name: "sid", value: "\(participant.getSessionId())"),
      URLQueryItem(name: "eid", value: "\(allocation[0]["eid"].stringValue)"),
      URLQueryItem(name: "cid", value: "\(allocation[0]["cid"].stringValue)"),
      URLQueryItem(name: "type", value: "contamination")
    ]
    
    guard let url = components.url else { return URL(string: "")! }
    print("URL: \(url)")
    return url
  }
  
  func testCreateAllocationsUrl() {
    let actualConfig = EvolvConfig.builder(environmentId: environmentId, httpClient: mockHttpClient).build()
    let mockConfig = setUpMockedEvolvConfigWithMockedClient(mockedConfig: self.mockConfig, actualConfig: actualConfig,
                                               mockExecutionQueue: mockExecutionQueue, mockHttpClient: mockHttpClient,
                                               mockAllocationStore: mockAllocationStore)
    let participant = EvolvParticipant.builder().build()
    let allocator = Allocator(config: mockConfig, participant: participant)
    let actualUrl = allocator.createAllocationsUrl()
    let expectedUrl = createAllocationsUrl(config: actualConfig, participant: participant)
    
    XCTAssertEqual(expectedUrl, actualUrl)
  }
  
}
