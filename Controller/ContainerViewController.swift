//
//  ContrainerViewController.swift
//  TransitAlarm
//
//  Created by id on 5/12/16.
//  Copyright © 2016 id. All rights reserved.
//

import UIKit
import QuartzCore

@objc
protocol CenterViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func toggleRightPanel()
    optional func collapseSidePanels()
}


class ContainerViewController: UIViewController {

    var centerNavigationController: UINavigationController!
    var centerViewController: CenterViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        centerViewController = UIStoryboard.centerViewController()
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        centerViewController.centerViewControllerDelegate = self
        centerNavigationController.didMoveToParentViewController(self)
    }
}


private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    }

    class func leftViewController() -> SearchViewController {
        let identifier = viewControllerIdentifiers.Search.identifier()
        return mainStoryboard().instantiateViewControllerWithIdentifier(identifier) as! SearchViewController
    }

    class func centerViewController() -> CenterViewController {
        let identifier = viewControllerIdentifiers.Center.identifier()
        return mainStoryboard().instantiateViewControllerWithIdentifier(identifier) as! CenterViewController
    }
}

extension ContainerViewController: CenterViewControllerDelegate {
    func toggleLeftPanel() { }
    func toggleRightPanel() { }
    func addLeftPanelViewController() {}
    func addRightPanelViewContoller() {}
    func animateLeftPanel(shouldExpand: Bool) {}
    func animateRightPanel(shouldExpand: Bool) {}
}