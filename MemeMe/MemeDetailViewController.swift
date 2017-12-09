//
//  MemeDetailViewController.swift
//  MemeMe
//
//  Created by Wu, Qifan | Keihan | ECID on 2017/12/09.
//

import UIKit

class MemeDetailViewController: UIViewController {
    
    @IBOutlet weak var image: UIImageView!
    
    var index: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let index = index {
            image.image = AppDelegate.shared.memes[index].memedImage
        }
    }
    
}
