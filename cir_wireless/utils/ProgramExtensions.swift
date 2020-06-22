//
//  ProgramExtensions.swift
//  cir_wireless
//
//  Created by softel on 11/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation
import UIKit

// Extensiones -------------------


// Aniade la conversion de bytes a string ---------
extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}
// ------------------------------------------------


// Aniade opciones de visibilidad a las vistas ---------
extension UIView {
    
    enum Visibility {
        case visible
        case invisible
        case gone
    }

    
    var visibility: Visibility {
        get {
            let constraint = (self.constraints.filter{$0.firstAttribute == .height && $0.constant == 0}.first)
            if let constraint = constraint, constraint.isActive {
                return .gone
            } else {
                return self.isHidden ? .invisible : .visible
            }
        }
        set {
            if self.visibility != newValue {
                self.setVisibility(newValue)
            }
        }
    }

    
    private func setVisibility(_ visibility: Visibility) {
        let constraint = (self.constraints.filter{$0.firstAttribute == .height && $0.constant == 0}.first)

        switch visibility {
        case .visible:
            constraint?.isActive = false
            self.isHidden = false
            break
        case .invisible:
            constraint?.isActive = false
            self.isHidden = true
            break
        case .gone:
            if let constraint = constraint {
                constraint.isActive = true
            } else {
                let constraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 0)
                self.addConstraint(constraint)
                constraint.isActive = true
            }
        }
    }
    

    func hideWithOppacity (duration: TimeInterval, delay: TimeInterval, completion: ((Bool) -> Void)?) {
            UIView.animate(withDuration: duration,
                           delay: delay,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: {
                            self.alpha = 0
                            
            },
                           completion: completion)
    }
    
    
    func showWithOppacity (duration: TimeInterval, delay: TimeInterval, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: duration,
                       delay: delay,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: {
                        self.alpha = 1
                        
        },
                       completion: completion)
    }
    
    
    func hideSliding (xPosition: CGFloat, yPosition: CGFloat, width: CGFloat, height: CGFloat, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: 0.5,
                           animations: {
                            self.frame = CGRect(x: xPosition - 1000, y: 0, width: width, height: height)
            },
                           completion: completion)
    }
    
    
    func showSliding (xPosition: CGFloat, yPosition: CGFloat, width: CGFloat, height: CGFloat, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: 0.5,
                           animations: {
                            self.frame = CGRect(x: xPosition + 1000, y: 0, width: width, height: height)
            },
                           completion: completion)
    }
}
// ------------------------------------------------


// Convierte una cadena en un arreglo de bytes --------------------------------------------
extension StringProtocol {
    var hexaToBytes: [UInt8] {
        let hexa = Array(self)
        return stride(from: 0, to: count, by: 2).compactMap { UInt8(String(hexa[$0...$0.advanced(by: 1)]), radix: 16) }
    }
}
// ----------------------------------------------------------------------------------------
