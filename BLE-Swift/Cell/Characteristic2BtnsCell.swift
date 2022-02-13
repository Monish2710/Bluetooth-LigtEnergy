

import UIKit



open class Characteristic2BtnsCell: UITableViewCell {
    
    
    @IBOutlet var leftBtn: UIButton!
    @IBOutlet var rightBtn: UIButton!
    
    fileprivate var leftAction: (() -> ())?
    fileprivate var rightAction: (() -> ())?
    

    override open func awakeFromNib() {
        super.awakeFromNib()
        leftBtn.addTarget(self, action: #selector(self.leftBtnClick(_:)), for: .touchUpInside)
        rightBtn.addTarget(self, action: #selector(self.rightBtnClick(_:)), for: .touchUpInside)
    }
    
    open func enableBtns() {
        leftBtn.isEnabled = true
        rightBtn.isEnabled = true
    }
    
    open func disableBtns() {
        leftBtn.isEnabled = false
        rightBtn.isEnabled = false
    }
    
    open func setLeftAction(_ action: @escaping (() -> ())) {
        self.leftAction = action
    }
    
    open func setRightAction(_ action: @escaping () -> ()) {
        self.rightAction = action
    }
    
    @objc func leftBtnClick(_ sender: AnyObject?) {
        if let action = leftAction {
            action()
        }
    }
    
    @objc func rightBtnClick(_ sender: AnyObject?) {
        if let action = rightAction {
            action()
        }
    }
    
}
