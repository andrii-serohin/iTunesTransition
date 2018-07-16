//
//  PlayerTabBarController.swift
//  iTunesTransition
//
//  Created by Andrew Seregin on 21.06.2018.
//  Copyright © 2018 Andrew Seregin. All rights reserved.
//

import UIKit

class PlayerTabBarViewController: AdditionalViewTabBarController {
    
    var player = PlayerView()
    
    override var additionalView: UIView {
        return player
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var flexibleViewController: FlexibleViewController {
        return TrackDetailsViewController()
    }
}


