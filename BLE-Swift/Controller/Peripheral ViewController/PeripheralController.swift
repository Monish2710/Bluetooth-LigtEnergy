
import UIKit
import CoreBluetooth 

class PeripheralController : UIViewController, UITableViewDelegate, UITableViewDataSource, BluetoothDelegate {
    
    fileprivate let bluetoothManager = BluetoothManager.getInstance()
    fileprivate var showAdvertisementData = false
    fileprivate var services : [CBService]?
    fileprivate var characteristicsDic = [CBUUID : [CBCharacteristic]]()
    
    var lastAdvertisementData : Dictionary<String, Any>?
    fileprivate var advertisementDataKeys : [String]?
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet var peripheralNameLbl: UILabel!
    @IBOutlet var peripheralUUIDLbl: UILabel!
    @IBOutlet var connectFlagLbl: UILabel!
    @IBOutlet var tableViewHeight: NSLayoutConstraint!
    @IBOutlet var dataTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bluetoothManager.delegate = self
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: custom functions
    func initAll() {
        self.topView.layer.cornerRadius = 16
        self.topView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
        advertisementDataKeys = ([String](lastAdvertisementData!.keys)).sorted()
        bluetoothManager.discoverCharacteristics()
        services = bluetoothManager.connectedPeripheral?.services
        peripheralNameLbl.text = bluetoothManager.connectedPeripheral?.name
        peripheralUUIDLbl.text = bluetoothManager.connectedPeripheral?.identifier.uuidString
        reloadTableView()
    }
    
    /**
     The callback function of the Show Advertisement Data button click
     */
    @objc func showAdvertisementDataBtnClick() {
        print("PeripheralController --> showAdvertisementDataBtnClick")
        showAdvertisementData = !showAdvertisementData
        reloadTableView()
    }
    
    /**
     Reload tableView
     */
    func reloadTableView() {
        dataTableView.reloadData()
        
        // Fix the contentSize.height is greater than frame.size.height bug(Approximately 20 unit)
        tableViewHeight.constant = dataTableView.contentSize.height
    }
    
    /**
     According the characteristic property array get the properties string
     
     - parameter array: characteristic property array
     
     - returns: properties string
     */
    func getPropertiesFromArray(_ array : [String]) -> String {
        var propertiesString = "Properties:"
        let containWrite = array.contains("Write")
        for property in array {
            if containWrite && property == "Write Without Response" {
                continue
            }
            propertiesString += " " + property
        }
        return propertiesString
    }
    
    
    // MARK: Delegate
    // Mark: UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if showAdvertisementData {
                return advertisementDataKeys!.count
            } else {
                return 0
            }
        }
        let characteristics = characteristicsDic[services![section - 1].uuid]
        return characteristics == nil ? 0 : characteristics!.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print("numberOfSectionsInTableView:\(bluetoothManager.connectedPeripheral!.services!.count + 1)")
        return bluetoothManager.connectedPeripheral!.services!.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "serviceCell")
            cell?.selectionStyle = .none
            cell?.accessoryType = .disclosureIndicator
        }
        if indexPath.section == 0 {
            cell?.textLabel?.text = CBAdvertisementData.getAdvertisementDataStringValue(lastAdvertisementData!, key: advertisementDataKeys![indexPath.row])
            cell?.textLabel?.adjustsFontSizeToFitWidth = true
            
            cell?.detailTextLabel?.text = CBAdvertisementData.getAdvertisementDataName(advertisementDataKeys![indexPath.row])
        } else {
            let characteristic = characteristicsDic[services![indexPath.section - 1].uuid]![indexPath.row]
            cell?.textLabel?.text = characteristic.name
            cell?.detailTextLabel?.text = getPropertiesFromArray(characteristic.properties.names)
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        print("section:\(section)")
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.backgroundColor = UIColor(red: 239/255.0, green: 239/255.0, blue: 239/255.0, alpha: 1)
        
        let serviceNameLbl = UILabel(frame: CGRect(x: 10, y: 20, width: UIScreen.main.bounds.size.width - 100, height: 20))
        serviceNameLbl.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.medium)
        
        view.addSubview(serviceNameLbl)
        
        if section == 0 {
            serviceNameLbl.text = "ADVERTISEMENT DATA"
            let showBtn = UIButton(type: .system)
            showBtn.frame = CGRect(x: UIScreen.main.bounds.size.width - 80, y: 20, width: 60, height: 20)
            if showAdvertisementData {
                showBtn.setTitle("Hide", for: UIControl.State())
            } else {
                showBtn.setTitle("Show", for: UIControl.State())
            }

            showBtn.addTarget(self, action: #selector(self.showAdvertisementDataBtnClick), for: .touchUpInside)
            view.addSubview(showBtn)
        } else {
            let service = bluetoothManager.connectedPeripheral!.services![section - 1]
            serviceNameLbl.text = service.name
        }
        
        return view
    }
    
    // Need overide this method for fix start section from 1(not 0) in the method 'tableView:viewForHeaderInSection:' after iOS 7
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section != 0  else {
            return
        }
        
        print("Click at section: \(indexPath.section), row: \(indexPath.row)")
        let controller = CharacteristicController()
        controller.characteristic = characteristicsDic[services![indexPath.section - 1].uuid]![indexPath.row]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: BluetoothDelegate
    func didDisconnectPeripheral(_ peripheral: CBPeripheral) {
        print("PeripheralController --> didDisconnectPeripheral")
        connectFlagLbl.text = "Disconnected. Data is Stale."
        connectFlagLbl.textColor = UIColor.red
        
    }
    
    func didDiscoverCharacteritics(_ service: CBService) {
        print("Service.characteristics:\(service.characteristics?.description ?? "Unknow Characteristics")")
        characteristicsDic[service.uuid] = service.characteristics
        reloadTableView()
    }
    
}
