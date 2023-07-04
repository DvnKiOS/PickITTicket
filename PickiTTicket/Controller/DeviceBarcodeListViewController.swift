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

class DeviceBarcodeListViewController: UIViewController, UISearchControllerDelegate{
   
    
    var pickedItems:  [DeviceBarcodeModel] = []  
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
    
   // let barcodeSearchController = UISearchController()
  
   
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let navigationController = navigationController {
            navigationController.overrideUserInterfaceStyle = .light
            navigationController.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            navigationController.navigationBar.prefersLargeTitles = true
            
        }

       
        
        scanButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        

        loadData()
        

        
     
        //navigationItem.searchController = barcodeSearchController
   
      
        
        pickListTableView.dataSource = self
        pickListTableView.delegate = self
        
        pickListTableView.isUserInteractionEnabled = true
        pickListTableView.allowsSelection = false
       
        
        //        tableView.emptyDataSetView { [weak self] view in
        //            guard let `self` = self else { return }
        //            view.customView(CustomView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)))
        //                .verticalOffset(50)
        //                .buttonImage(nil, for: .disabled)
        //        }
        func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
               return NSAttributedString(string: "hahaha")
           }
      
        
          
        scannerViewController.delegate = self
        
        pickListTableView.register(UINib(nibName: "pickedItemTableViewCell", bundle: nil), forCellReuseIdentifier: pickedItemCell) // ->  Dont forget to register the nibs we have created to make to free to use on our currentTableView.
        pickListTableView.layer.cornerRadius = 10.0
        
        deviceBarcodeManager.delegate = self
      //  barcodeSearchController.delegate = self
        
        sendListButton.addShadow()
        sendListButton.layer.cornerRadius = 10.0
        
        scanButton.addShadow()
        scanButton.layer.cornerRadius = 10.0
        
        //        pickListTableView.addShadow() BUG CODE: Causes the tableview to expand beyond the its current bounds. REMEMBER: We can use our custom add shadow method on our tableView with our current implementation without causing bugs.
        pickListTableView.layer.cornerRadius = 10.0
        
        
        totalItemsPickedLabel.text = (" Items Picked: \(pickedItems.count)")
        
        
      animateNavigationTitle(titleText: "Device List")
        
       
    
    }
    func animateNavigationTitle(titleText: String) {
        var charIndex = 0.0
        navigationItem.title = ""
        for letter in titleText {
            Timer.scheduledTimer(withTimeInterval: 0.1 * charIndex, repeats: false) { (timer) in
                self.navigationItem.title = self.navigationItem.title! + String(letter)
            }
            charIndex += 1
        }
    }
    func customView(forEmptyDataSet scrollView: UIScrollView) -> UIView? {
        let view = UIView (frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        return view
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

    
   
    
    
  

    
    @IBAction func sendPickListButton(_ sender: UIButton) {
        
        if pickedItems.isEmpty {
            let emptyAlert = SCLAlertView()
            emptyAlert.showCustom("Test", subTitle: "testing one of these alerts", color: .black , icon: UIImage(named: "barcode")!)
            return
        }
        let filename = "Device List: \(updateDateLabel()).csv"
        let path = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        
        var csvText = "Device Name   ,Manufacture   ,Total Picked   ,Barcode   \n"
        for item in pickedItems {
            csvText += "\(item.currentItemTitle)  ,\(item.manufactureName)  ,\(item.itemQuantity)  ,\(item.currentBarcode)  \n"
        }
        
        do {
            try csvText.write(to: path!, atomically: true, encoding: .utf16)
            let activityViewController = UIActivityViewController(activityItems: [path!], applicationActivities: nil)
            activityViewController.completionWithItemsHandler = { [weak self] activityType, completed, _, error in
                if let error = error {
                    print("Activity failed: \(error.localizedDescription)")
                    return
                }
                
                if completed {
                    DispatchQueue.main.async {
                        self?.refreshDeviceBarcodeTableView()
                        self?.pickedItems = []
                        self?.pickListTableView.reloadData()
                        self?.totalItemsPickedLabel.text = "Boxes Picked: \(self?.pickedItems.count ?? 0)"
                    }
                } else {
                    let cancelAlert = SCLAlertView()
                    cancelAlert.showCustom("Cancelled", subTitle: "Your list was not sent", color: .systemYellow, icon: UIImage(named: "syringe")!)

                }
            }
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                // Use a popover presentation on iPad
                activityViewController.modalPresentationStyle = .popover
                activityViewController.popoverPresentationController?.sourceView =  sender
                activityViewController.popoverPresentationController?.permittedArrowDirections = .down
            } else {
                // Use a modal presentation on iPhone
                activityViewController.modalPresentationStyle = .fullScreen
            }
            
            present(activityViewController, animated: true, completion: nil)
            
        } catch {
            print("Failed to write file")
            // ADD ERROR MESSAGE THAT THE USER IS ABLE TO SEE WITHIN OUR APPLICATION
        }
    }

    
    
    @IBAction func addCustomPickItem(_ sender: UIBarButtonItem) {
        addCustomEntry()
       
        
        
        
    }
   
   
    
    
    func updateDateLabel() -> String {
        let today = Date.now
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "MMM, yyyy"
        let formattedDate = formatter.string(from: today)
        return formattedDate
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
                    totalItemsPickedLabel.text = "Items Picked: \(pickedItems.count)"
                }
            }
        } catch let error as NSError {
            print("Error loading data: \(error.localizedDescription)")
            //add error message that be seen within the application.
        }
    }
   
    

   


    
    func refreshDeviceBarcodeTableView() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DevicebarcodeEntity")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try managedObjectContext.execute(batchDeleteRequest)
        } catch let error as NSError {
            
            //add error message that be be seen inside our application
            print("Error deleting data: \(error.localizedDescription)")
        }
    }
    
   
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
        if pickedItems.count == 0 {
            pickListTableView.setEmptyView(title: "Empty List", message: "Scan or add an item manually with the + button in the top right corrner ")
        } else {
            pickListTableView.restore()
        }
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
            
           
            let itemToEdit = self.pickedItems[indexPath.row]
            
            
            let appearance = SCLAlertView.SCLAppearance(
              kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
              kTextFont: UIFont(name: "HelveticaNeue", size: 8)!,
                kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 16)!,
                showCloseButton: false
           )
            

            let alert = SCLAlertView(appearance: appearance)
          
            
            // Create the subview
            let subview = UIView(frame: CGRect(x: 0, y: 0, width: 250, height: 150))
            let x = (subview.frame.width - 240) / 2

            let label1 = UILabel(frame: CGRect(x: x, y: 10, width: 90, height: 25))
            label1.text = "Device Name:"
            label1.textAlignment = .left
            label1.font = UIFont(name: "Thonburi-Bold", size: 10)
            subview.addSubview(label1)

            let textfield1 = UITextField(frame: CGRect(x: x + 90, y: 10, width: 90, height: 25))
            if textfield1.frame.size.width > 0 && textfield1.frame.size.height > 0 {
                textfield1.layer.borderColor = UIColor.systemYellow.cgColor
                textfield1.layer.borderWidth = 1.5
                textfield1.layer.cornerRadius = 5
            }
            textfield1.placeholder = "60ML Syringe"
            textfield1.textAlignment = .center
            subview.addSubview(textfield1)

            let label2 = UILabel(frame: CGRect(x: x, y: textfield1.frame.maxY + 10, width: 80, height: 25))
            label2.text = "Amount Picked:"
            label2.textAlignment = .left
            label2.font = UIFont(name: "Thonburi-Bold", size: 8)
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
            label3.font = UIFont(name: "Thonburi-Bold", size: 8)
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
                    errorAlert.showError("Error", subTitle: "Sorry, you can't leave any text fields empty. Please fill them out and try again.")
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
                  
                    let newIndexPath = IndexPath(row: self.pickedItems.count, section: 0)
                    self.pickListTableView.insertRows(at: [newIndexPath], with: .automatic)
                }

                // Update the label showing the number of items in the array
                self.totalItemsPickedLabel.text = "Items Picked: \(self.pickedItems.count)"

                self.deleteDeviceBarcodeObject(itemToEdit)
                self.saveData(deviceBarcodeModel: itemToEdit)
                // Save changes to the managed object context
              
                // Reload the edited row
          
                self.pickListTableView.reloadRows(at: [indexPath], with: .automatic)
                
                
                
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
          kTitleFont: UIFont(name: "HelveticaNeue", size: 15)!,
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
        label1.text = "Device Name:"
        label1.textAlignment = .left
        label1.font = UIFont(name: "Thonburi-Bold", size: 10)
        label1.textColor = .black
        subview.addSubview(label1)

        let textfield1 = UITextField(frame: CGRect(x: x + 90, y: 10, width: 90, height: 25))
        if textfield1.frame.size.width > 0 && textfield1.frame.size.height > 0 {
            textfield1.layer.borderColor = UIColor.systemYellow.cgColor
            textfield1.layer.borderWidth = 1.5
            textfield1.layer.cornerRadius = 5
            textfield1.textColor = .black
        }
        textfield1.placeholder = "60ML Syringe"
        textfield1.textAlignment = .center
        textfield1.textColor = .black
        subview.addSubview(textfield1)

        let label2 = UILabel(frame: CGRect(x: x, y: textfield1.frame.maxY + 10, width: 80, height: 25))
        label2.text = "Amount Picked:"
        label2.textAlignment = .left
        label2.font = UIFont(name: "Thonburi-Bold", size: 10)
        label2.textColor = .black
        subview.addSubview(label2)

        let textfield2 = UITextField(frame: CGRect(x: x + 90, y: textfield1.frame.maxY + 10, width: 90, height: 25))
        if textfield2.frame.size.width > 0 && textfield2.frame.size.height > 0 {
            textfield2.layer.borderColor = UIColor.systemYellow.cgColor
            textfield2.layer.borderWidth = 1.5
            textfield2.layer.cornerRadius = 5
            textfield2.textColor = .black
        }
        textfield2.placeholder = "15"
        textfield2.textAlignment = .center
        subview.addSubview(textfield2)

        let label3 = UILabel(frame: CGRect(x: x, y: textfield2.frame.maxY + 10, width: 80, height: 25))
        label3.text = "Brand:"
        label3.textAlignment = .left
        label3.font = UIFont(name: "Thonburi-Bold", size: 10)
        label3.textColor = .black
        subview.addSubview(label3)

        let textfield3 = UITextField(frame: CGRect(x: x + 90, y: textfield2.frame.maxY + 10, width: 90, height: 25))
        if textfield3.frame.size.width > 0 && textfield3.frame.size.height > 0 {
            textfield3.layer.borderColor = UIColor.systemYellow.cgColor
            textfield3.layer.borderWidth = 1.5
            textfield3.layer.cornerRadius = 5
            textfield3.textColor = .black
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
                errorAlert.showError( "Error", subTitle: "Text fields cannot be be empty.")

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
            
            
            //We need to implement the functionality to save our user Defaults information once the user had edited one of their entries
            
            
        }
        
  
        
        
        

        // Add Button with Duration Status and custom Colors
        alert.addButton("Cancel", backgroundColor: UIColor.systemYellow, textColor: UIColor.black) {
            //print("Duration Button tapped")
        }

        alert.showInfo("Custom Entry" , subTitle: "Add device details below")
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

        // Check if the item already exists in the array
        if let existingItemIndex = pickedItems.firstIndex(where: { $0.currentBarcode == itemBarcode }) {
            // Item exists, update the quantity
            pickedItems[existingItemIndex].itemQuantity += itemQuantity
        } else {
            // Item does not exist, create a new entry
            let newItem = DeviceBarcodeModel(currentBarcode: itemBarcode, currentItemTitle: itemName, itemQuantity: itemQuantity, manufactureName: itemBrand)
            pickedItems.append(newItem)
            saveData(deviceBarcodeModel: newItem)
        }

        DispatchQueue.main.async { [self] in
            pickListTableView.reloadData()
            scrollToBottom()
            totalItemsPickedLabel.text = "Items Picked: \(pickedItems.count)"
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


extension UITableView {
func setEmptyView(title: String, message: String) {
let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
let titleLabel = UILabel()
let messageLabel = UILabel()
titleLabel.translatesAutoresizingMaskIntoConstraints = false
messageLabel.translatesAutoresizingMaskIntoConstraints = false
titleLabel.textColor = UIColor.black
titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
messageLabel.textColor = UIColor.lightGray
messageLabel.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
emptyView.addSubview(titleLabel)
emptyView.addSubview(messageLabel)
titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
titleLabel.text = title
messageLabel.text = message
messageLabel.numberOfLines = 0
messageLabel.textAlignment = .center
// The only tricky part is here:
self.backgroundView = emptyView
self.separatorStyle = .none
}
func restore() {
self.backgroundView = nil
self.separatorStyle = .singleLine
}
}
