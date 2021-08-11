//
//  TestController.swift
//  cir_wireless
//
//  Created by softel on 09/06/20.
//  Copyright © 2020 SOFTEL. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class ScanBleController: UIViewController {
    let manager = CLLocationManager()
    
    // MARK: Constants
    let DEFAULT_SCANNING_TIME           : Double = 8
    let REUSABLE_CELL_ID                = "cir_wireless"
    let REUSABLE_CELL_NAME              = "CirWirelessCell"
    let _ACCEPT                         = NSLocalizedString("Accept", comment: "")
    let _SETTINGS                       = NSLocalizedString("System Settings", comment: "Leads user to setting values")
    
    
    // MARK: Outlets
    @IBOutlet weak var courtain         : CourtainView!
    @IBOutlet weak var cirWirelessTable : UITableView!
    
    
    // MARK: Variables para el escaneo de dispositivos
    var isBluetoothOn                   = false
    var bluetoothActions                : CoreBluetoothActions?
    var cirsFound                       = [CirWirelessModel] ()
    var selectedCirWireless             : CirWirelessModel?
    var locationManager                 : CLLocationManager?
    
    
    lazy var refreshControl: UIRefreshControl = {
           let refreshControl = UIRefreshControl()
           refreshControl.addTarget(self, action:
               #selector(handleRefresh(_:)),
                                    for: UIControl.Event.valueChanged)
           refreshControl.tintColor = UIColor.lightGray

           return refreshControl
    }()
    
    // Ciclo de vida de la vista --------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // MARK: Comenzamos a escanear
        bluetoothActions = CoreBluetoothActions(filterBy: [BluetoothGattConstants.CBUUID_SERVICE_CIR_WIRELESS],
                                scanningTime: self.DEFAULT_SCANNING_TIME)
        bluetoothActions?.bluetoothBaseDelegate = self
        bluetoothActions?.bluetoothScanDelegate = self

        
        // Para pedir los permisos de localizacion
        locationManager = CLLocationManager()
        locationManager?.delegate = self

        
        // MARK: Algunos cambios en las vistas al iniciar
        loadViews()
        registerTableViewCells()

        
        // Revisamos permisos de ubicacion
        arePermissionsGranted()
    }
    // -----------------------------------------------------------
    
    
    // Funciones utiles del propio controler ---------------------
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
    
    
    private func arePermissionsGranted () {

        if CLLocationManager.locationServicesEnabled() {
            
            switch manager.authorizationStatus {
                
                case .notDetermined,
                     .restricted,
                     .denied:
                    locationManager?.requestAlwaysAuthorization()
    
                case .authorizedAlways,
                     .authorizedWhenInUse:
                    bluetoothActions?.initScan()
                
                @unknown default:
                break
                
            }
            
        } else {
            
            print("Location services are not enabled")
            popUpLocationServicesDisabled()
        }
    }
    
    
    private func scanAgain () {
        if isBluetoothOn {
            
            courtain.visibility = .visible
            courtain.showCourtain(animationFinished: { _ in
                self.refreshControl.endRefreshing()
            })
            bluetoothActions?.scanDevices()
            
        } else {
            
            popUpTurnedBluetoothOff()
            
        }
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        scanAgain()
    }
    
    
    private func registerTableViewCells () {
        let cirWirelessCell = UINib(nibName: REUSABLE_CELL_NAME, bundle: nil)
        self.cirWirelessTable.register(cirWirelessCell, forCellReuseIdentifier: REUSABLE_CELL_ID)
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ConfigurationController {
            destination.cirWireless = self.selectedCirWireless
            destination.bluetoothActions = self.bluetoothActions
        }
    }
    
    
    // Pop Ups Area :D -------------------------------------------
    // Pop up los permisos negados de bluetooth
    private func popUpBluetoothPermissionDenied () {
        var permissionPopUp: UIAlertController?
        
        let permissionTitleAlert = NSLocalizedString("BLE Persmission Title Denied",
                                                      comment: "Permission needs to be updated")
        let permissionMessageAlert = NSLocalizedString("BLE Persmission Message Denied",
                                                        comment: "Permission needs to be updated")
        let permissionAlertComponents = AlertComponents(alertTitle: permissionTitleAlert, alertMessage: permissionMessageAlert)
        

        let settings = AlertActionComponents(
            buttonTitle: _SETTINGS,
            buttonHandler: {(_) -> Void in
                let settingsUrl = URL(string: UIApplication.openSettingsURLString)
                if UIApplication.shared.canOpenURL(settingsUrl!) {
                    UIApplication.shared.open(
                        settingsUrl!,
                        completionHandler: { (success) in
                            permissionPopUp?.dismiss(animated: true, completion: nil)
                        })
                }
        })
        
        let accept = AlertActionComponents(buttonTitle: _ACCEPT, buttonHandler: {_ in
            permissionPopUp?.dismiss(animated: true, completion: nil)
        })
        
        permissionPopUp = try? PopUpAlert.popUpTwoButtons(alertCharacteristic: permissionAlertComponents,
                                                             buttonCharacteristic: [accept, settings])
        
        self.present(permissionPopUp!, animated: true, completion: nil)
    }
    
    
    private func popUpLocationServicesDisabled () {
        var locationPopUp: UIAlertController?
        
        let locationTitleAlert      = NSLocalizedString("Location Services",
                                                      comment: "Location Services are disabled")
        let locationMessageAlert    = NSLocalizedString("Location Services Disabled",
                                                        comment: "")
                   
        let locationAlertComponents = AlertComponents(alertTitle: locationTitleAlert, alertMessage: locationMessageAlert)
        let settings       = AlertActionComponents(
            buttonTitle: _SETTINGS,
            buttonHandler: {(_) -> Void in
                let locationURL = URL(string: UIApplication.openSettingsURLString)

                if UIApplication.shared.canOpenURL(locationURL!) {
                    UIApplication.shared.open(locationURL!,
                                              completionHandler: { (success) in
                                                locationPopUp?.dismiss(animated: true, completion: nil)
                    })
                }
        })
        
        let accept = AlertActionComponents(buttonTitle: _ACCEPT, buttonHandler: {_ in
            locationPopUp?.dismiss(animated: true, completion: {
                self.bluetoothActions?.initScan()
            })
        })
        
        locationPopUp = try? PopUpAlert.popUpTwoButtons(alertCharacteristic: locationAlertComponents,
                                                         buttonCharacteristic: [accept, settings])

        self.present(locationPopUp!, animated: true, completion: nil)
    }
    
    
    // Pop up para indicar que ningun dispositivo Cir ha sido encontrado
    private func popUpNoneCirsFound () {
        var scanResultPopUp         : UIAlertController?
        
        let scanAlertTitle          = NSLocalizedString("Bluetooth Scanning",
                                           comment: "None Cir Wireless near by")
        
        let scanAlertMessage        = NSLocalizedString("Cir's Not Found",
                                             comment: "None Cir Wireless near by")
        
        let scanAlertComponents     = AlertComponents(alertTitle: scanAlertTitle,
                                              alertMessage: scanAlertMessage)
        
        let retryActionComponents   = AlertActionComponents(
            buttonTitle: NSLocalizedString("Retry",
                                           comment: "Scan again"),
            
            buttonHandler: {(_) -> Void in
                scanResultPopUp?.dismiss(animated: true, completion: nil)
                self.scanAgain()
        })
        
        let acceptActionComponents  = AlertActionComponents(
            buttonTitle: _ACCEPT,
            buttonHandler: {(_) -> Void in
                scanResultPopUp?.dismiss(animated: true, completion: nil)
        })
        
        scanResultPopUp             = try? PopUpAlert.popUpTwoButtons(alertCharacteristic: scanAlertComponents,
                                                          buttonCharacteristic: [acceptActionComponents, retryActionComponents])
        
        self.present(scanResultPopUp!, animated: true, completion: nil)
    }
    
    
    // Pop up para indicar que el bluetooth ha sido apagado
    private func popUpTurnedBluetoothOff () {
        var bluetoothOffPopUp               : UIAlertController?
        
        let bluetoothOffTitle               = NSLocalizedString("Bluetooth Off Title",
                                                  comment: "When user turns bluetooth off in the middle of a process")
        let bluetoothOffMessage             = NSLocalizedString("Bluetooth Off Message",
                                                    comment: "Bluetooth is mandatory for many process in the app")
        
        let bluetoothOffAlertComponents     = AlertComponents(alertTitle: bluetoothOffTitle,
                                                 alertMessage: bluetoothOffMessage)
        let acceptActionComponents          = AlertActionComponents(
                  buttonTitle: NSLocalizedString("Accept",
                                                comment: "Just to dismiss dialog"),
                  buttonHandler: { _ -> Void in
                    // En caso de que haya hecho scroll en la lista
                    self.refreshControl.endRefreshing()
                    
                    bluetoothOffPopUp?.dismiss(animated: true, completion: nil)
                    
        })
        
        bluetoothOffPopUp                   = PopUpAlert.popUpOneButton(alertCharacteristic: bluetoothOffAlertComponents,
                                                           buttonCharacteristic: acceptActionComponents)
        
        self.present(bluetoothOffPopUp!, animated: true, completion: nil)
    }
    // ------------------------------------------------
    // ------------------------------------------------
}



// Delegados para la tabla de CIRs encontradas ----------------------------
extension ScanBleController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cirsFound.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cirWirelessCell                     = cirWirelessTable.dequeueReusableCell(withIdentifier: REUSABLE_CELL_ID,
                                                                   for: indexPath) as? CirWirelessCell
        
        cirWirelessCell?.cirWirelessModelName.text  = (cirsFound[indexPath.row]).beacon?.beaconModelName
        cirWirelessCell?.cirWirelessMac.text        = (cirsFound[indexPath.row]).getCirWirelessMac()
        cirWirelessCell?.cirModel                   = cirsFound[indexPath.row]
        
        return cirWirelessCell!
    }
}


extension ScanBleController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isBluetoothOn {
            
            selectedCirWireless = cirsFound[indexPath.row]
            self.performSegue(withIdentifier: ControllerIdentifiers.vcConfiguration.rawValue, sender: self)
            
        } else {
            
            popUpTurnedBluetoothOff()
            
        }
    }
}
// --------------------------------------------------------------------------



// Extensiones de los protocolos --------------------------------------------
extension ScanBleController: BluetoothBaseProtocol {
    
    func updateBluetoothActionProcess(status: BluetoothActionsProcess) {
        print(status)
    }
    
    
    func updateCentralState(newState: CBManagerState) {
        
        switch newState {
            
        case .poweredOn :
            print("poweredOn")
            isBluetoothOn = true
            bluetoothActions?.scanDevices()
               
               
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
       
}


extension ScanBleController: BluetoothScanProtocol {
    
    func updateBluetoothScanProcess(status: BluetoothScanProcess) {
        print(status)
    }
    
      
    func scanFinished (scannedDevices: [CirWirelessModel]) {
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
    
      
    func errorScanOcurred(error: ErrorBluetoothActions) {
        print("errorOcurred: \(error)")
    }
}
// --------------------------------------------------------------------------



extension ScanBleController:  CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .restricted,
             .denied:
            popUpLocationServicesDisabled()

        
        case .authorizedAlways,
             .authorizedWhenInUse:
            bluetoothActions?.initScan()
            
        default:
            break
        }
        
    }
}
