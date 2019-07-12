//
//  Allocations.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import SwiftyJSON

public class Allocations {
  let allocations: [JSON]
  let audience : Audience = Audience()
  let LOGGER = Log.logger
  
  init (allocations: [JSON]) {
    self.allocations = allocations
  }
  
  func getMyType<T>(_ element: T) -> Any? {
    return type(of: element)
  }
  
  // FIXME: clean this up!
  func getValueFromAllocations<T>(_ key: String, _ type: T, _ participant: EvolvParticipant) throws -> JSON? {
    let keyParts = key.components(separatedBy: ".")
    
    if (keyParts.isEmpty) {
      throw EvolvKeyError(rawValue: "Key provided was empty.")!
    }
    
    for a in self.allocations {
      print("A: \(a)")
      let genome = a["genome"]
      let element = try getElementFromGenome(genome: genome, keyParts: keyParts)
      print("element: \(element)")
      if element.error == nil {
        return element
      } else {
        throw EvolvKeyError.errorMessage
      }
    }
    let errorJson = JSON([key: "Unable to find key in experiment"])
    return errorJson
  }
  
  private func getElementFromGenome(genome: JSON, keyParts: [String]) throws -> JSON {
    var element: JSON = genome
    if element.count <= 0 {
      throw EvolvKeyError(rawValue: "Allocation genome was empty")!
    }
    
    for part in keyParts {
      let object = element[part]
      element = object
    
      if (element.error == nil) {
        // throw EvolvKeyError(rawValue: "element fails")!
        LOGGER.log(.error, message: "Element fails")
      }
    }
    print("element: \(element)")
    return element
  }
  
  static public func reconcileAllocations(previousAllocations: [JSON], currentAllocations: [JSON]) -> [JSON] {
    var allocations = [JSON]()
    
    for ca in currentAllocations {
      let currentEid = String(describing: ca["eid"])
      var previousFound = false
      
      for pa in previousAllocations {
        let previousEid = String(describing: pa["eid"])
        
        if currentEid.elementsEqual(previousEid) {
          allocations.append(pa)
          previousFound = true
        }
      }
      if !previousFound { allocations.append(ca) }
    }
    return allocations
  }
  
  
  public func getActiveExperiments() -> Set<String> {
    var activeExperiments = Set<String>()
    for a in allocations {
      let eid = String(describing: a["eid"])
      activeExperiments.insert(eid)
    }
    return activeExperiments
  }
}
