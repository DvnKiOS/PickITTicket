//
//  MedicationBarcodeModel.swift
//  PickiTTicket
//
//  Created by Devin King on 1/31/23.
//

import Foundation

struct MedicationBarcodeModel: Codable {
    let medicationName: String
    let medicationBrand: String
    let medicationBarcode: String
    let amountPicked: Int
    
}
