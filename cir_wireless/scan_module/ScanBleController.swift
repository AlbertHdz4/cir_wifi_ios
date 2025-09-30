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
import Alamofire
import CoreData

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

        // MARK: Para pedir los permisos de localizacion
        locationManager = CLLocationManager()
        locationManager?.delegate = self

        // MARK: Algunos cambios en las vistas al iniciar
        loadViews()
        registerTableViewCells()
        
        // MARK: Request token auth
        requestAuthToken()
        
        // MARK: Revisamos permisos de ubicacion
        arePermissionsGranted()
    }
    // -----------------------------------------------------------
    
    
    private func getSupportedFirmwares () -> [Int] {
        var supportedFirmwares = [Int] ()
        
        let fetchRequest = NSFetchRequest <Firmwares> (entityName: "Firmwares")

        do {
            let firmwares = try CoreDataManager.shared.viewContext.fetch(fetchRequest)
            
            print("getSupportedFirmwares: \(firmwares)")
            
            for supportedFirmware in firmwares {
                // print("Supported firmwares: \(supportedFirmware.firmware_version!) ")
                supportedFirmwares.append(Int(supportedFirmware.firmware_version!)!)
            }
            
        } catch {
            print("Error al recuperar datos: \(error)")
        }
        
        return supportedFirmwares
    }
    
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
    

    private func requestAuthToken () {
        var url     = ""
        var pass    = ""
        
        do {
            
           
            // print("La aplicación está en modo de depuración.")
            // url     = ApiFirmwaresConstants.BASE_URL_DEV + ApiFirmwaresConstants.LOGIN_URL
            // pass    = try decrypt(encryptedPassword: ApiFirmwaresConstants.ENCRYPTED_PASS_DEV_FW_API,
            //                       key: ApiFirmwaresConstants.SECRET_KEY)
            // print("pass dev: \(pass)")
            
                        
            url     = ApiFirmwaresConstants.BASE_URL_PROD + ApiFirmwaresConstants.LOGIN_URL
            pass    = try decrypt(encryptedPassword: ApiFirmwaresConstants.ENCRYPTED_PASS_PROD_FW_API,
                                  key: ApiFirmwaresConstants.SECRET_KEY)
            // print("pass prod: \(pass)")

            // print("La aplicación está en modo de producción.")
        } catch {
            print("Error: \(error)")
        }

        let parameters: Parameters = [
            "email"     : ApiFirmwaresConstants.USR_FW_API,
            "password"  : pass
        ]

        // print("url: \(url)")
        // print("usrname and passcode: \(parameters)")

        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<599)
            .responseJSON { response in
                switch response.result {
                    
                case .success(let value):
                    
                    if let rawJson = value as? [String: Any], let rawData = rawJson["data"] as? [String: Any] {
                        
                        let token       = rawData["token"] as! String?
                        let email       = rawData["email"] as! String?
                        let expiresIn   = rawData["expiresIn"] as! String?
                        
                        let managedContext = AppDelegate.sharedAppDelegate.coreDataStack.managedContext
                        self.deleteLocalUserData(managedContext: managedContext)
                        
                        // Crear un nuevo objeto
                        let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: CoreDataManager.shared.viewContext) as! User
                        
                        user.token      = token
                        user.expires_in = expiresIn
                        
                        // Guardar cambios en el contexto
                        CoreDataManager.shared.saveContext()
                        
                        self.requestSupportedFirmwares(user: self.getLocalUserData()!)
                        

                    } else {
                        print("Respuesta JSON no válida")
                    }

                    
                case .failure(let error):
                    print("Error al obtener el token: \(error)")
                }
            }
    }
    
    
    private func requestSupportedFirmwares(user: User) {
        guard let token = user.token, !token.isEmpty else {
            print("Token vacío/nulo")
            return
        }

        let url = ApiFirmwaresConstants.BASE_URL_PROD + ApiFirmwaresConstants.FIRMWARE_URL
        let headers: HTTPHeaders = [
            "Authorization": "Softel \(token)",
            "Content-Type": "application/json"
        ]
        let parameters: Parameters = [
            "applicationId": ApiFirmwaresConstants.APP_DOMAIN
            // TIP: considera enviar también el CFBundleIdentifier si el backend lo usa para autorizar
            // "bundleId": Bundle.main.bundleIdentifier ?? ""
        ]

        // Usa SIEMPRE el mismo contexto
        let context = CoreDataManager.shared.viewContext

        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
            .validate(statusCode: 200..<300)               // <-- solo 2xx
            .responseData { response in
                let status = response.response?.statusCode ?? -1
                // print("FW request status=\(status) URL=\(url)")

                switch response.result {
                case .failure(let error):
                    // Loguea el cuerpo para entender errores 4xx/5xx
                    if let data = response.data, let body = String(data: data, encoding: .utf8) {
                        print("FW request failed. Body:\n\(body)")
                    }
                    print("FW request error: \(error.localizedDescription)")
                    return

                case .success(let data):
                    // Parseo seguro
                    do {
                        guard
                            let raw = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                            let rawData = raw["data"] as? [String: Any],
                            let supported = rawData["supportedFw"] as? [[String: Any]]
                        else {
                            print("Estructura JSON inesperada")
                            if let s = String(data: data, encoding: .utf8) { print("Respuesta:\n\(s)") }
                            return
                        }
                        
                        // print("Supported firmwares count: \(supported.count)")

                        // Todo cambio en Core Data en el hilo del contexto
                        context.perform {
                            self.deleteLocalFirmwaresData(managedContext: context)

                            for item in supported {
                                guard
                                    let fwStr = item["fw"] as? String,
                                    let uid = item["uid"] as? String
                                else { continue }

                                let fw = NSEntityDescription.insertNewObject(forEntityName: "Firmwares", into: context) as! Firmwares
                                fw.active = 1
                                fw.firmware_version = fwStr.replacingOccurrences(of: ".", with: "")
                                // Si tu modelo tiene 'uid', ¡guárdalo!
                                // fw.uid = uid
                            }

                            do {
                                try context.save()
                                print("Firmwares saved ✅")
                                self.showToast(message: NSLocalizedString("Firmware DB updated", comment: ""), duration: 3.0)
                            } catch {
                                print("Error guardando Core Data: \(error.localizedDescription)")
                                self.showToast(message: NSLocalizedString("Firmware DB updated Error", comment: ""), duration: 3.0)
                            }
                        }
                    } catch {
                        print("Error parseando JSON: \(error.localizedDescription)")
                        if let s = String(data: data, encoding: .utf8) { print("Respuesta:\n\(s)") }
                    }
                }
            }
    }
    
    
    private func validateExpirationUserToken (user: User?) -> Bool {
        
        if (user != nil) {
          
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale.current
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Ajusta el formato según tu string
            dateFormatter.timeZone = TimeZone.current // Utiliza la zona horaria local

            let currentDate         = Date()
            let currentDatee        = self.convertStringToDate(dateString: dateFormatter.string(from: currentDate))
            let tokenExpirationDate = self.convertStringToDate(dateString: user!.expires_in!.truncateString(longitudMaxima: 19))

            // print("User date: \(user!.expires_in!)")
            // print("Current date: \(currentDatee)")
            // print("Token expiration date: \(tokenExpirationDate!)")
            // print("Comparission: \(Calendar.current.compare(currentDatee!, to: tokenExpirationDate!, toGranularity: .second) == .orderedDescending)")
            
            if (tokenExpirationDate != nil && currentDatee != nil) {
                return Calendar.current.compare(currentDatee!, to: tokenExpirationDate!, toGranularity: .second) == .orderedDescending
            }
        }
        
        return true
    }
    
    
    private func convertStringToDate (dateString: String) -> Date? {
        let dateFormatter           = DateFormatter()
        dateFormatter.locale        = Locale.current
        dateFormatter.dateFormat    = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone      = TimeZone.current
        return dateFormatter.date(from: dateString)
    }
    
    
    private func getLocalUserData () -> User? {
        var user : User?
        
        let fetchRequest = NSFetchRequest <User> (entityName: "User")

        do {
            let users = try CoreDataManager.shared.viewContext.fetch(fetchRequest)
            for userr in users {
                // print("getLocalUserData: User: \(userr)")
                user = userr
            }
        } catch {
            print("Error al recuperar datos: \(error)")
        }
        
        return user
    }
    
    
    private func deleteLocalUserData (managedContext : NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            print("ERROR: \(error.localizedDescription)")
        }
    }
    

    private func deleteLocalFirmwaresData (managedContext : NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Firmwares")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            print("ERROR: \(error.localizedDescription)")
        }
    }
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


extension String {
    
    func truncateString (longitudMaxima: Int) -> String {
        if self.count > longitudMaxima {
            let indiceFinal = self.index(self.startIndex, offsetBy: longitudMaxima)
            return String(self[..<indiceFinal])
        } else {
            return self
        }
    }
    
    
    func removeCharFromString(caracterARemover: Character) -> String {
        let resultado = String(self.filter { $0 != caracterARemover })
        return resultado
    }
}

extension UIViewController {
    
    /// Muestra un mensaje tipo "Toast" en la parte inferior de la pantalla.
    func showToast(message: String, duration: Double = 2.0) {
        // Crea la etiqueta donde irá el texto
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.numberOfLines = 0
        
        // Ajusta el padding y el color de fondo
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        
        // Calcula la altura y anchura en función del texto, con un máximo para que no se salga de pantalla
        let maxWidthPercentage: CGFloat = 0.8 // 80% del ancho de la pantalla
        let maxTitleSize = CGSize(width: self.view.bounds.width * maxWidthPercentage, height: CGFloat.greatestFiniteMagnitude)
        let expectedSize = toastLabel.sizeThatFits(maxTitleSize)
        
        // Ajusta el frame de la etiqueta
        toastLabel.frame = CGRect(
            x: 0,
            y: 0,
            width: expectedSize.width + 20,  // padding horizontal
            height: expectedSize.height + 20 // padding vertical
        )
        
        // Centra la etiqueta horizontalmente y sitúa la parte inferior con un margen
        toastLabel.center = CGPoint(
            x: self.view.center.x,
            y: self.view.bounds.height - (toastLabel.frame.height + 50)
        )
        
        // Agrega la etiqueta a la vista
        self.view.addSubview(toastLabel)
        
        // Establece la opacidad inicial en 0 (invisible)
        toastLabel.alpha = 0.0
        
        // Animamos para que aparezca
        UIView.animate(withDuration: 0.5, animations: {
            toastLabel.alpha = 1.0
        }, completion: { _ in
            // Tras la duración establecida, se oculta y se remueve
            UIView.animate(withDuration: 0.5, delay: duration, options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        })
    }
}
