//
//  CustomTableViewCell.swift
//  IOS_Dev
//
//  Created by Sara Krg on 18/5/21.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

   
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var holdingsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

