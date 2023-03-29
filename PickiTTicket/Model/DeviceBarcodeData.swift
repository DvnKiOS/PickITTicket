//
//  BarcodeData.swift
//  PickiTTicket
//
//  Created by Devin King on 1/14/23.
//

import Foundation



struct DeviceBarcodeData: Codable {
    
    
    let device: Device
}

struct GUDID: Codable {
    let gudid: DeviceBarcodeData
}



struct Device: Codable {
  
    
    let identifiers: Identifiers
    let brandName: String
   
    let deviceCount: Int
    let deviceDescription: String

    
    
    struct Identifiers: Codable {
        let identifier: [Identifier]
    }

    struct Identifier: Codable {
        let deviceId: String
      
    }
    

}











