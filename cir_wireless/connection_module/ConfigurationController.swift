//
//  ConfigurationController.swift
//  cir_wireless
//
//  Created by softel on 15/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit
import CoreBluetooth


class ConfigurationController: UIViewController {
    
    let SEGMENTED_CONTROL_VALUES = [NSLocalizedString("Lock Label", comment: "First value of segmented control"),
                                    NSLocalizedString("Configuration Label", comment: "Second value of segmented control")]
    
    
    var isCirConnected = false
    var isBluetoothOn = false
    
    
    var cirWireless: CirWirelessModel?
    var bluetoothActions: CoreBluetoothActions?
    
    
    var connectingAlert: UIAlertController?
    
    
    // Outlets
    @IBOutlet weak var connectionStatus: UILabel!
    @IBOutlet weak var cirWirelessMac: UILabel!
    @IBOutlet weak var configurationSelector: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: Algunos cambios necesarios antes de iniciar
        loadViews()
        
        if let _ = cirWireless, let _ = bluetoothActions {
            
            popUpConnectingCir()
            bluetoothActions?.bluetoothConnectionDelegate = self
            bluetoothActions?.connectCirWireless(peripheralToConnect: cirWireless!.peripheral!)
            
        } else {
            popUpErrorCirConnection()
        }
    }
    
    
    private func loadViews() {
        configurationSelector.setTitle(SEGMENTED_CONTROL_VALUES[0], forSegmentAt: 0)
        configurationSelector.setTitle(SEGMENTED_CONTROL_VALUES[1], forSegmentAt: 1)
    }
    
    
    private func goBackToRootController () {
        bluetoothActions?.disconnectCirWireless()
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    // MARK: Outlet actions
    @IBAction func selectedSegment(_ sender: Any) {
        if configurationSelector.selectedSegmentIndex == 0 {
            print("Lock is selected")
        } else {
            print("Configuration is selected")
        }
    }
    // Outlet actions (End)
    
    
    // MARK: Pop up area :D
    private func popUpErrorCirConnection () {
        var errorCirAlert: UIAlertController?
    
        let errorCirAlertTitle = NSLocalizedString("Connection Error Title", comment: "In case the passed parameter were null")
        let errorCirAlertMessage = NSLocalizedString("Connection Error Message", comment: "Message")
        let errorCirAlertComponents = AlertComponents(alertTitle: errorCirAlertTitle, alertMessage: errorCirAlertMessage)
        let errorCirAlertAction = AlertActionComponents(buttonTitle: "Accept", buttonHandler: { _ in
            errorCirAlert?.dismiss(animated: true, completion: nil)
            self.goBackToRootController()
        })
        
        errorCirAlert = PopUpAlert.popUpOneButton(alertCharacteristic: errorCirAlertComponents, buttonCharacteristic: errorCirAlertAction)
        
        self.present(errorCirAlert!, animated: true, completion: nil)
        
    }
    
    
    private func popUpConnectingCir () {
    
        let connectingAlertTitle = NSLocalizedString("Connecting Device Title", comment: "Connectig with CIR Wireless")
        let connectingAlertMessage = NSLocalizedString("Please Wait", comment: "Message")
        let connectingAlertComponents = AlertComponents(alertTitle: connectingAlertTitle, alertMessage: connectingAlertMessage)
        let connectingAlertAction = AlertActionComponents(buttonTitle: "Cancel", buttonHandler: { _ in
            self.connectingAlert?.dismiss(animated: true, completion: nil)
            self.goBackToRootController()
        })
        
        connectingAlert = PopUpAlert.popUpOneButton(alertCharacteristic: connectingAlertComponents, buttonCharacteristic: connectingAlertAction)
        
        self.present(connectingAlert!, animated: true, completion: nil)
    }
    
    
    private func popUpCirConnected () { print("Cir connected") }
    // Pop up area (End)
}


extension ConfigurationController: BluetoothConnectionProtocol {
    func servicesAvailable(services: [CBService]?) {
        print(services)
        
        connectionStatus.text = NSLocalizedString("Device Connected", comment: "Device is now connected")
        cirWirelessMac.text = self.cirWireless?.getCirWirelessMac()
        connectingAlert?.dismiss(animated: true, completion: nil)
    }
    
    
    func updateBluetoothConnectProcess(status: BluetoothConnectionProcess) {
        print(status)
        
        switch status {
        case .connecting:
            print("connecting")
            
            
        case .connected:
            bluetoothActions?.discoverCirWirelessServices(specificServices: nil)
            
            
        case .disconnecting:
            print("disconnecting")
            
            
        case .disconnected:
            print("disconnected")
            
            
        case .discoveringServicesAndCharacteristics:
            print("discoveringServices")
            
            
        case .connectionFailed:
            print("connectionFailed")
            
            
        case .servicesDiscovered:
            print("servicesDiscovered")
            
            
        case .noneServicesAvailable:
            print("noneServicesAvailable")
            popUpErrorCirConnection()
        }
    }
    
    
    func updateCentralState(newState: CBManagerState) {
        print("")
    }
    
    
    func errorConnectionOcurred(error: ErrorConnection) {
        print("")
    }
}
