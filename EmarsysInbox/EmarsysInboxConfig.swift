//
//  Copyright © 2020 Emarsys. All rights reserved.
//

import UIKit
import EmarsysSDK

public class EmarsysInboxConfig {
    
    public static var headerView: UIView?
    public static var headerBackgroundColor: UIColor? = .color(fromHexCode: 0x5F9F9FFF)
    public static var headerForegroundColor: UIColor? = .white
    public static var bodyBackgroundColor: UIColor? = .color(fromHexCode: 0xD1EEEEFF)
    public static var bodyForegroundColor: UIColor? = .black
    public static var bodyTintColor: UIColor? = .systemBlue
    public static var bodyHighlightTintColor: UIColor? = .color(fromHexCode: 0xFFD700FF)
    public static var activityIndicatorColor: UIColor? = .darkGray
    public static var notOpenedViewColor: UIColor? = .color(fromHexCode: 0x5F9F9FFF)
    public static var favImageOff: UIImage? = UIImage(named: "star", in: Bundle(for: EmarsysInboxConfig.self), compatibleWith: nil)
    public static var favImageOn: UIImage? = UIImage(named: "starfill", in: Bundle(for: EmarsysInboxConfig.self), compatibleWith: nil)
    public static var iconImageBackgroundColor: UIColor? = .white
    public static var defaultImage: UIImage? = UIImage(named: "logo", in: Bundle(for: EmarsysInboxConfig.self), compatibleWith: nil)
    public static var highPriorityImage: UIImage? = UIImage(named: "exclamationmark", in: Bundle(for: EmarsysInboxConfig.self), compatibleWith: nil)
    public static var actionButtonStyler: ((UIButton) -> Void)?
    public static var actionEventHandler: EMSEventHandlerBlock?
    
}
