
import UIKit
import CoreBluetooth
import QuartzCore

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


class MainController: UIViewController, UITableViewDelegate, UITableViewDataSource, BluetoothDelegate {
    
    fileprivate class PeripheralInfos: Equatable, Hashable {
        let peripheral: CBPeripheral
        var RSSI: Int = 0
        var advertisementData: [String: Any] = [:]
        var lastUpdatedTimeInterval: TimeInterval
        
        init(_ peripheral: CBPeripheral) {
            self.peripheral = peripheral
            self.lastUpdatedTimeInterval = Date().timeIntervalSince1970
        }
        
        static func == (lhs: PeripheralInfos, rhs: PeripheralInfos) -> Bool {
            return lhs.peripheral.isEqual(rhs.peripheral)
        }
        
        var hashValue: Int {
            return peripheral.hash
        }
    }
    
    let bluetoothManager = BluetoothManager.getInstance()
    var connectingView: ConnectingView?
    fileprivate var nearbyPeripheralInfos: [PeripheralInfos] = []
    var cachedVirtualPeripherals: [VirtualPeripheral] {
        return VirtualPeripheralStore.shared.cachedVirtualPeripheral
    }
    var preferences: Preferences? {
        return PreferencesStore.shared.preferences
    }
    var selectedVirtualPeriperalIndex: Int = -1
    
    @IBOutlet var peripheralsTb: UITableView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topView.layer.cornerRadius = 16
        self.topView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        self.searchBar.layer.cornerRadius = 16
        self.searchBar.clipsToBounds = true
        self.view.backgroundColor = .white
        self.peripheralsTb.backgroundColor = .white
        peripheralsTb.register(UITableViewCell.self, forCellReuseIdentifier: "SearchingCell")
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        nearbyPeripheralInfos.removeAll()
        if bluetoothManager.connectedPeripheral != nil {
            bluetoothManager.disconnectPeripheral()
        }
        bluetoothManager.delegate = self
        peripheralsTb.reloadData()
    }
    
    // MARK: Delegates
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if nearbyPeripheralInfos.count == 0 {
            return
        }
        let peripheral = nearbyPeripheralInfos[indexPath.row].peripheral
        connectingView = ConnectingView.showConnectingView()
        connectingView?.tipNameLbl.text = peripheral.name
        bluetoothManager.connectPeripheral(peripheral)
        bluetoothManager.stopScanPeripheral()
    }
    
    // MARK： UITableViewDataSource
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard nearbyPeripheralInfos.count != 0 || indexPath.row != 0 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SearchingCell", for: indexPath) as UITableViewCell
            cell.textLabel?.text = "Searching for peripherals..."
            cell.selectionStyle = .none
            cell.textLabel?.font = UIFont.systemFont(ofSize: 12, weight: .thin)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "NearbyPeripheralCell") as! NearbyPeripheralCell
        let peripheralInfo = nearbyPeripheralInfos[indexPath.row]
        let peripheral = peripheralInfo.peripheral
        
        cell.peripheralNameLbl.text = peripheral.name == nil || peripheral.name == ""  ? "Unnamed" : peripheral.name
        
        if let serviceUUIDs = peripheralInfo.advertisementData["kCBAdvDataServiceUUIDs"] as? NSArray, serviceUUIDs.count != 0 {
            cell.serviceCountLbl.text = "\(serviceUUIDs.count) service" + (serviceUUIDs.count > 1 ? "s" : "")
        } else {
            cell.serviceCountLbl.text = "No service"
        }
        
        let RSSI = peripheralInfo.RSSI
        
        if RSSI == 127 {
            cell.signalStrengthLbl.text = "---"
            cell.serviceCountLbl.alpha = 0.4
            cell.peripheralNameLbl.alpha = 0.4
        } else {
            cell.signalStrengthLbl.text = "\(RSSI)"
            cell.serviceCountLbl.alpha = 1.0
            cell.peripheralNameLbl.alpha = 1.0
        }
        
        // The signal strength img icon
        switch labs(RSSI) {
        case 0...40:
            cell.signalStrengthImg.image = UIImage(named: "signal_strength_5")
        case 41...53:
            cell.signalStrengthImg.image = UIImage(named: "signal_strength_4")
        case 54...65:
            cell.signalStrengthImg.image = UIImage(named: "signal_strength_3")
        case 66...77:
            cell.signalStrengthImg.image = UIImage(named: "signal_strength_2")
        case 77...89:
            cell.signalStrengthImg.image = UIImage(named: "signal_strength_1")
        default:
            cell.signalStrengthImg.image = UIImage(named: "signal_strength_0")
        }
        return cell
    }
    
    // The tableview group header view
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0,y: 0,width: 0,height: 0))
        headerView.backgroundColor = .white
        let lblTitle = UILabel(frame: CGRect(x: 15, y: 10, width: view.frame.width, height: 20))
        lblTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        lblTitle.textColor = .darkGray
        lblTitle.text = "Peripherals Nearby"
        headerView.addSubview(lblTitle)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyPeripheralInfos.count == 0 ? 1 : nearbyPeripheralInfos.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // MARK: BluetoothDelegate
    func didDiscoverPeripheral(_ peripheral: CBPeripheral, advertisementData: [String : Any], RSSI: NSNumber) {
        let peripheralInfo = PeripheralInfos(peripheral)
        if !nearbyPeripheralInfos.contains(peripheralInfo) {
            if let preference = preferences, preference.needFilter {
                if RSSI.intValue != 127, RSSI.intValue > preference.filter {
                    peripheralInfo.RSSI = RSSI.intValue
                    peripheralInfo.advertisementData = advertisementData
                    nearbyPeripheralInfos.append(peripheralInfo)
                    LogStore.append("Discovered nearby peripheral: \(peripheral.name ?? "(null)") (RSSI: \(RSSI.intValue))")
                }
            } else {
                peripheralInfo.RSSI = RSSI.intValue
                peripheralInfo.advertisementData = advertisementData
                nearbyPeripheralInfos.append(peripheralInfo)
                LogStore.append("Discovered nearby peripheral: \(peripheral.name ?? "(null)")) (RSSI: \(RSSI.intValue))")
            }
        } else {
            guard let index = nearbyPeripheralInfos.firstIndex(of: peripheralInfo) else {
                return
            }
            
            let originPeripheralInfo = nearbyPeripheralInfos[index]
            let nowTimeInterval = Date().timeIntervalSince1970
            
            // If the last update within one second, then ignore it
            guard nowTimeInterval - originPeripheralInfo.lastUpdatedTimeInterval >= 1.0 else {
                return
            }
            
            originPeripheralInfo.lastUpdatedTimeInterval = nowTimeInterval
            originPeripheralInfo.RSSI = RSSI.intValue
            originPeripheralInfo.advertisementData = advertisementData
        }
        peripheralsTb.reloadData()
    }
    
    /**
     The bluetooth state monitor
     
     - parameter state: The bluetooth state
     */
    func didUpdateState(_ state: CBCentralManagerState) {
        print("MainController --> didUpdateState:\(state)")
        switch state {
        case .resetting:
            print("MainController --> State : Resetting")
            LogStore.append("Bluetooth State: Resetting")
        case .poweredOn:
            LogStore.append("Bluetooth State: Powered On")
            bluetoothManager.startScanPeripheral()
            UnavailableView.hideUnavailableView()
        case .poweredOff:
            print(" MainController -->State : Powered Off")
            LogStore.append("Bluetooth State: Powered Off")
            fallthrough
        case .unauthorized:
            print("MainController --> State : Unauthorized")
            LogStore.append("Bluetooth State: Unauthorized")
            fallthrough
        case .unknown:
            print("MainController --> State : Unknown")
            LogStore.append("Bluetooth State: Unknown")
            fallthrough
        case .unsupported:
            print("MainController --> State : Unsupported")
            LogStore.append("Bluetooth State: Unsupported")
            bluetoothManager.stopScanPeripheral()
            bluetoothManager.disconnectPeripheral()
            ConnectingView.hideConnectingView()
            UnavailableView.showUnavailableView()
        }
    }
    
    /**
     The callback function when central manager connected the peripheral successfully.
     
     - parameter connectedPeripheral: The peripheral which connected successfully.
     */
    func didConnectedPeripheral(_ connectedPeripheral: CBPeripheral) {
        print("MainController --> didConnectedPeripheral")
        connectingView?.tipLbl.text = "Interrogating..."
    }
    
    /**
     The peripheral services monitor
     
     - parameter services: The service instances which discovered by CoreBluetooth
     */
    func didDiscoverServices(_ peripheral: CBPeripheral) {
        print("MainController --> didDiscoverService:\(peripheral.services?.description ?? "Unknow Service")")
        
        let tmp = PeripheralInfos(peripheral)
        guard let index = nearbyPeripheralInfos.firstIndex(of: tmp) else {
            return
        }
        ConnectingView.hideConnectingView()
        let peripheralController = PeripheralController()
        let peripheralInfo = nearbyPeripheralInfos[index]
        peripheralController.lastAdvertisementData = peripheralInfo.advertisementData
        self.navigationController?.pushViewController(peripheralController, animated: true)
    }
    
    /**
     The method invoked when interrogated fail.
     
     - parameter peripheral: The peripheral which interrogation failed.
     */
    func didFailedToInterrogate(_ peripheral: CBPeripheral) {
        ConnectingView.hideConnectingView()
        AlertUtil.showCancelAlert("Connection Alert", message: "The perapheral disconnected while being interrogated.", cancelTitle: "Dismiss", viewController: self)
    }
    
}

