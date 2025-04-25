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

/// A window router specifically designed for displaying info bars
/// 
/// Creates a transparent window at the alert level to display info bars
/// over the application content
open class InfoBarWindowRouter: WindowRouter {
    /// Initializes a new info bar window router
    /// - Parameter windowScene: The window scene in which to create the window
    /// 
    /// Example:
    /// ```swift
    /// let windowRouter = InfoBarWindowRouter(windowScene: UIApplication.shared.connectedScenes.first as! UIWindowScene)
    /// ```
    public init(windowScene: UIWindowScene) {
        let window = PassThroughWindow(windowScene: windowScene)

        window.backgroundColor = .clear
        window.windowLevel = UIWindow.Level.alert
        window.isHidden = false
        
        super.init(window: window)
    }

    /// Dismisses the router and hides its window
    /// - Parameters:
    ///   - animated: Whether to animate the dismissal
    ///   - completion: A closure to call when the dismissal is complete
    override open func dismissRouter(animated: Bool, completion: (() -> Void)?) {
        super.dismissRouter(animated: animated, completion: { [window] in
            window?.isHidden = true
            window?.resignKey()
            completion?()
        })
    }
}
#endif
