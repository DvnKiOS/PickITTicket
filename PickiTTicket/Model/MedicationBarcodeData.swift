//
//  MedicationBarcodeData.swift
//  PickiTTicket
//
//  Created by Devin King on 1/31/23.
//

import Foundation

struct MedicationBarcodeData: Decodable {
    let meta: Meta
    let results: [Result]
    
}
    
    
    
    
    struct Meta: Decodable {
        let disclaimer: String
        let terms: String
        let license: String
        let last_updated: String?
        
        
 
        
  
    }
    
    
    //let meta: Meta
    struct Result: Decodable {
        let product_ndc: String
        let generic_name: String
        let labeler_name: String
        let brand_name: String
        
        
        struct ActiveIngredient: Decodable {
            let name: String
            let strength: String
        }
      
        struct Packaging: Decodable {
          
            let description: String
         
        }
        let packaging: [Packaging]
        
        
    }
    
