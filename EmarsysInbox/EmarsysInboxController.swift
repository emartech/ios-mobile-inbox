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
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet public weak var tableView: UITableView!
    var refreshControl = UIRefreshControl()
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    public var messages: [EMSMessage]?
    var isFetchingMessages = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.addSubview(EmarsysInboxConfig.headerView ?? EmarsysInboxDefaultHeaderView(backgroudColor: EmarsysInboxConfig.headerBackgroundColor, titleColor: EmarsysInboxConfig.headerForegroundColor))
        tableView.backgroundColor = EmarsysInboxConfig.bodyBackgroundColor
        refreshControl.tintColor = EmarsysInboxConfig.activityIndicatorColor?.withAlphaComponent(0.5)
        activityIndicatorView.color = EmarsysInboxConfig.activityIndicatorColor
        
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(fetchMessages), for: .valueChanged)
    }
    
    @objc func fetchMessages() {
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
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMessages()
        tableView.reloadData()
    }
}

extension EmarsysInboxController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if messages?.count == 0 {
            tableView.setEmptyView(title: "You don't have any message.", message: "Your messages will be displayed here.")
        } else {
            tableView.restore()
        }
        return messages?.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row < messages?.count ?? 0, let message = messages?[indexPath.row],
            !(message.tags?.contains(EmarsysInboxTag.seen) ?? false) else { return }
        message.tags?.append(EmarsysInboxTag.seen)
        Emarsys.messageInbox.addTag(tag: EmarsysInboxTag.seen, messageId: message.id)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: EmarsysInboxTableViewCell.id, for: indexPath) as! EmarsysInboxTableViewCell
        
        if cell.favImageView?.gestureRecognizers?.isEmpty ?? true {
            cell.favImageView?.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(favImageViewClicked)))
        }
        
        cell.titleLabel.textColor = EmarsysInboxConfig.bodyForegroundColor
        cell.bodyLabel.textColor = EmarsysInboxConfig.bodyForegroundColor
        cell.favView.backgroundColor = EmarsysInboxConfig.notOpenedViewColor
        
        cell.messageImageView.image = nil
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
        
        guard let imageUrl = message.imageUrl, let url = URL(string: imageUrl) else {
            cell.messageImageView.image = EmarsysInboxConfig.defaultImage
            return cell
        }
        cell.imageUrl = imageUrl
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200, error == nil,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async() {
                guard cell.imageUrl == imageUrl else { return }
                cell.messageImageView.image = image
            }
        }.resume()
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    
    @objc func favImageViewClicked(_ sender: UIGestureRecognizer) {
        guard let cell = sender.view?.superview?.superview as? EmarsysInboxTableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            indexPath.row < messages?.count ?? 0, let message = messages?[indexPath.row] else { return }
        if let pinnedIndex = message.tags?.firstIndex(of: EmarsysInboxTag.pinned) {
            message.tags?.remove(at: pinnedIndex)
            Emarsys.messageInbox.removeTag(tag: EmarsysInboxTag.pinned, messageId: message.id)
        } else {
            message.tags?.append(EmarsysInboxTag.pinned)
            Emarsys.messageInbox.addTag(tag: EmarsysInboxTag.pinned, messageId: message.id)
        }
        tableView.reloadData()
    }
    
}
