//
//  Copyright © 2019 Emarsys. All rights reserved.
//

import UIKit
import EmarsysSDK
import EmarsysInbox

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let config = EMSConfig.make { builder in
            builder.setMobileEngageApplicationCode("EMS98-029BE")
        }
        Emarsys.setup(config: config)
        
        EmarsysInboxConfig.actionButtonStyler = { button in
            button.backgroundColor = .white
            button.layer.cornerRadius = 10
        }
        EmarsysInboxConfig.actionEventHandler = { eventName, payload in
            print("eventName: \(eventName), payload: \(payload)")
        }
        
        return true
    }

}

