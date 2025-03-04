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

struct AlertWindowRouterCouldNotBeConstructed: Error { }

extension UIWindow {
    func alertWindowRouter(topPadding: CalculatePaddingClosure) throws -> (InfoBarWindowRouter, frame: CGRect, topPadding: CGFloat) {
        guard let windowScene else {
            throw AlertWindowRouterCouldNotBeConstructed()
        }

        return try (InfoBarWindowRouter(windowScene: windowScene), frame: self.frame, topPadding: topPadding(self))
    }
}
#endif
