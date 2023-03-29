//
//  pickedItemTableViewCell.swift
//  PickiTTicket
//
//  Created by Devin King on 1/14/23.
//

import UIKit

class pickedItemTableViewCell: UITableViewCell {

    @IBOutlet weak var pickedItemCellView: UIView!
    
    
    @IBOutlet weak var pickedItemTitleLabel: UILabel!
    
    @IBOutlet weak var currentBarcodeLabel: UILabel!

    
    @IBOutlet weak var amountOfItemPickedLabel: UILabel!
    
    @IBOutlet weak var deviceBrandLabel: UILabel!
    var setUpShadowDone: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
  
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        contentView.layer.cornerRadius = 20
        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 3, right: 0)
        contentView.frame = contentView.frame.inset(by: margins)
        let maskLayer = CALayer()
        maskLayer.cornerRadius = 30   //if you want round edges
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.borderColor = UIColor.black.cgColor
        maskLayer.borderWidth = 5
        self.layer.borderColor = UIColor.black.cgColor // no change
        self.layer.borderWidth = 5 // no change
        maskLayer.frame = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.width, height: self.bounds.height).insetBy(dx: 2/2, dy: 2/2)
     
        //elf.layer.shadowOffset = CGSize(width: 0, height: 3)
        
    }
   public func setUpShadow() {
       
            print("setup Shadow!")
            self.layer.cornerRadius = 8
            self.layer.shadowOffset = CGSize(width: 0, height: 3)
                    self.layer.shadowRadius = 3
                    self.layer.shadowOpacity = 0.3
                    self.layer.shadowColor = UIColor.black.cgColor
                    self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds,
            byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 8, height:
            8)).cgPath
                    self.layer.shouldRasterize = true
                    self.layer.rasterizationScale = UIScreen.main.scale
                
                   
                
    }
    
}
