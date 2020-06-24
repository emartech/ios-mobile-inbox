//
//  EmarsysInboxDetailCollectionViewCell.swift
//  InboxSample
//
//  Created by Bianca Lui on 23/6/2020.
//  Copyright © 2020 Emarsys. All rights reserved.
//

import UIKit

class EmarsysInboxDetailCollectionViewCell: UICollectionViewCell {
    
    static let id = "EmarsysInboxDetailCollectionViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var datetimeLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var imageUrl: String?
    
}
