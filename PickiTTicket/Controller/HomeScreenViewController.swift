//
//  HomeScreenViewController.swift
//  PickiTTicket
//
//  Created by Devin King on 1/31/23.
//

import UIKit
import SCLAlertView


class HomeScreenViewController: UIViewController {

    @IBOutlet weak var deviceManagerButton: UIButton!
    
    @IBOutlet weak var medicationManagerButton: UIButton!
    
    var deviceManagerButtonString = ""
    var medicationManagerButtonString = ""
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        var charIndex = 0.0
            let titleText = "Device Manager"
            self.deviceManagerButton.setTitle("", for: .normal)
            for letter in titleText {
                Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in
                    self.deviceManagerButton.setTitle(self.deviceManagerButton.title(for: .normal)! + String(letter), for: .normal)
                }
                charIndex += 1
            }

        
            
    }
   
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
