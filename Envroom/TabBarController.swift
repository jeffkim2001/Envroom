//
//  TabBarController.swift
//  Envroom
//
//  Created by Jeff Kim on 3/25/18.
//  Copyright © 2018 Jeff Kim. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let attributes = [NSAttributedStringKey.font : UIFont(name: "Helvetica-Light", size: 20)!, NSAttributedStringKey.foregroundColor : UIColor.white]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.classForCoder() as! UIAppearanceContainer.Type]).setTitleTextAttributes(attributes, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
