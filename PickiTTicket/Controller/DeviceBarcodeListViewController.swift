//
//  ViewController.swift
//  PickiTTicket
//
//  Created by Devin King on 1/13/23.
//

import UIKit
import CoreData
import SCLAlertView


//Mark: - HomeScreen

class DeviceBarcodeListViewController: UIViewController {
   
    
    var pickedItems:  [DeviceBarcodeModel] = []  // -> we want the array of pickedItems to be an empty array of DeviceModel Objects
    let entityName = "DevicebarcodeEntity"

    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
    
    var deviceBarcodeManager = DeviceBarcodeManager()
    
    var scannerViewController = ScannerViewController()
    let cellSpacingHeight: CGFloat = 5
    

  
    
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var pickListTableView: UITableView!
    
    @IBOutlet weak var scanButton: UIButton!
    
    @IBOutlet weak var sendListButton: UIButton!
    @IBOutlet weak var totalItemsPickedLabel: UILabel!
    var currentDateString: String = ""
    
    var pickedItemCell = "pickedItemCell"
    
    
  
   
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scanButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        

        loadData()
        

        self.navigationItem.title = "Device List💉"
        
   
      
        
        pickListTableView.dataSource = self
        pickListTableView.delegate = self
          
        scannerViewController.delegate = self
        
        pickListTableView.register(UINib(nibName: "pickedItemTableViewCell", bundle: nil), forCellReuseIdentifier: pickedItemCell) // ->  Dont forget to register the nibs we have created to make to free to use on our currentTableView.
        pickListTableView.layer.cornerRadius = 10.0
        
        deviceBarcodeManager.delegate = self
        
        
        sendListButton.addShadow()
        sendListButton.layer.cornerRadius = 10.0
        
        scanButton.addShadow()
        scanButton.layer.cornerRadius = 10.0
        
        //        pickListTableView.addShadow() BUG CODE: Causes the tableview to expand beyond the its current bounds. REMEMBER: We can use our custom add shadow method on our tableView with our current implementation without causing bugs.
        pickListTableView.layer.cornerRadius = 10.0
        
        
        totalItemsPickedLabel.text = (" Boxes Picked: \(pickedItems.count)")

        totalItemsPickedLabel.text = "Boxes Picked: \(pickedItems.count)"
       
       
    
    }
    
   
    
    
    @IBAction func scanNewItemButton(_ sender: UIButton) {
        // -> Currently this is going to present our scannerViewController. More functions to come later
        
        
        
     performSegue(withIdentifier: "ScannerSegue", sender: self)
        
        
        
       
        
       
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "ScannerSegue" {
              let scannerViewController = segue.destination as! ScannerViewController
              scannerViewController.delegate = self
            
          }
      }
    func sendTableViewData() {
        let filename = "Device List: \(updateDateLabel()).csv"
           let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
           
           var csvText = "Device Name   ,Manufacture   ,Total Picked   ,Barcode   \n"
           for item in pickedItems {
               csvText += "\(item.currentItemTitle)  ,\(item.manufactureName)  ,\(item.itemQuantity)  ,\(item.currentBarcode)  \n"
           }
           
           do {
               try csvText.write(to: path!, atomically: true, encoding: .utf16)
           } catch {
               print("Failed to write file")
           }
           
           let activityViewController = UIActivityViewController(activityItems: [path!], applicationActivities: nil)
           present(activityViewController, animated: true, completion: nil)
       }
    
   
    
    
  

    
    @IBAction func sendPickListButton(_ sender: UIButton) {
        
      
        sendTableViewData()
        
        
        DispatchQueue.main.async {
            self.refreshDeviceBarcodeTableView()
            self.pickedItems = []  
            self.pickListTableView.reloadData()
            self.totalItemsPickedLabel.text = "Boxes Picked: \(self.pickedItems.count)"
           
            
        }
        
      
    }
    
    
    @IBAction func addCustomPickItem(_ sender: UIBarButtonItem) {
        addCustomEntry()
       
        
        
        
    }
   
   
    
    
    func updateDateLabel() -> String {
       
        let today = Date.now
        let formatter1 = DateFormatter()
        formatter1.dateStyle = .medium
        let formattedDate = (formatter1.string(from: today))
        currentDateString = formattedDate
    
        
        return(currentDateString)
    }
    
    
    // Save the data to Core Data
    func saveData(deviceBarcodeModel: DeviceBarcodeModel) {
        let deviceBarcodeModel = DeviceBarcodeModel(currentBarcode: deviceBarcodeModel.currentBarcode, currentItemTitle: deviceBarcodeModel.currentItemTitle, itemQuantity: deviceBarcodeModel.itemQuantity, manufactureName: deviceBarcodeModel.manufactureName)

        // Create a managed object
          let managedObject = NSEntityDescription.insertNewObject(forEntityName: "DevicebarcodeEntity", into: managedObjectContext)

        // Set the managed object's attributes with the values from the struct
        managedObject.setValue(deviceBarcodeModel.currentBarcode, forKey: "currentBarcode")
        managedObject.setValue(deviceBarcodeModel.currentItemTitle, forKey: "currentItemTitle")
        managedObject.setValue(deviceBarcodeModel.itemQuantity, forKey: "itemQuantity")
        managedObject.setValue(deviceBarcodeModel.manufactureName, forKey: "manufactureName")
        print("The managed objects have properties")

        // Save the changes
        do {
          try managedObjectContext.save()
            print("We have saved the changes")
        } catch let error as NSError {
          print("Error saving data: \(error.localizedDescription)")
        }
      }
  
    func loadData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DevicebarcodeEntity")

        do {
            let results = try managedObjectContext.fetch(fetchRequest)

            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    let currentBarcode = result.value(forKey: "currentBarcode") as! String
                    let currentItemTitle = result.value(forKey: "currentItemTitle") as! String
                    let itemQuantity = result.value(forKey: "itemQuantity") as! Int
                    let manufactureName = result.value(forKey: "manufactureName") as! String

                    let deviceBarcodeModel = DeviceBarcodeModel(currentBarcode: currentBarcode, currentItemTitle: currentItemTitle, itemQuantity: itemQuantity, manufactureName: manufactureName)

                    pickedItems.append(deviceBarcodeModel)
                    pickListTableView.reloadData()
                    totalItemsPickedLabel.text = "BoxesPicked: \(pickedItems.count)"
                }
            }
        } catch let error as NSError {
            print("Error loading data: \(error.localizedDescription)")
        }
    }
   
    

   


    
    func refreshDeviceBarcodeTableView() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DevicebarcodeEntity")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try managedObjectContext.execute(batchDeleteRequest)
        } catch let error as NSError {
            print("Error deleting data: \(error.localizedDescription)")
        }
    }
    
//    func deleteItem(item: DeviceBarcodeModel){
//        managedObjectContext.delete(item)
//        do {
//            try managedObjectContext.save()
//        } catch {
//            print("Error")
//        }
//    }
 }
    
    
    
   
   
   
    
  
    
    

//Mark: - TableView Delegate and DateSource


extension DeviceBarcodeListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return "Device List For: \(updateDateLabel())"
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.black
        if let headerView = view as? UITableViewHeaderFooterView {
                headerView.textLabel?.textColor = .white
            }
        
     
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pickedItems.count
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       cell.contentView.backgroundColor = UIColor.clear
        cell.backgroundColor = UIColor.clear
        //cell.layer.cornerRadius = 10
       //  cell.separatorInset = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 20)
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: pickedItemCell, for: indexPath) as! pickedItemTableViewCell
        
        cell.pickedItemTitleLabel.text = "Item Picked: \(pickedItems[indexPath.row].currentItemTitle)"
        cell.currentBarcodeLabel.text =  "Barcode: \(pickedItems[indexPath.row].currentBarcode )"
        cell.amountOfItemPickedLabel.text = "Total Picked: \(pickedItems[indexPath.row].itemQuantity)"
        cell.deviceBrandLabel.text =    "Manufacture: \(pickedItems[indexPath.row].manufactureName)"
       
        //cell.addShadow()
       
        return cell
    }
    
     
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            
            var itemToEdit = self.pickedItems[indexPath.row]
            
            
            let appearance = SCLAlertView.SCLAppearance(
              kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
              kTextFont: UIFont(name: "HelveticaNeue", size: 8)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 16)!,
                showCloseButton: false
           )
            

            let alert = SCLAlertView(appearance: appearance)
           // let alertViewIcon = UIImage(named: "barcode")

            // Create the subview
            let subview = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 150))
            let x = (subview.frame.width - 240) / 2

            let label1 = UILabel(frame: CGRect(x: x, y: 10, width: 90, height: 25))
            label1.text = "Medication:"
            label1.textAlignment = .left
            label1.font = UIFont(name: "Thonburi-Bold", size: 10)
            subview.addSubview(label1)

            let textfield1 = UITextField(frame: CGRect(x: x + 90, y: 10, width: 90, height: 25))
            if textfield1.frame.size.width > 0 && textfield1.frame.size.height > 0 {
                textfield1.layer.borderColor = UIColor.systemYellow.cgColor
                textfield1.layer.borderWidth = 1.5
                textfield1.layer.cornerRadius = 5
            }
            textfield1.placeholder = "Cefepime"
            textfield1.textAlignment = .center
            subview.addSubview(textfield1)

            let label2 = UILabel(frame: CGRect(x: x, y: textfield1.frame.maxY + 10, width: 80, height: 25))
            label2.text = "Amount Picked:"
            label2.textAlignment = .left
            label2.font = UIFont(name: "Thonburi-Bold", size: 10)
            subview.addSubview(label2)

            let textfield2 = UITextField(frame: CGRect(x: x + 90, y: textfield1.frame.maxY + 10, width: 90, height: 25))
            if textfield2.frame.size.width > 0 && textfield2.frame.size.height > 0 {
                textfield2.layer.borderColor = UIColor.systemYellow.cgColor
                textfield2.layer.borderWidth = 1.5
                textfield2.layer.cornerRadius = 5
            }
            textfield2.placeholder = "15"
            textfield2.textAlignment = .center
            subview.addSubview(textfield2)

            let label3 = UILabel(frame: CGRect(x: x, y: textfield2.frame.maxY + 10, width: 80, height: 25))
            label3.text = "Brand:"
            label3.textAlignment = .left
            label3.font = UIFont(name: "Thonburi-Bold", size: 10)
            subview.addSubview(label3)

            let textfield3 = UITextField(frame: CGRect(x: x + 90, y: textfield2.frame.maxY + 10, width: 90, height: 25))
            if textfield3.frame.size.width > 0 && textfield3.frame.size.height > 0 {
                textfield3.layer.borderColor = UIColor.systemYellow.cgColor
                textfield3.layer.borderWidth = 1.5
                textfield3.layer.cornerRadius = 5
            }
            textfield3.placeholder = "BD"
            textfield3.textAlignment = .center
            subview.addSubview(textfield3)

            // Add the subview to the alert's UI property
            
            
            
            
            
            
            
          
            alert.customSubview = subview
            alert.addButton("OK", backgroundColor: UIColor.systemYellow, textColor: UIColor.black) {
                
                   
                
                
                let newDeviceName = textfield1.text!
                let amountPicked = textfield2.text!
                let deviceBrand = textfield3.text!
                let barcodeData = " "
                let amountPicked2 = Int(amountPicked)
                
                
                
                
                if newDeviceName.isEmpty || amountPicked.isEmpty || deviceBrand.isEmpty {
                    let errorAlert = SCLAlertView()
                    errorAlert.showError("ERROR", subTitle: "Test")
                    return
                }
                print(newDeviceName)
                print(amountPicked)
                print(deviceBrand)
                
                itemToEdit.currentItemTitle = newDeviceName
                itemToEdit.manufactureName = deviceBrand
                itemToEdit.itemQuantity = amountPicked2!
                itemToEdit.currentBarcode = barcodeData
           
               // itemToEdit = DeviceBarcodeModel(currentBarcode: barcodeData, currentItemTitle: newDeviceName, itemQuantity: amountPicked2 ?? 0, manufactureName: deviceBrand)
                if let index = self.pickedItems.firstIndex(where: { $0.currentBarcode == itemToEdit.currentBarcode }) {
                    // If the item already exists, update it in the array
                    self.pickedItems[index] = itemToEdit
                    let editedIndexPath = IndexPath(row: index, section: 0)
                    self.pickListTableView.reloadRows(at: [editedIndexPath], with: .automatic)
                } else {
                    // If the item doesn't exist, add it to the array
                  
                    let newIndexPath = IndexPath(row: self.pickedItems.count - 1, section: 0)
                    self.pickListTableView.insertRows(at: [newIndexPath], with: .automatic)
                }

                // Update the label showing the number of items in the array
                self.totalItemsPickedLabel.text = "Boxes Picked: \(self.pickedItems.count)"

                self.deleteDeviceBarcodeObject(itemToEdit)
                self.saveData(deviceBarcodeModel: itemToEdit)
                // Save changes to the managed object context
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print("Error saving managed object context: \(error)")
                }
                // Reload the edited row
                let editedIndexPath = IndexPath(row: indexPath.row, section: 0)
                self.pickListTableView.reloadRows(at: [editedIndexPath], with: .automatic)
              
                
            }
            
      
            
            
            

            // Add Button with Duration Status and custom Colors
            alert.addButton("Cancel", backgroundColor: UIColor.systemYellow, textColor: UIColor.black) {
                //print("Duration Button tapped")
            }

            alert.showInfo("Edit Entry", subTitle: "Change the details from top to bottom")
      
            
            
            
            
            
            
            
            
      
        
         
            
            
        }
        editAction.backgroundColor = .systemGreen

        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { [self] (rowAction, indexPath) in
            let itemToDelete = pickedItems[indexPath.row]
                       
                       // Delete the object with the given currentBarcode value
            deleteDeviceBarcodeObject(itemToDelete)
                       
                       // Remove the item from the array and update the table view
                       pickedItems.remove(at: indexPath.row)
                       tableView.deleteRows(at: [indexPath], with: .fade)
                       totalItemsPickedLabel.text = "Boxes Picked: \(pickedItems.count)"
                       pickListTableView.reloadData()
            
            
        }
        deleteAction.backgroundColor = .red

        return [editAction,deleteAction]
    }
    
    func deleteDeviceBarcodeObject(_ deviceBarcodeModel: DeviceBarcodeModel) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DevicebarcodeEntity")
        fetchRequest.predicate = NSPredicate(format: "currentBarcode == %@", deviceBarcodeModel.currentBarcode)
        fetchRequest.fetchLimit = 1

        do {
            let objects = try managedObjectContext.fetch(fetchRequest)
            for object in objects {
                managedObjectContext.delete(object as! NSManagedObject)
            }

            try managedObjectContext.save()
            print("DeviceBarcodeModel with currentBarcode: \(deviceBarcodeModel.currentBarcode) has been deleted")
        } catch let error as NSError {
            print("Error deleting data: \(error.localizedDescription)")
        }
    }
   
   
    
    
    
    
    
}
//Mark: -  ScannerViewController Delegate
           
         
extension DeviceBarcodeListViewController: ScannerViewControllerDelegate {
    func didScanBarcode(_ barcode: String) {
        
        
        deviceBarcodeManager.fetchBarcode(barcode: barcode)
        
    
        
        
        
        
    }
    
    
    
    
    
    
    
    
}

//Mark: - DeviceBarcodeManagerDelegate
        
           
extension DeviceBarcodeListViewController: DeviceBarcodeManagerDelegate {
    
    
    func addCustomEntry(itemToEdit: DeviceBarcodeModel? = nil ) {
        
        
        let appearance = SCLAlertView.SCLAppearance(
          kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
          kTextFont: UIFont(name: "HelveticaNeue", size: 8)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 16)!,
            showCloseButton: false
       )
        

        let alert = SCLAlertView(appearance: appearance)
       // let alertViewIcon = UIImage(named: "barcode")

        // Create the subview
        let subview = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 150))
        let x = (subview.frame.width - 240) / 2

        let label1 = UILabel(frame: CGRect(x: x, y: 10, width: 90, height: 25))
        label1.text = "Medication:"
        label1.textAlignment = .left
        label1.font = UIFont(name: "Thonburi-Bold", size: 10)
        subview.addSubview(label1)

        let textfield1 = UITextField(frame: CGRect(x: x + 90, y: 10, width: 90, height: 25))
        if textfield1.frame.size.width > 0 && textfield1.frame.size.height > 0 {
            textfield1.layer.borderColor = UIColor.systemYellow.cgColor
            textfield1.layer.borderWidth = 1.5
            textfield1.layer.cornerRadius = 5
        }
        textfield1.placeholder = "Cefepime"
        textfield1.textAlignment = .center
        subview.addSubview(textfield1)

        let label2 = UILabel(frame: CGRect(x: x, y: textfield1.frame.maxY + 10, width: 80, height: 25))
        label2.text = "Amount Picked:"
        label2.textAlignment = .left
        label2.font = UIFont(name: "Thonburi-Bold", size: 10)
        subview.addSubview(label2)

        let textfield2 = UITextField(frame: CGRect(x: x + 90, y: textfield1.frame.maxY + 10, width: 90, height: 25))
        if textfield2.frame.size.width > 0 && textfield2.frame.size.height > 0 {
            textfield2.layer.borderColor = UIColor.systemYellow.cgColor
            textfield2.layer.borderWidth = 1.5
            textfield2.layer.cornerRadius = 5
        }
        textfield2.placeholder = "15"
        textfield2.textAlignment = .center
        subview.addSubview(textfield2)

        let label3 = UILabel(frame: CGRect(x: x, y: textfield2.frame.maxY + 10, width: 80, height: 25))
        label3.text = "Brand:"
        label3.textAlignment = .left
        label3.font = UIFont(name: "Thonburi-Bold", size: 10)
        subview.addSubview(label3)

        let textfield3 = UITextField(frame: CGRect(x: x + 90, y: textfield2.frame.maxY + 10, width: 90, height: 25))
        if textfield3.frame.size.width > 0 && textfield3.frame.size.height > 0 {
            textfield3.layer.borderColor = UIColor.systemYellow.cgColor
            textfield3.layer.borderWidth = 1.5
            textfield3.layer.cornerRadius = 5
        }
        textfield3.placeholder = "BD"
        textfield3.textAlignment = .center
        subview.addSubview(textfield3)
      

        // Add the subview to the alert's UI property
        
        
        
        
        
        
        
      
        alert.customSubview = subview
        alert.addButton("OK", backgroundColor: UIColor.systemYellow, textColor: UIColor.black) {
            
               
            
            
            let newDeviceName = textfield1.text!
            let amountPicked = textfield2.text!
            let deviceBrand = textfield3.text!
            let barcodeData = " "
            let amountPicked2 = Int(amountPicked)
            
            if newDeviceName.isEmpty || amountPicked.isEmpty || deviceBrand.isEmpty {
                let errorAlert = SCLAlertView()
                errorAlert.showError("ERROR", subTitle: "Text Fields Can't Be Empty‼️")
                return
            }
            print(newDeviceName)
            print(amountPicked)
            print(deviceBrand)
       
            let newItem = DeviceBarcodeModel(currentBarcode: barcodeData, currentItemTitle: newDeviceName, itemQuantity: amountPicked2 ?? 0, manufactureName: deviceBrand)
            print(newItem)
        
            self.pickedItems.append(newItem)
            self.pickListTableView.reloadData()
            self.saveData(deviceBarcodeModel: newItem)
            self.totalItemsPickedLabel.text = "Boxes Picked: \(self.pickedItems.count)"
            self.scrollToBottom()
            
        }
        
  
        
        
        

        // Add Button with Duration Status and custom Colors
        alert.addButton("Cancel", backgroundColor: UIColor.systemYellow, textColor: UIColor.black) {
            //print("Duration Button tapped")
        }

        alert.showInfo("Devin", subTitle: "Hey, Hows the weather")
    }
        
        
    
    func scrollToBottom(){
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.pickedItems.count-1, section: 0)
            self.pickListTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
   

    
  
    func didUpdateDeviceBarcodeData(barcode: DeviceBarcodeModel) {
        let itemName = barcode.currentItemTitle
        let itemQuantity = barcode.itemQuantity
        let itemBrand = barcode.manufactureName
        let itemBarcode = barcode.currentBarcode
        print(itemName)
        print(itemQuantity)
        print(itemBrand)
        print(itemBarcode)
        

        let newItem = DeviceBarcodeModel(currentBarcode: itemBarcode, currentItemTitle: itemName, itemQuantity: itemQuantity, manufactureName: itemBrand)
        print(newItem)
        
        DispatchQueue.main.async { [self] in
            pickedItems.append(newItem)
            saveData(deviceBarcodeModel: newItem)
            pickListTableView.reloadData()
            scrollToBottom()
           
            totalItemsPickedLabel.text = "Boxes Picked: \(pickedItems.count)"
         
           
        }
      
      

 
    }
   
    
  
    
    
    
    
}
    
   
    
    
    
//Mark: - UIView Methods
extension UIView {
    
    func addShadow() {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 4.0
    }
}



