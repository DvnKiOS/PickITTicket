//
//  BarcodeModel.swift
//  PickiTTicket
//
//  Created by Devin King on 1/14/23.
//

import Foundation
import CoreData



class DeviceBarcodeModel: Codable {
    var currentBarcode: String
    var currentItemTitle: String
    var itemQuantity: Int
    var manufactureName: String
    var managedObjectContext: NSManagedObjectContext?
     
    init(currentBarcode: String, currentItemTitle: String, itemQuantity: Int, manufactureName: String) {
        self.currentBarcode = currentBarcode
        self.currentItemTitle = currentItemTitle
        self.itemQuantity = itemQuantity
        self.manufactureName = manufactureName
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currentBarcode, forKey: .currentBarcode)
        try container.encode(currentItemTitle, forKey: .currentItemTitle)
        try container.encode(itemQuantity, forKey: .itemQuantity)
        try container.encode(manufactureName, forKey: .manufactureName)
    }
    
    private enum CodingKeys: String, CodingKey {
        case currentBarcode
        case currentItemTitle
        case itemQuantity
        case manufactureName
    }
}





