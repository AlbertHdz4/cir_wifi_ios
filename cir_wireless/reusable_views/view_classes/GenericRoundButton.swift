//
//  GenericButton.swift
//  cir_wireless
//
//  Created by softel on 01/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit

class GenericRoundButton: UIButton {
    
   @IBDesignable
   class RoundButton: UIButton {

       @IBInspectable var cornerRadius: CGFloat = 0 {
           didSet {
           self.layer.cornerRadius = cornerRadius
           }
       }

       @IBInspectable var borderWidth: CGFloat = 0 {
           didSet {
               self.layer.borderWidth = borderWidth
           }
       }

       @IBInspectable var borderColor: UIColor = UIColor.clear {
           didSet {
               self.layer.borderColor = borderColor.cgColor
           }
       }
   }
}
