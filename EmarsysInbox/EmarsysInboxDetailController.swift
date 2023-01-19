//
//  Copyright © 2020 Emarsys. All rights reserved.
//

import UIKit
import EmarsysSDK

class EmarsysInboxDetailController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var initialized = false
    var initialIndexPath: IndexPath?
    var messages: [EMSMessage]?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.backgroundColor = EmarsysInboxConfig.bodyBackgroundColor
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        guard !initialized, let ip = initialIndexPath else { return }
        initialized = true
        collectionView.scrollToItem(at: ip, at: .left, animated: false)
    }
    
}

extension EmarsysInboxDetailController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages?.count ?? 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard indexPath.row < messages?.count ?? 0, let message = messages?[indexPath.row],
            !(message.tags?.contains(EmarsysInboxTag.opened) ?? false) else { return }
        Emarsys.messageInbox.addTag(tag: EmarsysInboxTag.opened, messageId: message.id) { error in
            if error == nil {
                message.tags?.append(EmarsysInboxTag.opened)
            }
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmarsysInboxDetailCollectionViewCell.id, for: indexPath) as! EmarsysInboxDetailCollectionViewCell
        
        cell.titleLabel.textColor = EmarsysInboxConfig.bodyForegroundColor
        cell.datetimeLabel.textColor = EmarsysInboxConfig.bodyForegroundColor
        cell.bodyLabel.textColor = EmarsysInboxConfig.bodyForegroundColor
        
        cell.imageView.image = nil
        cell.imageUrl = nil
        
        guard indexPath.row < messages?.count ?? 0, let message = messages?[indexPath.row] else { return cell }
        cell.titleLabel.text = message.title
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:MM - dd MMM YYY"
        dateFormatter.locale = Locale.current
        let date = Date(timeIntervalSince1970: TimeInterval(truncating: message.receivedAt))
        let formattedDate = dateFormatter.string(from: date)
        
        cell.datetimeLabel.text = formattedDate
        cell.bodyLabel.text = message.body
        
        guard let imageUrl = message.imageUrl, let url = URL(string: imageUrl) else {
            cell.imageView.image = EmarsysInboxConfig.defaultImage
            return cell
        }
        cell.imageUrl = imageUrl
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200, error == nil,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async() {
                guard cell.imageUrl == imageUrl else { return }
                cell.imageView.image = image
            }
        }.resume()
        
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width , height: view.frame.height - (view.safeAreaInsets.top + view.safeAreaInsets.bottom))
    }
    
}
