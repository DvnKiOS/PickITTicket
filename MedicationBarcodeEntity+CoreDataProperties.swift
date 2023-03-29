//
//  MedicationBarcodeEntity+CoreDataProperties.swift
//  
//
//  Created by Devin King on 2/17/23.
//
//

import Foundation
import CoreData


extension MedicationBarcodeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MedicationBarcodeEntity> {
        return NSFetchRequest<MedicationBarcodeEntity>(entityName: "MedicationBarcodeEntity")
    }

    @NSManaged public var amountPicked: Int16
    @NSManaged public var medicationBarcode: String?
    @NSManaged public var medicationBrand: String?
    @NSManaged public var medicationName: String?

}
