//
//  Copyright © 2020 Emarsys. All rights reserved.
//

import UIKit
import EmarsysSDK

open class EmarsysInboxController: UIViewController {
    
    public static func new() -> UIViewController {
        return UIStoryboard.init(name: "EmarsysInbox", bundle: Bundle(for: self))
            .instantiateViewController(withIdentifier: "EmarsysInboxController")
    }
    
    @IBOutlet public weak var headerView: UIView!
    @IBOutlet public weak var tableView: UITableView!
    var refreshControl = UIRefreshControl()
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    public var messages: [EMSMessage]?
    public var isFetchingMessages = false
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.addSubview(EmarsysInboxConfig.headerView ?? EmarsysInboxDefaultHeaderView(backgroudColor: EmarsysInboxConfig.headerBackgroundColor, titleColor: EmarsysInboxConfig.headerForegroundColor))
        tableView.backgroundColor = EmarsysInboxConfig.bodyBackgroundColor
        refreshControl.tintColor = EmarsysInboxConfig.activityIndicatorColor?.withAlphaComponent(0.5)
        activityIndicatorView.color = EmarsysInboxConfig.activityIndicatorColor
        
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(fetchMessages), for: .valueChanged)
    }
    
    @objc public func fetchMessages() {
        guard !isFetchingMessages else { return }
        isFetchingMessages = true
        Emarsys.messageInbox.fetchMessages { [weak self] (result, error) in
            self?.activityIndicatorView.stopAnimating()
            self?.refreshControl.endRefreshing()
            self?.messages = result?.messages.filter({ !($0.tags?.contains(EmarsysInboxTag.deleted) ?? false) })
            self?.isFetchingMessages = false
            self?.tableView.reloadData()
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMessages()
        tableView.reloadData()
    }
}

extension EmarsysInboxController: UITableViewDataSource, UITableViewDelegate {
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages?.count == 0 {
            tableView.setEmptyView(title: "You don't have any message.", message: "Your messages will be displayed here.")
        } else {
            tableView.restore()
        }
        return messages?.count ?? 0
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row < messages?.count ?? 0, let message = messages?[indexPath.row],
            !(message.tags?.contains(EmarsysInboxTag.seen) ?? false) else { return }
        Emarsys.messageInbox.addTag(tag: EmarsysInboxTag.seen, messageId: message.id) { error in
            if error == nil {
                message.tags?.append(EmarsysInboxTag.seen)
            }
        }
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: EmarsysInboxTableViewCell.id, for: indexPath) as! EmarsysInboxTableViewCell
        
        if cell.favImageView?.gestureRecognizers?.isEmpty ?? true {
            cell.favImageView?.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(favImageViewClicked)))
        }
        
        cell.titleLabel.textColor = EmarsysInboxConfig.bodyForegroundColor
        cell.bodyLabel.textColor = EmarsysInboxConfig.bodyForegroundColor
        cell.favView.backgroundColor = EmarsysInboxConfig.notOpenedViewColor
        
        cell.iconImageView.image = nil
        cell.imageUrl = nil
        
        guard indexPath.row < messages?.count ?? 0, let message = messages?[indexPath.row] else { return cell }
        
        cell.highPriorityImageView.tintColor = .red
        cell.favImageView?.image = message.tags?.contains(EmarsysInboxTag.pinned) ?? false ?
            EmarsysInboxConfig.favImageOn : EmarsysInboxConfig.favImageOff
        cell.favImageView?.tintColor = message.tags?.contains(EmarsysInboxTag.pinned) ?? false ?
            EmarsysInboxConfig.bodyHighlightTintColor : EmarsysInboxConfig.bodyTintColor
        cell.favView.isHidden = message.tags?.contains(EmarsysInboxTag.opened) ?? false
        cell.highPriorityImageView.image = EmarsysInboxConfig.highPriorityImage
        cell.highPriorityImageView.isHidden = !(message.tags?.contains(EmarsysInboxTag.high) ?? false)
        
        cell.titleLabel.text = message.title
        cell.bodyLabel.text = message.body
        
        guard let iconUrl = message.properties?["icon"] ?? message.imageUrl, let url = URL(string: iconUrl) else {
            cell.iconImageView.image = EmarsysInboxConfig.defaultImage
            cell.iconImageView.contentMode = .scaleAspectFit
            return cell
        }
        cell.imageUrl = iconUrl
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200, error == nil,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async() {
                guard cell.imageUrl == iconUrl else { return }
                cell.iconImageView.image = image
                cell.iconImageView.contentMode = .scaleAspectFill
            }
        }.resume()
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard indexPath.row < messages?.count ?? 0, let message = messages?[indexPath.row] else { return }
        if editingStyle == .delete {
            Emarsys.messageInbox.addTag(tag: EmarsysInboxTag.deleted, messageId: message.id)
            messages?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
}

extension EmarsysInboxController {
    
    open override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? EmarsysInboxDetailController,
            let tableViewCell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: tableViewCell) {
            destination.initialIndexPath = indexPath
            destination.messages = messages
        }
    }
    
    @objc open func favImageViewClicked(_ sender: UIGestureRecognizer) {
        guard let cell = sender.view?.superview?.superview as? EmarsysInboxTableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            indexPath.row < messages?.count ?? 0, let message = messages?[indexPath.row] else { return }
        if let pinnedIndex = message.tags?.firstIndex(of: EmarsysInboxTag.pinned) {
            Emarsys.messageInbox.removeTag(tag: EmarsysInboxTag.pinned, messageId: message.id) { [weak self] error in
                if error == nil {
                    message.tags?.remove(at: pinnedIndex)
                    self?.tableView.reloadData()
                }
            }
        } else {
            Emarsys.messageInbox.addTag(tag: EmarsysInboxTag.pinned, messageId: message.id) { [weak self] error in
                if error == nil {
                    message.tags?.append(EmarsysInboxTag.pinned)
                    self?.tableView.reloadData()
                }
            }
        }
        tableView.reloadData()
    }
    
}
