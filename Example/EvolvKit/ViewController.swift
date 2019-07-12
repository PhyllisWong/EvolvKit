//
//  ViewController.swift
//  EvolvKit
//
//  Created by PhyllisWong on 07/03/2019.
//  Copyright (c) 2019 PhyllisWong. All rights reserved.
//

import UIKit
import SwiftyJSON
import EvolvKit


class ViewController: UIViewController {
  
  @IBOutlet weak var textLabel: UILabel!
  
  let store : AllocationStoreProtocol
  var allocations = [JSON]()
  var client : EvolvClientProtocol?
  var httpClient: HttpProtocol
  let LOGGER = Log.logger
  
  @IBAction func didPressCheckOut(_ sender: Any) {
    client?.emitEvent(key: "conversion")
    self.textLabel.text = "Conversion!"
  }
  
  @IBAction func didPressProductInfo(_ sender: Any) {
    self.textLabel.text = "Some really cool product info!"
  }
  
  required init?(coder aDecoder: NSCoder) {
    /*
     When you get the json from the participants API, it will come as a string of json array.
     If you use the EvolvHttpClient, the json will be parsed with SwiftyJSON. This example shows
     how the data is structures, but will be obfuscated in your implementation.
     */
    let myStoredAllocation = "[{\"uid\":\"sandbox_user\",\"eid\":\"experiment_1\",\"cid\":\"candidate_3\",\"genome\":{\"ui\":{\"layout\":\"option_1\",\"buttons\":{\"checkout\":{\"text\":\"Begin Secure Checkout\",\"color\":\"#f3b36d\"},\"info\":{\"text\":\"Product Specifications\",\"color\":\"#f3b36d\"}}},\"search\":{\"weighting\":3.5}},\"excluded\":true}]"
    // let myStoredAllocation = "[{\"uid\":\"sandbox_user\",\"eid\":\"experiment_1\",\"cid\":\"candidate_3\",\"genome\":{\"ui\":{\"layout\":\"option_2\",\"buttons\":{\"checkout\":{\"text\":\"Begin Secure Checkout\",\"color\":\"#f3b36d\"},\"info\":{\"text\":\"Product Specifications\",\"color\":\"#f3b36d\"}}},\"search\":{\"weighting\":3.5}},\"excluded\":true}]"
    // let myStoredAllocation = "[{\"uid\":\"sandbox_user\",\"eid\":\"experiment_1\",\"cid\":\"candidate_3\",\"genome\":{\"ui\":{\"layout\":\"option_3\",\"buttons\":{\"checkout\":{\"text\":\"Begin Secure Checkout\",\"color\":\"#f3b36d\"},\"info\":{\"text\":\"Product Specifications\",\"color\":\"#f3b36d\"}}},\"search\":{\"weighting\":3.5}},\"excluded\":true}]"
    store = CustomAllocationStore()
    
    if let dataFromString = myStoredAllocation.data(using: String.Encoding.utf8, allowLossyConversion: false) {
      do {
        self.allocations = try JSON(data: dataFromString).arrayValue
        store.set(uid: "sandbox_user", allocations: self.allocations)
      } catch {
        LOGGER.log(.error, message: "Error converting string json to SwiftyJSON")
      }
    }
    
    httpClient = EvolvHttpClient()
    
    // build config with custom timeout and custom allocation store
    // set client to use sandbox environment
    let config = EvolvConfig.builder(environmentId: "sandbox", httpClient: httpClient)
      .setEvolvAllocationStore(allocationStore: store)
      .build()
    
    // initialize the client with a stored user
    client = EvolvClientFactory(config: config, participant: EvolvParticipant.builder()
      .setUserId(userId: "sandbox_user").build()).client as! EvolvClientImpl
    
//    // initialize the client with a new user
//        client = AscendClientFactory.init(config)
   
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Retrieve allocations in the background as the first thing.

    guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
    statusBarView.backgroundColor = UIColor(red: 0.0, green: 0.3, blue: 0.3, alpha: 1.0)
    _ = getJsonData()
    
    client?.subscribe(key: "ui.layout", defaultValue: "#ffffff", function: setContentViewWith)
    client?.confirm()

  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}

private extension ViewController {
  
  private func onCreate() -> Void {


  }
  
  func printStuff(value: Any) {
    print("DO STUFF with \(value)")
  }
  
//  func layoutOption () {
//    // here I want to get the value at key
//    DispatchQueue.main.async { [weak self] in
//      self?.setContentViewWith(layoutOption)
//    }
//  }
  
  func setContentViewWith(_ layoutOption: Any) -> () {
    let json = layoutOption as! JSON
    if let stringOption = json.rawString() {
      print("siiiiick! \(stringOption)")
      switch stringOption {
      case "option_1":
        self.view.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0)
        
      case "option_2":
        self.view.backgroundColor = UIColor(red: 0.6, green: 0.9, blue: 0.5, alpha: 1.0)
        
      case "option_3":
        self.view.backgroundColor = UIColor(red: 32/255, green: 79/255, blue: 79/255, alpha: 1)
        
      case "option_4":
        self.view.backgroundColor = UIColor(red: 59/255, green: 144/255, blue: 147/255, alpha: 1)
      default:
        self.view.backgroundColor = UIColor(red: 219/255, green: 254/255, blue: 248/255, alpha: 1)
      }
    }
  }
  
  private func getJsonData() -> String {
    guard let client = self.client else { return "" }
    let key = "someKey"
    // get this to execute on the main thread and change the UI
    
    // Client makes the call to get the allocations
   
    client.emitEvent(key: key, score: 1.0)
    // client.contaminate()
    return key
  }
}

