//
//  Copyright © 2019 Emarsys. All rights reserved.
//

import UIKit
import EmarsysSDK

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        Emarsys.setContactWithContactFieldValue("biancalui")
    }
    
    @IBAction func buttonClick(_: UIButton) {
        navigationController?.pushViewController(EmarsysInboxController.new(), animated: true)
//        present(EmarsysInboxController.get(), animated: true, completion: nil)
    }
    
}
