

import UIKit

class LogViewController : UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var logLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var topView: UIView!
    
    var titleName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initAll()
    }
    
    private func initAll() {
        titleLabel.text = titleName
        if titleName == "Log" {
            mainScrollView.isHidden = false
            imageView.isHidden = true
            logLabel.text = LogStore.getAllLogs().joined(separator: "\n")
        } else {
            mainScrollView.isHidden = true
            imageView.isHidden = false
            logLabel.isHidden = true
        }
        self.topView.layer.cornerRadius = 16
        self.topView.layer.maskedCorners = [.layerMinXMaxYCorner,.layerMaxXMaxYCorner]
    }
}
