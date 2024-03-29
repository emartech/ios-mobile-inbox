//
//  Copyright © 2020 Emarsys. All rights reserved.
//

import UIKit
import EmarsysSDK

open class EmarsysInboxDetailController: UIViewController {
    
    public static func new(initialIndexPath: IndexPath? = nil, messages: [EMSMessage]? = nil) -> EmarsysInboxDetailController {
        let controller = UIStoryboard.init(name: "EmarsysInbox", bundle: Bundle(for: EmarsysInboxDetailController.self))
            .instantiateViewController(withIdentifier: "EmarsysInboxDetailController") as! EmarsysInboxDetailController
        controller.initialIndexPath = initialIndexPath
        controller.messages = messages
        return controller
    }
    
    @IBOutlet public weak var collectionView: UICollectionView!
    
    public var initialized = false
    public var initialIndexPath: IndexPath?
    public var messages: [EMSMessage]?
    public var actionButtons: [String: [EmarsysInboxActionButton]] = [:]
    
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
        cell.bodyLabel.textColor = EmarsysInboxConfig.bodyForegroundColor
        cell.datetimeLabel.textColor = EmarsysInboxConfig.bodyForegroundColor
        
        cell.actionButtonView.subviews.forEach { $0.removeFromSuperview() }
        cell.actionButtonViewHeight.isActive = true
        cell.imageView.image = nil
        cell.imageUrl = nil
        
        guard indexPath.row < messages?.count ?? 0, let message = messages?[indexPath.row] else { return cell }
        
        cell.titleLabel.text = message.title
        cell.bodyLabel.text = message.body
        cell.datetimeLabel.text = DateFormatter.HHmmddMMMyyyy.string(
            from: Date(timeIntervalSince1970: TimeInterval(truncating: message.receivedAt)))
        
        if let actions = message.actions, !actions.isEmpty {
            if actionButtons[message.id] == nil {
                actionButtons[message.id] = actions.map { createActionButton(for: $0) }
            }
            actionButtons[message.id]?.forEach {
                cell.actionButtonView.addArrangedSubview($0)
            }
            cell.actionButtonViewHeight.isActive = false
        }
        
        guard let imageUrl = message.imageUrl, let url = URL(string: imageUrl) else {
            cell.imageView.image = EmarsysInboxConfig.defaultImage
            cell.imageView.contentMode = .scaleAspectFit
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
                cell.imageView.contentMode = .scaleAspectFill
            }
        }.resume()
        
        return cell
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
}

extension EmarsysInboxDetailController {
    
    @objc open func createActionButton(for action: EMSActionModelProtocol) -> EmarsysInboxActionButton {
        let button = EmarsysInboxActionButton()
        button.action = action
        button.addTarget(self, action: #selector(actionButtonClicked), for: .touchUpInside)
        button.setTitle(action.title(), for: .normal)
        button.setTitleColor(EmarsysInboxConfig.bodyTintColor, for: .normal)
        if let actionButtonStyler = EmarsysInboxConfig.actionButtonStyler {
            actionButtonStyler(button)
        }
        return button
    }
    
    @objc open func actionButtonClicked(sender: EmarsysInboxActionButton) {
        guard let action = sender.action else { return }
        switch action.type() {
        case "MEAppEvent":
            guard let a = action as? EMSAppEventActionModel,
                  let actionEventHandler = EmarsysInboxConfig.actionEventHandler else { return }
            actionEventHandler(a.name, a.payload)
        case "OpenExternalUrl":
            guard let a = action as? EMSOpenExternalUrlActionModel else { return }
            UIApplication.shared.open(a.url)
        default:
            break
        }
    }
    
}
