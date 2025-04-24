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
    func alertWindowRouter(calculatedPositionContraintConstant: CalculatePaddingClosure) throws -> (InfoBarWindowRouter, frame: CGRect, topPadding: CGFloat) {
        guard let windowScene else {
            throw AlertWindowRouterCouldNotBeConstructed()
        }

        return try (InfoBarWindowRouter(windowScene: windowScene), frame: self.frame, topPadding: calculatedPositionContraintConstant(self))
    }
}
#endif
