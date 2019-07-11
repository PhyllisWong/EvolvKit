//
//  AllocationStoreProtocol.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

public protocol AllocationStoreProtocol {
  
  /**
   Retrieves a JsonArray.
   - Retrieves a JsonArray converted to json using SwiftyJSON. JsonArray represents the participant's allocations.
   If there are no stored allocations, should return an empty SwiftyJSON array.
   - Parameters:
      - uid: The participant's unique id.
   - Returns: a SwiftyJSON array of allocation if one exists, else an empty SwiftyJSON array.
   */
  
  func get(uid: String) -> [JSON]?
  
  /**
   Stores a JsonArray.
   - Stores the given SwiftyJSON array.
   - Parameters:
      - uid: The participant's unique id.
      - allocations: The participant's allocations.
   */
  func set(uid: String, allocations: [JSON]) -> ()
}
