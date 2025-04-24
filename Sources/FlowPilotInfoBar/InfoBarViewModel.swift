//
//  InfoBarViewModel.swift
//
//
//  Created by Lukáš Valenta on 22.06.2023.
//

import Foundation
import Combine
import UIKit

public struct ConstraintAnchors {
    var positionConstraint: NSLayoutConstraint
    var otherConstraints: [NSLayoutConstraint]
}

@MainActor
open class InfoBarViewModel<InfoBarContent>: ObservableObject {
    public let content: InfoBarContent
    var positionConstrainConstant: CGFloat = 0
    @Published public var isMessageShown = false

    public init(
        content: InfoBarContent,
        hideAfter seconds: TimeInterval = 2
    ) {
        self.content = content

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(seconds))) {
            self.isMessageShown = false
        }
    }

    open func calculatedPositionContraintConstant(window: UIWindow) -> CGFloat {
        let navigationController: UINavigationController? = window.topViewController?.navigationController ?? window.topViewController?.tabBarController.flatMap { $0.selectedViewController as? UINavigationController }

        if let navigationController, !navigationController.isNavigationBarHidden {
            return navigationController.navigationBar.frame.height + 8
        }

        return 8
    }

    open func notVisiblePositionConstraintConstant(from frame: CGRect) -> CGFloat {
        -frame.height
    }

    open func constraints(infoView: UIView, on view: UIView, frame: CGRect) -> ConstraintAnchors {
        .init(
            positionConstraint: infoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: notVisiblePositionConstraintConstant(from: frame)),
            otherConstraints: [
                infoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                infoView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                infoView.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor, constant: -positionConstrainConstant)
            ]
        )
    }
}
