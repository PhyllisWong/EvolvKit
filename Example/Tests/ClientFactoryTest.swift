//
//  EvolvClientTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/13/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import SwiftyJSON
import PromiseKit
@testable import EvolvKit

class EvolvClientTest: XCTestCase {
  
  private let environmentId: String = "test_12345"
  private let rawAllocation: String = "[{\"uid\":\"test_uid\",\"sid\":\"test_sid\",\"eid\":\"test_eid\",\"cid\":\"test_cid\",\"genome\":{\"search\":{\"weighting\":{\"distance\":2.5,\"dealer_score\":2.5}},\"pages\":{\"all_pages\":{\"header_footer\":[\"blue\",\"white\"]},\"testing_page\":{\"megatron\":\"none\",\"header\":\"white\"}},\"algorithms\":{\"feature_importance\":false}},\"excluded\":false}]"

  
  private var mockHttpClient : HttpClientMock!
  private var mockAllocationStore : AllocationStoreMock!
  private var mockExecutionQueue : ExecutionQueueMock!
  private var mockConfig : ConfigMock!
  
    override func setUp() {
      mockHttpClient = HttpClientMock()
      mockAllocationStore = AllocationStoreMock(testCase: self)
      mockExecutionQueue = ExecutionQueueMock()
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

  func testClientInit() {
    let actualConfig = EvolvConfig.builder(environmentId: environmentId,
                                           httpClient: mockHttpClient).build()
    // let mockConfig = AllocatorTest().setUpMockedEvolvConfigWithMockedClient(mockConfig, actualConfig, mockExecutionQueue, mockHttp, mockAllocationStore)
  }

}
