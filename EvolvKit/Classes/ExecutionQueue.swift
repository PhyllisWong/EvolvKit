//
//  ExecutionQueue.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

public class ExecutionQueue<T> {
  private let LOGGER = Log.logger
  private var queue : LinkedQueue<Execution<T>>
  
  init () {
    self.queue = LinkedQueue<Execution<T>>()
  }
  
  func enqueue<T>(execution: Execution<T>) {
    self.queue.add(execution)
  }
  
  func executeAllWithValuesFromAllocations(allocations: [JSON]) throws {
    while !queue.isEmpty {
      let execution: Execution = queue.remove()!
      
      do {
        try execution.executeWithAllocation(rawAllocations: allocations)
      } catch let err {
        let message = "There was an error retrieving the value of " +
          "\(execution.getKey()) from the allocation. \(err.localizedDescription)"
        LOGGER.log(.debug, message: message)
        execution.executeWithDefault()
        throw EvolvKeyError.keyError
      }
    }
  }
  
  func executeAllWithValuesFromDefaults() {
    while !queue.isEmpty {
      let execution: Execution = queue.remove()!
      execution.executeWithDefault()
    }
  }
}
