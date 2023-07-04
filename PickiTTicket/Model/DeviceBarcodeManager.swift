//
//  BarcodeManager.swift
//  PickiTTicket
//
//  Created by Devin King on 1/14/23.
//

import Foundation
import SCLAlertView

protocol DeviceBarcodeManagerDelegate{
    func didUpdateDeviceBarcodeData(barcode: DeviceBarcodeModel)
}








struct DeviceBarcodeManager {
    
    var delegate: DeviceBarcodeManagerDelegate?
    
     
    
    
    
    
    let barcodeURl : String = "https://accessgudid.nlm.nih.gov/api/v2/devices/lookup.json?di="
    

    
    

    
    
    func fetchBarcode(barcode: String) {
        
        let barcodeUrlString = "https://accessgudid.nlm.nih.gov/api/v2/devices/lookup.json?di=\(barcode)"
        
     
        performRequest(urlString: barcodeUrlString)
    }
    
    
    
    
    
    func performRequest(urlString: String) {
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { data, response, error in
                
                if error != nil {
                    DispatchQueue.main.async {
                        let errorAlert = SCLAlertView()
                            errorAlert.showInfo("Networking Error ", subTitle: "An internet connection is needed to fetch barcode information. Please try again later")
                    }
    
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
    
    
    func parseJSON(_ barcodeData: Data) -> DeviceBarcodeModel? {
        
        let decoder = JSONDecoder()
        
        do{
            let decodedData = try decoder.decode(GUDID.self, from: barcodeData)
            let deviceName = decodedData.gudid.device.deviceDescription
        
            let brandName = decodedData.gudid.device.brandName
            
            
            let deviceCount = decodedData.gudid.device.deviceCount
            let deviceID = decodedData.gudid.device.identifiers.identifier[0].deviceId
//            print(deviceName)
//            print(deviceCount)
//            print(brandName)
//            print(deviceID)
//            print(deviceNameString)
            let newDeviceName = deviceName.dropFirst(8)
            print(newDeviceName)
            let anotherDeviceName = newDeviceName.replacingOccurrences(of: ",", with: "")

            
            print(anotherDeviceName)
            let barcode =
            DeviceBarcodeModel(currentBarcode: deviceID,
                               currentItemTitle:String(anotherDeviceName),
                               itemQuantity: deviceCount,
                               manufactureName: brandName)
            delegate?.didUpdateDeviceBarcodeData(barcode: barcode)
            
            
           print(barcode)
            
         
           
          
            
            
            
            
         
            
            
            return barcode
        } catch{
            DispatchQueue.main.async {
                let barcodeErrorAlert = SCLAlertView()
                 barcodeErrorAlert.showInfo("Error", subTitle: "Error Scanning Barcode, Wrong Barcode Format Scanned")
            }
           
            return nil
            
        }
        
        
        
        
    }
}
    

