//
//  TestWiFiConnectionViewController.swift
//  cir_wireless
//
//  Created by softel on 30/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit
import CoreBluetooth

class TestWiFiConnectionViewController: UIViewController {
    
    var bluetoothActions                : CoreBluetoothActions?
    var cirWireless                     : CirWirelessModel?
    
    
    // MARK: Servicios bluetooth de la cir wireless
    var cwProtocolService                       : CBService?
     
     
    // MARK: Caracteristicas bluetooth de la cir wireless
    var cwProtocolNotificationCharac            : CBCharacteristic?
    var cwProtocolWriteCharacteristic           : CBCharacteristic?
    
    // Outlets
    @IBOutlet weak var iPLabel          : UILabel!
    @IBOutlet weak var ssidLabel        : UILabel!
    @IBOutlet weak var rssiLabel        : UILabel!
    @IBOutlet weak var aPLabel          : UILabel!
    @IBOutlet weak var internetLabel    : UILabel!
    @IBOutlet weak var dataLabel        : UILabel!
    @IBOutlet weak var statusLabel      : UILabel!
    @IBOutlet weak var cwMacLabel       : UILabel!
    
    
    // Ciclo de vida de la vista --------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let _ = bluetoothActions {
            bluetoothActions?.bluetoothBaseDelegate  = self
            bluetoothActions?.bluetoothPolingDelegate   = self
            bluetoothActions?.setCirWirelessNotifyCharacteristic(enable: true, notifyCharacteristic: cwProtocolNotificationCharac!)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        bluetoothActions?.setCirWirelessNotifyCharacteristic(enable: false, notifyCharacteristic: cwProtocolNotificationCharac!)
    }
    // -----------------------------------------------------------
    
}


extension TestWiFiConnectionViewController: BluetoothBaseProtocol {
    func updateCentralState(newState: CBManagerState) {
        print("updateCentralState: ")
    }
    
    func updateBluetoothActionProcess(status: BluetoothActionsProcess) {
        print("updateBluetoothActionProcess: ")
    }
    
    
}


extension TestWiFiConnectionViewController: BluetoothPolingProtocol {
    
    func successfullyReadCharacteristic(characteristic: CBCharacteristic, readValue: Data?) {
        print("TestWiFi:successfullyReadCharacteristic: ")
    }
    
    
    func successfullyWrittenInCharacteristic(characteristic: CBCharacteristic, writtenValue: Data) {
        print("TestWiFi:successfullyWrittenInCharacteristic: ")
    }
    
    
    func successfullyWrittenInDescriptor(descriptor: CBDescriptor, writtenValue: Data) {
        print("TestWiFi:successfullyWrittenInDescriptor: ")
    }
    
}


enum TestConnectionMachineState: Int {
    case _GET_STATUS_TASK  = 0
    
    case _
}
