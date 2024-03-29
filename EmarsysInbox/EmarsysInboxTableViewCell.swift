//
//  Copyright © 2020 Emarsys. All rights reserved.
//

import UIKit

class EmarsysInboxTableViewCell: UITableViewCell {
    
    static let id = "EmarsysInboxTableViewCell"
    
    @IBOutlet weak var notOpenedView: UIView!
    @IBOutlet weak var favImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var highPriorityImageView: UIImageView!
    
    var imageUrl: String?
    
    override func awakeFromNib() {
        iconImageView.layer.cornerRadius = 15
        iconImageView.backgroundColor = EmarsysInboxConfig.iconImageBackgroundColor
    }
    
}
