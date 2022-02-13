

import UIKit

class RootController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupTabbar()
    }
    private func setupTabbar() {
        let Peripherals = self.storyboard?.instantiateViewController(withIdentifier: "MainController") as! MainController
        Peripherals.tabBarItem = UITabBarItem(title: "Peripherals", image: #imageLiteral(resourceName: "Peripherals"), tag: 0)
        let Virtual = LogViewController(nibName: "LogViewController", bundle: nil)
        Virtual.tabBarItem = UITabBarItem(title: "Virtual Devices", image: #imageLiteral(resourceName: "Virtual Devices"), tag: 0)
        Virtual.titleName = "Virtual Devices"
        let Log = LogViewController(nibName: "LogViewController", bundle: nil)
        Log.titleName = "Log"
        Log.tabBarItem = UITabBarItem(title: "Log", image: #imageLiteral(resourceName: "Log"), tag: 0)
        let More = LogViewController(nibName: "LogViewController", bundle: nil)
        More.titleName = "More"
        More.tabBarItem = UITabBarItem(title: "More", image: #imageLiteral(resourceName: "More"), tag: 0)
        let tabBarController = CBFlashyTabBarController()
        tabBarController.viewControllers = [Peripherals, Virtual, Log, More]
        navigationController?.pushViewController(tabBarController, animated: true)
    }
    
}
