//
//  InfoBarWindowRouter.swift
//
//
//  Created by Lukáš Valenta on 22.06.2023.
//

import Foundation
import FlowPilot
import CleevioUI

#if canImport(UIKit)
import UIKit

open class InfoBarWindowRouter: WindowRouter {
    public init(windowScene: UIWindowScene) {
        let window = PassThroughWindow(windowScene: windowScene)

        window.backgroundColor = .clear
        window.windowLevel = UIWindow.Level.alert
        window.isHidden = false
        
        super.init(window: window)
    }

    override open func dismissRouter(animated: Bool, completion: (() -> Void)?) {
        super.dismissRouter(animated: animated, completion: { [window] in
            window?.isHidden = true
            window?.resignKey()
            completion?()
        })
    }
}
#endif
