//
//  EvolvClientProtocol.swift
//  EvolvKit_Example
//
//  Created by phyllis.wong on 7/3/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

public protocol EvolvClientProtocol {
  /**
   Retrieves a value from the participant's allocation, returns a default upon error.
   
   - Given a unique key this method will retrieve the key's associated value. A
   default value can also be specified in case any errors occur during the values
   retrieval. If the allocation call times out or fails the default value is
   always returned. This method is blocking, it will wait till the allocation
   is available and then return.
   
   - Parameters:
      - key: A unique key identifying a specific value in the participants allocation.
      - defaultValue: A default value to return upon error.
      - <T>: Type of value to be returned.
   - Returns: a value associated with the given key
   */
  func get<T>(key: String, defaultValue: T) -> Any
  
  /**
   Retrieves a value from Evolv asynchronously and applies some custom action.
   
   - This method is non blocking. It will preform the programmed action once
   the allocation is available. If there is already of stored allocation
   it will immediately apply the value retrieved and then when the new
   allocation returns it will reapply the new changes if the experiment
   has changed.
   
   - Parameters:
   - key: A unique key identifying a specific value in the participants allocation.
   - defaultValue: A default value to return upon error.
   - function:  a handler that is invoked when the allocation is updated
   - <T>: type of value to be returned
   - Returns: a value associated with the given key
   */
  func subscribe(key: String, defaultValue: Any, function: @escaping (Any) -> Void)
  
  
  /**
   Emits a generic event to be recorded by Evolv.
   - Sends an event to Evolv to be recorded and reported upon. Also records
   a generic score value to be associated with the event.
   - Parameters:
       - key: The identifier of the event.
       - score: A score to be associated with the event.
   */
  
  func emitEvent(key: String, score: Double) -> Void
  
  /**
   Emits a generic event to be recorded by Evolv.
   - Sends an event to Evolv to be recorded and reported upon.
   - Parameters:
      - key: The identifier of the event.
   */
  func emitEvent(key: String) -> Void
  
  /**
   Sends a confirmed event to Evolv.
   - Method produces a confirmed event which confirms the participant's
   allocation. Method will not do anything in the event that the allocation
   timed out or failed.
   */
  func confirm() -> Void
  
  /**
   Sends a contamination event to Evolv.
   - Method produces a contamination event which will contaminate the
   participant's allocation. Method will not do anything in the event
   that the allocation timed out or failed.
   */
  func contaminate() -> Void
}
