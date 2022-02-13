

import UIKit
import CoreBluetooth

class NewVirtualPeripheralController : UITableViewController {
    
    fileprivate let cellReuseIdentifier = "VirtualPeripheralCell"
    fileprivate var saveBarButtonItem: UIBarButtonItem?
    fileprivate let peripherals: [VirtualPeripheral] = [.blankPeripheral, .alertNotificationPeripheral, .bloodPressurePeripheral, .cyclingPowerPeripheral, .cyclingSpeedAndCadencePeripheral, .findMePeripheral, .glucosePeripheral, .HIDOVERGATTPeripheral, .healthThermometerPeripheral, .heartRatePeripheral, .locationAndNavigationPeripheral, .phoneAlertStatusPeripheral, .polarHRSensorPeripheral, .proximityPeripheral, .runningSpeedAndCadencePeripheral, .scanParametersPeripheral, .temperatureAlarmServicePeripheral, .timePeripheral]
    fileprivate var selectedIndex: Int? {
        didSet {
            self.saveBarButtonItem?.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initAll()
    }
    
    // MARK: Custom functions
    func initAll() {
        // init prompt without animation and let the navigationBar do not overlap with uitableview
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        self.navigationItem.prompt = "Choose A Base Profile"
        self.title = "New Virtual Peripheral"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick(_:)))
        saveBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveClick(_:)))
        navigationItem.rightBarButtonItem = saveBarButtonItem
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        saveBarButtonItem = navigationItem.rightBarButtonItem
        saveBarButtonItem?.isEnabled = false
    }
    
    // MARK: Callback functions
    @objc func cancelClick(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
        
    @objc func saveClick(_ sender: Any) {
        guard let selectedIndex = selectedIndex else {
            return;
        }
        VirtualPeripheralStore.shared.add(virtualPeripheral: peripherals[selectedIndex])
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Delegate
    // MARK: UITableViewDelegate & UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        
        cell.textLabel?.text = peripherals[indexPath.row].name
        
        if selectedIndex == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
}
