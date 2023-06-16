//
//  Copyright © 2019 Emarsys. All rights reserved.
//

import UIKit
import EmarsysSDK
import EmarsysInbox

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Emarsys.setContact(contactFieldId: 100009769, contactFieldValue: "B8mau1nMO8PilvTp6P") // demoapp@emarsys.com
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        navigationController?.pushViewController(EmarsysInboxController.new(), animated: true)
//        Emarsys.messageInbox.fetchMessages { [weak self] (result, error) in
//            self?.navigationController?.pushViewController(
//                EmarsysInboxDetailController.new(messages: result?.messages), animated: true)
//        }
//        present(EmarsysInboxController.new(), animated: true, completion: nil)
    }
    
}
