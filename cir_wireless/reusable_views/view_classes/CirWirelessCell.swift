//
//  CirWirelessCell.swift
//  cir_wireless
//
//  Created by softel on 11/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit

class CirWirelessCell: UITableViewCell {
    // Outlets
    @IBOutlet weak var cirWirelessMac: UILabel!
    
    
    var cirModel: CirWirelessModel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
