//
//  Copyright © 2019 Emarsys. All rights reserved.
//

import UIKit

class EmarsysInboxDefaultHeaderView: UIView {
    
    var titleColor: UIColor?

    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
    init(backgroudColor: UIColor?, titleColor: UIColor?) {
        super.init(frame: CGRectMake(0, 0, UIScreen.main.bounds.width, 50))
        self.backgroundColor = backgroudColor
        self.titleColor = titleColor
        sharedInit()
    }
    
    private func sharedInit() {
        let titleLabel = UILabel()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = titleColor
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
        titleLabel.textAlignment = .center
        
        titleLabel.text = "Inbox"

        self.addSubview(titleLabel)
        
        titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
    }
}
