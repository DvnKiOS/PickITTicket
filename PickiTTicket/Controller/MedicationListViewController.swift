//
//  MedicationPickListHomeScreenViewContrllerViewController.swift
//  PickiTTicket
//
//  Created by Devin King on 1/31/23.
//

import UIKit
import CoreData
import SCLAlertView


class MedicationListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MedicationBarcodeManagerDelegate, MedicationBarcodeScannerViewControllerDelegate {
    
    
    
    
    
    
    var medicationPickList: [MedicationBarcodeModel] = []
    
    let medicationListCellIdentifier = "medicationItem"
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var medicationListTableView: UITableView!
    
    @IBOutlet weak var amountOfBoxesPickedLabel: UILabel!
    var medicationBarcodeManger = MedicationBarcodeManager()
    
    var medicationBarcodeScanner = MedicationBarcodeScannerViewController()
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    var urlString = "https://api.fda.gov/drug/ndc.json?search=product_ndc:67457-349&limit=1"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        medicationListTableView.delegate = self
        medicationListTableView.dataSource = self
        medicationBarcodeManger.delegate = self
        medicationBarcodeScanner.delegate = self
        
        
    
        medicationListTableView.register(UINib(nibName: "pickedItemTableViewCell", bundle: nil), forCellReuseIdentifier: "pickedItemCell")

        // Do any additional setup after loading the view.
    }
    
    @IBAction func scanMedicationButton(_ sender: UIButton) {
        performSegue(withIdentifier: "medicationScannerSegue", sender: self)
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) { // -> This line is block of code is extremely important to make sure the delegate is set correctly when the scan button is tapped. we want to make sure the data we get back is ready for us to use at the point when we get back to our medication list. 
          if segue.identifier == "medicationScannerSegue" {
              let medScanVC = segue.destination as! MedicationBarcodeScannerViewController
              medScanVC.delegate = self
            
          }
      }
    
    @IBAction func sendMedicationListButton(_ sender: UIButton) {
        
        self.medicationPickList = []
        self.medicationListTableView.reloadData()
        self.amountOfBoxesPickedLabel.text = "Medications Picked: \(self.medicationPickList.count)"
        
        
    }
    
    @IBAction func addCustomMedicationButton(_ sender: UIBarButtonItem) {
       showAlert()
        
        
        
        
        
        
    }
    
    
    
    func saveMedicationData(Data: DeviceBarcodeModel) {
        
        let medicationDataToSave = MedicationBarcodeModel(medicationName: Data.currentItemTitle, medicationBrand: Data.manufactureName, medicationBarcode: Data.currentItemTitle, amountPicked: Data.itemQuantity)
        
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medicationPickList.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
        return "MedicationList"
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = .black
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "pickedItemCell", for: indexPath) as! pickedItemTableViewCell // -> fixed a bug. since we are using our custom tableview cell we have to make sure we are using the identifiers we created while creating said cell. fixing this allows our custom tableviewcells to be added to our tableview.
        
        cell.pickedItemTitleLabel.text = "Item Picked: \(medicationPickList[indexPath.row].medicationName)"
        cell.currentBarcodeLabel.text =  "Barcode: \(medicationPickList[indexPath.row].medicationBarcode )"
        cell.amountOfItemPickedLabel.text = "Total Picked: \(medicationPickList[indexPath.row].amountPicked)"
        cell.deviceBrandLabel.text =    "Manufacture: \(medicationPickList[indexPath.row].medicationBrand)"
        cell.addShadow()
       
        return cell
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       if editingStyle == .delete {
           medicationPickList.remove(at: indexPath.row)
           tableView.deleteRows(at: [indexPath], with: .fade)
           amountOfBoxesPickedLabel.text = "Boxes Picked: \(medicationPickList.count)"
           
       } else if editingStyle == .insert {
           // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
       }
   }
    
    func showAlert() {
        
        let alert = UIAlertController(title: "Add Item", message: "Enter an item to add to the list", preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Item Name"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Amount Picked"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Item Barcode"
        }
        
        
        alert.addTextField { (textField) in
            textField.placeholder = "Item Manufacture"
            
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            let itemName = alert.textFields?[0].text ?? ""
            let amountPicked = alert.textFields?[1].text ?? ""
            let itemBarcode = alert.textFields?[2].text ?? ""
            let itemBrand = alert.textFields?[3].text ?? ""
            
          let amountPicked2 =  Int(amountPicked)
            
            let item =  MedicationBarcodeModel(medicationName: itemName, medicationBrand: itemBrand, medicationBarcode: itemBarcode, amountPicked: amountPicked2!)
            self.medicationPickList.append(item)
            //self.saveData(deviceBarcodeModel: item)
         
            print(self.medicationPickList.count)
            let indexPath = IndexPath(row: self.medicationPickList.count - 1, section: 0)
            self.medicationListTableView.insertRows(at: [indexPath], with: .automatic)
            DispatchQueue.main.async {
                self.amountOfBoxesPickedLabel.text = "Boxes Picked: \(self.medicationPickList.count)"
              
            }
        }
        alert.addAction(addAction)
        present(alert, animated: true, completion: nil)
        
        
    }
    func didUpdateMedicationBarcode(barcode: MedicationBarcodeModel) {
        let medicationName = barcode.medicationName
        let medicationAmount = barcode.amountPicked
        let medicationBrand = barcode.medicationBrand.dropLast(1)
        let medicationBarcode = barcode.medicationBarcode
        
        let newMedication = MedicationBarcodeModel(medicationName: String(medicationName), medicationBrand: String(medicationBrand), medicationBarcode: medicationBarcode, amountPicked: medicationAmount)
        
        
        print(newMedication)
        
        DispatchQueue.main.async {
            self.medicationPickList.append(newMedication)
            self.medicationListTableView.reloadData()
        }
        
       // medicationListTableView.reloadData()
        
    }
    func didScanBarcode(_ barcode: String) {
        medicationBarcodeManger.fetchMedicationBarcode(barcode: barcode)
        print("hay")
    }

}
