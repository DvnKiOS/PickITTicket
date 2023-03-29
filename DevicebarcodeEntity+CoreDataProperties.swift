//
//  DevicebarcodeEntity+CoreDataProperties.swift
//  
//
//  Created by Devin King on 2/17/23.
//
//

import Foundation
import CoreData


extension DevicebarcodeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DevicebarcodeEntity> {
        return NSFetchRequest<DevicebarcodeEntity>(entityName: "DevicebarcodeEntity")
    }

    @NSManaged public var currentBarcode: String?
    @NSManaged public var currentItemTitle: String?
    @NSManaged public var itemQuantity: Int16
    @NSManaged public var manufactureName: String?

}
