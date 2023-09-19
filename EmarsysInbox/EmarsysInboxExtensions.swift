//
//  Copyright © 2020 Emarsys. All rights reserved.
//

import UIKit

extension UIColor {
    static func color(fromHexCode hex: UInt64) -> UIColor {
        let r = ((CGFloat)((hex & 0xFF000000) >> 24)) / 255.0
        let g = ((CGFloat)((hex & 0x00FF0000) >> 16)) / 255.0
        let b = ((CGFloat)((hex & 0x0000FF00) >> 8)) / 255.0
        let a = ((CGFloat)((hex & 0x000000FF) >> 0)) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

extension DateFormatter {
    static let yyyyMMddHHmm: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm"
        return df
    }()

    static let HHmmddMMMyyyy: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm - dd MMM yyyy"
        df.locale = Locale.current
        return df
    }()
}

extension String {
    struct SegueId {
        static let ListToDetail = "ListToDetail"
    }
}

extension UITableView {
    func setEmptyView(title: String, message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = .black
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.textAlignment = .center
        
        messageLabel.textColor = .black
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        messageLabel.textAlignment = .center
        
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        
        titleLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        messageLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        
        titleLabel.text = title
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        self.backgroundView = emptyView
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
