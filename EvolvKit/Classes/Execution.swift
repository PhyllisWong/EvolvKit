//
//  Execution.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol Default {
  associatedtype T
}


class Execution<T> {
  
  private let key: String
  private let function: (Any) -> Void
  private let participant: EvolvParticipant
  private var defaultValue: T
  private var alreadyExecuted: Set<String> = Set()
  
  init(_ key: String,
       _ defaultValue: T,
       _ function: @escaping (Any) -> Void,
       _ participant: EvolvParticipant) {
    self.key = key
    self.defaultValue = defaultValue
    self.function = function as! (Any) -> Void
    self.participant = participant
  }
  
  func getKey() -> String { return key }
  
  func getMyType(_ element: Any) -> Any.Type {
    return type(of: element)
  }
  
  func executeWithAllocation(rawAllocations: [JSON]) throws -> Void {
    let type = getMyType(defaultValue)
    let allocations = Allocations(allocations: rawAllocations)
    let optionalValue = try allocations.getValueFromAllocations(key, type, participant)
    print("optioanl value: \(String(describing: optionalValue))")
    // this is optional needs to be unwrapped
    guard let value = optionalValue else {
      throw EvolvKeyError.errorMessage
    }
    print("unwrapped value: \(String(describing: value))")
    let activeExperiements = allocations.getActiveExperiments()
    if alreadyExecuted.isEmpty || alreadyExecuted == activeExperiements {
      // there was a change to the allocations after reconciliation, apply changes
      function(value as Any)
    }
    alreadyExecuted = activeExperiements
  }
  
  func executeWithDefault() -> Void {
    function(defaultValue)
  }
}
