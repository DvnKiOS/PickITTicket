//
//  MedicationBarcodeManager.swift
//  PickiTTicket
//
//  Created by Devin King on 1/31/23.
//

import Foundation
protocol MedicationBarcodeManagerDelegate {
    func didUpdateMedicationBarcode(barcode: MedicationBarcodeModel)
}


struct MedicationBarcodeManager {
    
    
    
    
    //var urlString = "https://api.fda.gov/drug/ndc.json?search=product_ndc:63323-729&limit=1"
    
    var testNDC = "product_ndc:63323-729&limit=1"
    
    var delegate: MedicationBarcodeManagerDelegate?
    
    
    func fetchMedicationBarcode(barcode:String)      {
        
        //let limitString = "&limit=1"
        
        
//        let medicationBarcodeString = "https://api.fda.gov/drug/ndc.json?search=product_ndc:\(barcode)&\(limitString)"
        let medicationBarcodeString = "https://api.fda.gov/drug/ndc.json?search=product_ndc:\(barcode)&limit=1"
       performMedicationRequest(urlString: medicationBarcodeString)
        
        
        
    }
    
    
    func performMedicationRequest(urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    if let safeBarcodeData = data {
                        
                        if self.parseJSON(safeBarcodeData) != nil {
                            
                            
                         
                            
                        }
                        
                        
                        
                        //print(deviceBarcodeData)
                        //self.delegate?.addDeviceBarcodeData( barcode: deviceBarcodeData) // ->  in this situation our activeURl is going to act as our Data.
                    }
                    
                }
            }
            task.resume()
        }
        
    }
    func parseJSON(_ barcodeData: Data) -> MedicationBarcodeModel? {
        let decoder = JSONDecoder()
        
        do{
            let decodedMedicationData = try decoder.decode(MedicationBarcodeData.self, from: barcodeData)
            
            let medicationBrandName =  decodedMedicationData.results[0].brand_name
            let medicationNDC = decodedMedicationData.results[0].product_ndc
           
            let medicationManufacture = decodedMedicationData.results[0].labeler_name
            let startingAmount = "1"
            
            let medicationBarcodeData = MedicationBarcodeModel(medicationName: medicationBrandName, medicationBrand: medicationManufacture, medicationBarcode: medicationNDC, amountPicked: startingAmount)

           
            
            
           print(medicationBarcodeData)
            
         
            delegate?.didUpdateMedicationBarcode(barcode: medicationBarcodeData)
          
            
            
            
            
         
            
            
            return medicationBarcodeData
        } catch{
            print(error)
            return nil
            
        }
        
        
        
        
    }
        
    }
    
    
    
    
    
    



