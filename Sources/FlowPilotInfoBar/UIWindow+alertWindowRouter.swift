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

/// Error thrown when an alert window router could not be constructed
struct AlertWindowRouterCouldNotBeConstructed: Error { }

extension UIWindow {
    /// Creates a window router for displaying info bars
    /// - Parameter calculatedPositionConstraintConstant: A closure that calculates the position constraint constant
    /// - Returns: A tuple containing the router, the frame, and the top padding
    /// - Throws: `AlertWindowRouterCouldNotBeConstructed` if the window scene is not available
    /// 
    /// Example:
    /// ```swift
    /// let (router, frame, topPadding) = try window.alertWindowRouter { window in
    ///     return window.safeAreaInsets.top + 8
    /// }
    /// ```
    func alertWindowRouter(calculatedPositionConstraintConstant: (UIWindow) throws -> CGFloat) throws -> (InfoBarWindowRouter, frame: CGRect, topPadding: CGFloat) {
        guard let windowScene else {
            throw AlertWindowRouterCouldNotBeConstructed()
        }

        return try (InfoBarWindowRouter(windowScene: windowScene), frame: self.frame, topPadding: calculatedPositionConstraintConstant(self))
    }
}
#endif
