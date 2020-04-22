//
//  NavigationController.swift
//  SigeChatApp
//
//  Created by 山口瑞歩 on 2019/11/13.
//  Copyright © 2019 山口瑞歩. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isTranslucent = false
        navigationBar.titleTextAttributes = [.font: UIFont.init(name: "AppleSDGothicNeo-Light", size: 25) as Any]
    }

}
