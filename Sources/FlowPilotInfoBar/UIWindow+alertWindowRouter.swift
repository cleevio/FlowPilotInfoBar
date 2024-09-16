//
//  UIWindow+alertWindowRouter.swift
//
//
//  Created by Lukáš Valenta on 22.06.2023.
//

import Foundation
import CleevioUI

#if canImport(UIKit)
import UIKit
extension UIWindow {
    func alertWindowRouter() -> (InfoBarWindowRouter, frame: CGRect, topPadding: CGFloat)? {
        guard let topViewController = topViewController,
              let windowScene = windowScene,
              let frame = windowScene.statusBarManager?.statusBarFrame
        else {            
            return nil
        }

        var topPadding: CGFloat {
            if let viewController = topViewController.navigationController, !viewController.isNavigationBarHidden {
                return viewController.navigationBar.frame.origin.y + viewController.navigationBar.frame.height
            } else {
                return frame.height
            }
        }

        return (InfoBarWindowRouter(windowScene: windowScene), frame: frame, topPadding: topPadding)
    }
}
#endif
