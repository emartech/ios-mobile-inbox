//
//  Copyright © 2020 Emarsys. All rights reserved.
//

import UIKit

class EmarsysInboxDetailCollectionViewCell: UICollectionViewCell {
    
    static let id = "EmarsysInboxDetailCollectionViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var actionButtonView: UIStackView!
    @IBOutlet weak var actionButtonViewHeight: NSLayoutConstraint!
    
    var imageUrl: String?
    
}
