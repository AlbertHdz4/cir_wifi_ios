//
//  TestController.swift
//  cir_wireless
//
//  Created by softel on 09/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit
import CoreBluetooth


class ScanBleController: UIViewController {
    
    // MARK: Constants
    let DEFAULT_SCANNING_TIME: Double = 8
    let REUSABLE_CELL_ID = "cir_wireless"
    let REUSABLE_CELL_NAME = "CirWirelessCell"
    
    
    // MARK: Outlets
    @IBOutlet weak var courtain: CourtainView!
    @IBOutlet weak var cirWirelessTable: UITableView!
    
    
    // MARK: Variables para el escaneo de dispositivos
    var isBluetoothOn = false
    var bleScan: BluetoothScan?
    var cirsFound = [CirWirelessModel] ()
    var selectedCirWireless : CirWirelessModel?
    
    
    lazy var refreshControl: UIRefreshControl = {
           let refreshControl = UIRefreshControl()
           refreshControl.addTarget(self, action:
               #selector(handleRefresh(_:)),
                                    for: UIControl.Event.valueChanged)
           refreshControl.tintColor = UIColor.lightGray

           return refreshControl
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // MARK: Algunos cambios en las vistas al iniciar
        loadViews()
        registerTableViewCells()
        
        
        // MARK: Comenzamos a escanear
        bleScan = BluetoothScan(filterBy: [BluetoothGattConstants.CBUUID_SERVICE_CIR_WIRELESS],
                                scanningTime: self.DEFAULT_SCANNING_TIME)
        bleScan?.bleScanDelegate = self
        bleScan?.initScan()
    }
    
    
    // MARK: Funciones utiles del propio controler
    private func loadViews () {
        courtain.courtainMessage.text = NSLocalizedString("Scanning Devices", comment: "Scanning BLE Devices")
        
        // Customizamos la table view
        cirWirelessTable.backgroundColor = .white
        cirWirelessTable.refreshControl = refreshControl
        cirWirelessTable.tableFooterView = UIView()
        
        // Implementamos protocolos
        cirWirelessTable.dataSource = self
        cirWirelessTable.delegate = self
    }
    
    
    private func scanAgain () {
        if isBluetoothOn {
            
            courtain.visibility = .visible
            courtain.showCourtain(animationFinished: { _ in
                self.refreshControl.endRefreshing()
            })
            bleScan?.scanDevices()
            
        } else {
            
            popUpTurnedBluetoothOff()
            
        }
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        print("Refreshing ... ")
        scanAgain()
    }
    
    
    private func registerTableViewCells () {
        let cirWirelessCell = UINib(nibName: REUSABLE_CELL_NAME, bundle: nil)
        self.cirWirelessTable.register(cirWirelessCell, forCellReuseIdentifier: REUSABLE_CELL_ID)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ConfigurationController {
            destination.cirWireless = self.selectedCirWireless
        }
    }
    
    
    // MARK: Pop Ups Area :D
    // Pop up los permisos negados de bluetooth
    private func popUpBluetoothPermissionDenied () {
        var permissionPopUp: UIAlertController?
        
        let permissionTitleAlert = NSLocalizedString("BLE Persmission Title Denied",
                                                      comment: "Permission needs to be updated")
        let persmissionMessageAlert = NSLocalizedString("BLE Persmission Message Denied",
                                                        comment: "Permission needs to be updated")
                   
        let permissionAlertComponents = AlertComponents(alertTitle: permissionTitleAlert, alertMessage: persmissionMessageAlert)
        let permissionActionComponents = AlertActionComponents(buttonTitle: NSLocalizedString("Settings",
                                                                                              comment: "Leads user to setting values"),
                                                               buttonHandler: {(_) -> Void in
                                                                let settingsUrl = URL(string: UIApplication.openSettingsURLString)
                                                                if UIApplication.shared.canOpenURL(settingsUrl!) {
                                                                    UIApplication.shared.open(
                                                                        settingsUrl!,
                                                                        completionHandler: { (success) in
                                                                            permissionPopUp?.dismiss(animated: true, completion: nil)
                                                                    }
                                                                    )
                                                                }
        })
        
        permissionPopUp = PopUpAlert.popUpOneButton(alertCharacteristic: permissionAlertComponents,
                                                     buttonCharacteristic: permissionActionComponents)
                   
        self.present(permissionPopUp!, animated: true, completion: nil)
    }
    
    
    // Pop up para indicar que ningun dispositivo Cir ha sido encontrado
    private func popUpNoneCirsFound () {
        let scanAlertTitle = NSLocalizedString("Bluetooth Scanning",
                                           comment: "None Cir Wireless near by")
        let scanAlertMessage = NSLocalizedString("Cir's Not Found",
                                             comment: "None Cir Wireless near by")
        
        var scanResultPopUp: UIAlertController?
        
        let scanAlertComponents = AlertComponents(alertTitle: scanAlertTitle,
                                              alertMessage: scanAlertMessage)
        let retryActionComponents = AlertActionComponents(
            buttonTitle: NSLocalizedString("Retry",
                                           comment: "Scan again"),
            
            buttonHandler: {(_) -> Void in
                scanResultPopUp?.dismiss(animated: true, completion: nil)
                self.scanAgain()
        })
        
        let acceptActionComponents = AlertActionComponents(
            buttonTitle: NSLocalizedString("Accept",
                                          comment: "Just to dismiss dialog"),
            buttonHandler: {(_) -> Void in
                scanResultPopUp?.dismiss(animated: true, completion: nil)
        })
        
        scanResultPopUp = try? PopUpAlert.popUpTwoButtons(alertCharacteristic: scanAlertComponents,
                                                          buttonCharacteristic: [acceptActionComponents, retryActionComponents])
        
        self.present(scanResultPopUp!, animated: true, completion: nil)
    }
    
    
    // Pop up para indicar que el bluetooth ha sido apagado
    private func popUpTurnedBluetoothOff () {
        var bluetoothOffPopUp: UIAlertController?
        
        let bluetoothOffTitle = NSLocalizedString("Bluetooth Off Title",
                                                  comment: "When user turns bluetooth off in the middle of a process")
        let bluetoothOffMessage = NSLocalizedString("Bluetooth Off Message",
                                                    comment: "Bluetooth is mandatory for many process in the app")
        
        let bluetoothOffAlertComponents = AlertComponents(alertTitle: bluetoothOffTitle,
                                                 alertMessage: bluetoothOffMessage)
        let acceptActionComponents = AlertActionComponents(
                  buttonTitle: NSLocalizedString("Accept",
                                                comment: "Just to dismiss dialog"),
                  buttonHandler: { _ -> Void in
                    // En caso de que haya hecho scroll en la lista
                    self.refreshControl.endRefreshing()
                    
                    bluetoothOffPopUp?.dismiss(animated: true, completion: nil)
                    
        })
        
        bluetoothOffPopUp = PopUpAlert.popUpOneButton(alertCharacteristic: bluetoothOffAlertComponents,
                                                           buttonCharacteristic: acceptActionComponents)
        
        self.present(bluetoothOffPopUp!, animated: true, completion: nil)
    }
    // Pop Ups area :D (End)
    // Funciones utiles del propio controler (End)
}


// MARK: Delegados para la tabla de CIRs encontradas
extension ScanBleController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("EXECUTING TABLE VIEW: \(cirsFound.count)")
        return cirsFound.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cirWirelessCell = cirWirelessTable.dequeueReusableCell(withIdentifier: REUSABLE_CELL_ID,
                                                                   for: indexPath) as? CirWirelessCell
        
        cirWirelessCell?.cirWirelessMac.text = (cirsFound[indexPath.row]).getCirWirelessMac()
        cirWirelessCell?.cirModel = cirsFound[indexPath.row]
        
        return cirWirelessCell!
    }
}


extension ScanBleController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("indexPath: \(cirsFound[indexPath.row].getCirWirelessMac())")
        
        if isBluetoothOn {
            selectedCirWireless = cirsFound[indexPath.row]
            self.performSegue(withIdentifier: ControllerIdentifiers.vcConfiguration.rawValue, sender: self)
        } else {
            popUpTurnedBluetoothOff()
        }
    }
}
// Delegados para la tabla de CIRs encontradas (End)


// MARK: Scan Devices Protocol
extension ScanBleController: ScanProtocol {
    
    func updateCentralState(newState: CBManagerState) {
        switch newState {
        case .poweredOn :
            print("poweredOn")
            isBluetoothOn = true
            bleScan?.scanDevices()
            
            
        case .poweredOff :
            print("poweredOff")
            isBluetoothOn = false
            popUpTurnedBluetoothOff()
          
          
        case .resetting :
            print("resetting")
          
          
        case .unauthorized :
            print("unauthorized")
            popUpBluetoothPermissionDenied()
           
          
        case .unknown :
            print("unknown")
          
          
        case .unsupported :
            print("unsupported")
          
          
        default:
            print("\(newState)")
        }
      }
    
    
    func updateScanProcessState(status: ScanProcess) {
        print("updateScanProcessState: \(status)")
    }
      
      
    func scanFinished(scannedDevices: [CirWirelessModel]) {
        self.courtain.hideCourtain(animationFinished: { _ in
            self.courtain.visibility = .invisible
        })
        
        if scannedDevices.count != 0 {
            self.cirsFound.removeAll()
            self.cirsFound = scannedDevices
            self.cirWirelessTable.reloadData()

        } else {
            popUpNoneCirsFound()
        }
    }
    
      
    func errorScanOcurred(error: ErrorBluetoothScan) {
        print("errorOcurred: \(error)")
    }
}
// Scan Devices Protocol (End)
