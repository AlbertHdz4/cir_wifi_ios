//
//  CirWirelessViewCell.swift
//  cir_wireless
//
//  Created by softel on 10/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit

class CirWirelessCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var cirWirelessMac: UILabel!
    
    
    // MARK: Cir Wireless asociada a esta celda
    var cirWirelessModel: CirWirelessModel?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
