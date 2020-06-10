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

    
    private static func popUp (alertCharacteristic alertComponents: AlertComponents) -> UIAlertController {
        return UIAlertController(title: alertComponents.alertTitle,
                                      message: alertComponents.alertMessage,
                                      preferredStyle: alertComponents.alertStyle!)
    }
    
    
    static func popUpOneButton (alertCharacteristic alertComponents: AlertComponents, buttonCharacteristic alertActionComponents: AlertActionComponents) ->  UIAlertController {
        
        let alert = popUp(alertCharacteristic: alertComponents)
        
        alert.addAction(UIAlertAction(title: alertActionComponents.buttonTitle!,
                                      style: alertActionComponents.buttonStyle!,
                                      handler: alertActionComponents.buttonHandler!))

        return alert
    }
    
    
    static func popUpTwoButtons (alertCharacteristic alertComponents: AlertComponents,
                          buttonCharacteristic alertActionComponents: [AlertActionComponents]) throws ->  UIAlertController {
        if alertActionComponents.count != 2 {
            throw AlertError.twoButtonLessParameters
        }
        
        let alert = popUp(alertCharacteristic: alertComponents)

        for component in alertActionComponents {
            alert.addAction(UIAlertAction(title: component.buttonTitle!,
                                          style: component.buttonStyle!,
                                          handler: component.buttonHandler!))
        }
        
        return alert
    }
    
    
    static func popUpThreeButtons (alertCharacteristic alertComponents: AlertComponents,
                            buttonCharacteristic alertActionComponents: [AlertActionComponents]) throws ->  UIAlertController {
        if alertActionComponents.count != 3 {
            throw AlertError.threeButtonsLessParameters
        }
        
        let alert = popUp(alertCharacteristic: alertComponents)

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
