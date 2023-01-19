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
        
        Emarsys.setContact(contactFieldId: 100010824, contactFieldValue: "biancalui")
    }
    
    @IBAction func buttonClicked(_ sender: UIButton) {
        navigationController?.pushViewController(EmarsysInboxController.new(), animated: true)
//        present(EmarsysInboxController.new(), animated: true, completion: nil)
    }
    
}
