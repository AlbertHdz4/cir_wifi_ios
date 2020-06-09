//
//  PopUpMessage.swift
//  cir_wireless
//
//  Created by softel on 09/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import Foundation
import UIKit

class PopUpAlert {
    var title: String?
    var message: String?
    var alertStyle: UIAlertController.Style?
    
    
    init (dialogCharacteristics alertCharacteristics: AlertComponents) {
        self.title = alertCharacteristics.alertTitle
        self.message = alertCharacteristics.alertMessage
        self.alertStyle = alertCharacteristics.alertStyle
    }
    
    
    func popUpOneButton (buttonCharacteristic alertActionComponents: AlertActionComponents) ->  UIAlertController {
        
        let alert = UIAlertController(title: self.title,
                                      message: self.message,
                                      preferredStyle: self.alertStyle!)
        
        alert.addAction(UIAlertAction(title: alertActionComponents.buttonTitle!,
                                      style: alertActionComponents.buttonStyle!,
                                      handler: alertActionComponents.buttonHandler!))

        return alert
    }
    
    
    func popUpTwoButtons (buttonCharacteristic alertActionComponents: [AlertActionComponents]) throws ->  UIAlertController {
        if alertActionComponents.count != 2 {
            throw AlertError.twoButtonLessParameters
        }
        
        let alert = UIAlertController(title: self.title,
                                      message: self.message,
                                      preferredStyle: self.alertStyle!)

        for component in alertActionComponents {
            alert.addAction(UIAlertAction(title: component.buttonTitle!,
                                          style: component.buttonStyle!,
                                          handler: component.buttonHandler!))
        }
        
        return alert
    }
    
    
    func popUpThreeButtons (buttonCharacteristic alertActionComponents: [AlertActionComponents]) throws ->  UIAlertController {
        if alertActionComponents.count != 3 {
            throw AlertError.threeButtonsLessParameters
        }
        
        let alert = UIAlertController(title: self.title,
                                      message: self.message,
                                      preferredStyle: self.alertStyle!)

        for component in alertActionComponents {
            alert.addAction(UIAlertAction(title: component.buttonTitle!,
                                          style: component.buttonStyle!,
                                          handler: component.buttonHandler!))
        }
        
        return alert
    }
}


// Alert's components
struct AlertComponents {
    var alertTitle: String?
    var alertMessage: String?
    var alertStyle: UIAlertController.Style?
    
    
    init (alertTitle: String, alertMessage: String, alertStyle: UIAlertController.Style = .alert) {
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        self.alertStyle = alertStyle
    }
    
}


// Button's components
struct AlertActionComponents {
    var buttonTitle: String?
    var buttonStyle: UIAlertAction.Style?
    var buttonHandler: ((UIAlertAction) -> Void)?
    
    
    init (buttonTitle: String, buttonStyle: UIAlertAction.Style = .default, buttonHandler: ((UIAlertAction) -> Void)?) {
        self.buttonTitle = buttonTitle
        self.buttonStyle = buttonStyle
        self.buttonHandler = buttonHandler
    }
}


// Possible errors with alert
enum AlertError: Error {
    case alertParametersNil
    
    case oneButtonLessParameters
    
    case twoButtonLessParameters
    
    case threeButtonsLessParameters
}
