//
//  LruCacheTest.swift
//  EvolvKit_Tests
//
//  Created by phyllis.wong on 7/18/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import EvolvKit

class LruCacheTest: XCTestCase {
  
  private let rawAllocation: String = "[{\"uid\":\"test_uid\",\"sid\":\"test_sid\",\"eid\":\"test_eid\",\"cid\":\"test_cid\",\"genome\":{\"search\":{\"weighting\":{\"distance\":2.5,\"dealer_score\":2.5}},\"pages\":{\"all_pages\":{\"header_footer\":[\"blue\",\"white\"]},\"testing_page\":{\"megatron\":\"none\",\"header\":\"white\"}},\"algorithms\":{\"feature_importance\":false}},\"excluded\":false}]"
  
  func parseRawAllocations(raw: String) -> [JSON] {
    var allocations = [JSON]()
    if let dataFromString = raw.data(using: String.Encoding.utf8, allowLossyConversion: false) {
      allocations = try! JSON(data: dataFromString).arrayValue
    }
    return allocations
  }
  
  func testGetEntryEmptyCache() {
    let testCacheSize = 10
    let testKey = "test_key"
    
    let cache = LRUCache(testCacheSize)
    let entry = cache.getEntry(testKey)
    
    XCTAssertNotNil(entry)
    XCTAssertTrue(entry.isEmpty)
  }
  
  func testGetEntry() {
    let testCacheSize = 10
    let testKey = "test_key"
    let testEntry = parseRawAllocations(raw: rawAllocation)
    
    let cache = LRUCache(testCacheSize)
    cache.putEntry(testKey, val: testEntry)
    let entry = cache.getEntry(testKey)
    
    XCTAssertNotNil(entry)
    XCTAssertFalse(entry.isEmpty)
    XCTAssertEqual(testEntry, entry)
  }
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
