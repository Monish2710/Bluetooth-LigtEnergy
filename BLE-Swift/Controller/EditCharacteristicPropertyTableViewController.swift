

import UIKit

class EditCharacteristicPropertyTableViewController: UITableViewController {

    let propertyCellReuseIdentifier = "PropertyCell"
    public var selectedProperties: VirtualPeripheral.Service.Characteristic.Properties!
    public var callback: ((VirtualPeripheral.Service.Characteristic.Properties) -> Void)?
    var allProperties: [VirtualPeripheral.Service.Characteristic.Properties] = [.read, .writeWithoutResponse, .write, .notify, .indicate, .authenticatedSignedWrites, .extendedProperties, .notifyEncryptionRequired, .indicateEncryptionRequired]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAll()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let callback = self.callback {
            callback(selectedProperties)
        }
    }
    
    func initAll() {
        self.title = "Characteristic Properties"
        self.toolbarItems = self.navigationController?.toolbar.items
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: propertyCellReuseIdentifier)
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allProperties.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: propertyCellReuseIdentifier, for: indexPath)
        let property = allProperties[indexPath.row]
        cell.textLabel?.text = property.names.joined(separator: " ")
        
        if selectedProperties.contains(property) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let property = allProperties[indexPath.row]
        if selectedProperties.contains(property) {
            selectedProperties.subtract(property)
        } else {
            selectedProperties.formUnion(property)
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }

}
