//
//  CustomAlerts.swift
//  PickiTTicket
//
//  Created by Devin King on 2/10/23.
//

import Foundation
import UIKit
import SCLAlertView






public func customEntry() {
    
    let appearance = SCLAlertView.SCLAppearance(
      kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
      kTextFont: UIFont(name: "HelveticaNeue", size: 8)!,
        kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 16)!,
        showCloseButton: false
   )


    
    
  
  
   

    // Initialize SCLAlertView using custom Appearance
    let alert = SCLAlertView(appearance: appearance)
   // let alertViewIcon = UIImage(named: "barcode")

    // Create the subview
    let subview = UIView(frame: CGRectMake(0,0,250,150))
    let x = (subview.frame.width - 240) / 2

    // Add the label
    let label1 = UILabel(frame: CGRectMake(x, 10, 90, 25))
    label1.text = "Medication:"
    label1.textAlignment = .left
    label1.font = UIFont(name: "Thonburi-Bold", size: 10)
    label1.textColor = .black
    subview.addSubview(label1)

    let textfield1 = UITextField(frame: CGRectMake(x + 90, 10, 90, 25))
    textfield1.layer.borderColor = UIColor.systemYellow.cgColor
    textfield1.layer.borderWidth = 1.5
    textfield1.layer.cornerRadius = 5
    textfield1.placeholder = "Cefepime"
    textfield1.textAlignment = NSTextAlignment.center
    subview.addSubview(textfield1)

    let label2 = UILabel(frame: CGRectMake(x, textfield1.frame.maxY + 10, 80, 25))
    label2.text = "Amount Picked:"
    label2.textAlignment = .left
    label2.font = UIFont(name: "Thonburi-Bold", size: 10)
    subview.addSubview(label2)

    let textfield2 = UITextField(frame: CGRectMake(x + 90, textfield1.frame.maxY + 10, 90, 25))
    textfield2.isSecureTextEntry = true
    textfield2.layer.borderColor = UIColor.systemYellow.cgColor
    textfield2.layer.borderWidth = 1.5
    textfield2.layer.cornerRadius = 5
   
    textfield2.placeholder = "15"
    textfield2.textAlignment = NSTextAlignment.center
    subview.addSubview(textfield2)
    
    
    let label3 = UILabel(frame: CGRectMake(x, textfield2.frame.maxY + 10, 80, 25))
    label3.text = "Brand:"
    label3.textAlignment = .left
    label3.font = UIFont(name: "Thonburi-Bold", size: 10)
    subview.addSubview(label3)
    
    let textfield3 = UITextField(frame: CGRectMake(x + 90 ,textfield2.frame.maxY + 10,90,25))
    textfield3.isSecureTextEntry = true
    textfield3.layer.borderColor = UIColor.systemYellow.cgColor
    textfield3.layer.borderWidth = 1.5
    textfield3.layer.cornerRadius = 5
    textfield3.textColor = .black
  
    textfield3.placeholder = "BD"
    textfield3.textAlignment = NSTextAlignment.center
    subview.addSubview(textfield3)

    // Add the subview to the alert's UI property
    
    
    
    
    
    alert.customSubview = subview
    alert.addButton("OK", backgroundColor: UIColor.systemYellow, textColor: UIColor.black) {
        //print("\(textfield1.text!) ayeeeee \(textfield2.text!)")
    }
    
    
    
    
    

    // Add Button with Duration Status and custom Colors
    alert.addButton("Cancel", backgroundColor: UIColor.systemYellow, textColor: UIColor.black) {
        //print("Duration Button tapped")
    }

    alert.showCustom("Edit Entry", subTitle: "", color: UIColor.systemYellow, icon: UIImage(named: "barcode")!)
    
}

 
    
    


public func errorAlert() {
    
    
}
public func barcodError() {
    
    
}

