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
    
    let SEGMENTED_CONTROL_VALUES    = [NSLocalizedString("Lock Label", comment: "First value of segmented control"),
                                       NSLocalizedString("Configuration Label", comment: "Second value of segmented control")]
    
    
    var isCirConnected              = false
    var isBluetoothOn               = false
    
    
    var cirWireless                             : CirWirelessModel?
    var bluetoothActions                        : CoreBluetoothActions?
    
    
    // MARK: Servicios bluetooth de la cir wireless
    var cWInfoService                           : CBService?
    var cwProtocolService                       : CBService?
    var cWQuickCommandsService                  : CBService?
    
    
    // MARK: Caracteristicas bluetooth de la cir wireless
    var cwInfoCharacteristic                    : CBCharacteristic?
    var cwQuickCommandsCharacteristic           : CBCharacteristic?
    var cwNotificationCharacteristic            : CBCharacteristic?
    var cwWriteCharacteristic                   : CBCharacteristic?
    
    
    var connectingAlert                         : UIAlertController?
    
    
    // Outlets
    @IBOutlet weak var connectionStatus         : UILabel!
    @IBOutlet weak var cirWirelessMac           : UILabel!
    @IBOutlet weak var configurationSelector    : UISegmentedControl!
    @IBOutlet weak var containerLockBtns        : UIStackView!
    @IBOutlet weak var containerReloadBtn       : UIStackView!
    @IBOutlet weak var containerConfigBtns      : UIStackView!
    
    
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
    
    
    private func loadViews () {
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
            containerConfigBtns.hideWithOppacity(duration: 0.2, delay: 0.1, completion: {_ in
                self.containerConfigBtns.isHidden = true
                self.containerLockBtns.isHidden = false
                self.containerReloadBtn.isHidden = false
                self.containerLockBtns.showWithOppacity(duration: 0.2, delay: 0.1, completion: nil)
                self.containerReloadBtn.showWithOppacity(duration: 0.2, delay: 0.1, completion: nil)
                
            })
            
        } else {
        
            print("Configuration is selected")
            containerLockBtns.hideWithOppacity(duration: 0.2, delay: 0.1, completion: nil)
            containerReloadBtn.hideWithOppacity(duration: 0.2, delay: 0.1, completion: {_ in
                self.containerLockBtns.isHidden = true
                self.containerReloadBtn.isHidden = true
                self.containerConfigBtns.isHidden = false
                self.containerConfigBtns.showWithOppacity(duration: 0.2, delay: 0.1, completion: nil)
            })
            
        }
    }
    
    
    @IBAction func lockFridge (_ sender: Any) {
        
    }
    
    
    @IBAction func unlockFridge (_ sender: Any) {
        
    }
    
    
    @IBAction func realodFridge (_ sender: Any) {
        
    }
    
    
    @IBAction func configWiFiConnection (_ sender: Any) {
        
    }
    
    
    @IBAction func testWiFiConnection (_ sender: Any) {
        
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
        
        if let _ = services {
            // MARK: Se obtienen los servicios de la tarjeta CIR Wireless
            for service in services! {
                let serviceUuid = service.uuid.uuidString
                
                
                if serviceUuid == BluetoothGattConstants.CBUUID_DEVICE_INFO_SERVICE {
                    
                    self.cWInfoService = service
                   
                } else if serviceUuid == BluetoothGattConstants.CBUUID_QUICK_COMMANDS_SERVICE {
                   
                    self.cWQuickCommandsService = service
               
                } else if serviceUuid == BluetoothGattConstants.CBUUID_CIR_NAMA_SERVICE {
                   
                    self.cwProtocolService = service
                                  
                }
            }
            
            
            if let _ = self.cWInfoService {
                
                bluetoothActions?.discoverCirWirelessCharacteristics(serviceToBeExamined: cWInfoService!,
                                                                     specificCharacteristics: [CBUUID(string: BluetoothGattConstants.CBUUID_DEVICE_INFO_CHARACTERISTIC)])
            }
            
            if let _ = self.cWQuickCommandsService {
                
                bluetoothActions?.discoverCirWirelessCharacteristics(serviceToBeExamined: cWQuickCommandsService!,
                                                                     specificCharacteristics: [CBUUID(string: BluetoothGattConstants.CBUUID_QUICK_COMMANDS_CHARACTERISTIC)])
            }
            
            
            if let _ = self.cwProtocolService {
                
                bluetoothActions?.discoverCirWirelessCharacteristics(serviceToBeExamined: cwProtocolService!,
                                                                     specificCharacteristics: [CBUUID(string: BluetoothGattConstants.CBUUID_CIR_NAMA_WRITE_CHARACTERISTIC),
                                                                                               CBUUID(string: BluetoothGattConstants.CBUUID_CIR_NAMA_NOTIFY_CHARACTERISTIC)])
            }
        }
    }
    
    
    func characteristicsAvailable(service: CBService, availableCharacteristics characteristics: [CBCharacteristic]) {
        
        for characteristic in characteristics {
            let characteristicUuid = characteristic.uuid.uuidString
               
            if characteristicUuid == BluetoothGattConstants.CBUUID_CIR_NAMA_NOTIFY_CHARACTERISTIC {
                
                self.cwNotificationCharacteristic = characteristic
            
            } else if characteristicUuid == BluetoothGattConstants.CBUUID_CIR_NAMA_WRITE_CHARACTERISTIC {
                
                self.cwWriteCharacteristic = characteristic
                
            } else if characteristicUuid == BluetoothGattConstants.CBUUID_QUICK_COMMANDS_CHARACTERISTIC {
                
                self.cwQuickCommandsCharacteristic = characteristic
                
            } else if characteristicUuid == BluetoothGattConstants.CBUUID_DEVICE_INFO_CHARACTERISTIC {
                
                self.cwInfoCharacteristic = characteristic
                
            }
        }
        
        
        if let _ = cwInfoCharacteristic, let _ = cwNotificationCharacteristic,
            let _ = cwWriteCharacteristic, let _ = cwQuickCommandsCharacteristic {
            
            connectionStatus.text = NSLocalizedString("Device Connected", comment: "Device is now connected")
            connectingAlert?.dismiss(animated: true, completion: nil)
            cirWirelessMac.text = self.cirWireless?.getCirWirelessMac()
            
        }
    }
    
    
    func updateBluetoothConnectProcess(status: BluetoothConnectionProcess) {
        print(status)
        
        switch status {
        case .connecting :
            print("connecting")
            
            
        case .connected :
            bluetoothActions?.discoverCirWirelessServices(specificServices: nil)
            
            
        case .disconnecting :
            print("disconnecting")
            
            
        case .disconnected :
            print("disconnected")
            
            
        case .discoveringServicesAndCharacteristics :
            print("discoveringServices")
            
            
        case .connectionFailed :
            print("connectionFailed")
            
            
        case .servicesDiscovered :
            print("servicesDiscovered")
        
            
        case .characteristicsDiscovered :
            print("characteristicsDiscovered")
            
        
        case .noneServicesAvailable,
             .noneCharacteristicsAvailable :
            print("noneServicesOrCharacteristics")
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
