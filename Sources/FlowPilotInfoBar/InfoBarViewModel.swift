//
//  InfoBarViewModel.swift
//
//
//  Created by Lukáš Valenta on 22.06.2023.
//

import Foundation
import Combine

#if canImport(UIKit)
import UIKit

/// A struct representing layout constraint anchors needed for positioning the info bar
public struct ConstraintAnchors {
    /// The primary constraint that controls the position (showing/hiding) of the info bar
    var positionConstraint: NSLayoutConstraint
    
    /// Additional constraints for proper layout of the info bar
    var otherConstraints: [NSLayoutConstraint]

    public init(positionConstraint: NSLayoutConstraint, otherConstraints: [NSLayoutConstraint]) {
        self.positionConstraint = positionConstraint
        self.otherConstraints = otherConstraints
    }
}

@MainActor
/// A view model that handles the logic and state for the info bar component
/// 
/// Example:
/// ```swift
/// let viewModel = InfoBarViewModel(
///     content: "Alert message",
///     hideAfter: 3
/// )
/// ```
open class InfoBarViewModel<InfoBarContent>: ObservableObject {
    /// The content to be displayed in the info bar
    public let content: InfoBarContent
    
    /// Constant value for position constraint, used for adjusting based on navigation bar
    var positionConstrainConstant: CGFloat = 0
    
    /// Published property indicating whether the info bar message is currently shown
    @Published public var isMessageShown = false

    /// Initializes a new info bar view model
    /// - Parameters:
    ///   - content: The content to display in the info bar
    ///   - seconds: Time in seconds after which the info bar will automatically dismiss
    public init(
        content: InfoBarContent,
        hideAfter seconds: TimeInterval = 2
    ) {
        self.content = content

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(seconds))) {
            self.isMessageShown = false
        }
    }

    /// Calculates the appropriate position constraint constant based on navigation bar presence
    /// - Parameter window: The window containing the view controller hierarchy
    /// - Returns: The calculated position constraint constant in points
    open func calculatedPositionContraintConstant(window: UIWindow) -> CGFloat {
        let navigationController: UINavigationController? = window.topViewController?.navigationController ?? window.topViewController?.tabBarController.flatMap { $0.selectedViewController as? UINavigationController }

        if let navigationController, !navigationController.isNavigationBarHidden {
            return navigationController.navigationBar.frame.height + 8
        }

        return 8
    }

    /// Calculates the position constraint constant for when the info bar is not visible
    /// - Parameter frame: The frame of the info bar
    /// - Returns: The constraint constant value to position the info bar off-screen
    open func notVisiblePositionConstraintConstant(from frame: CGRect) -> CGFloat {
        -frame.height
    }

    /// Creates the constraint anchors needed for positioning the info bar
    /// - Parameters:
    ///   - infoView: The info bar view to be constrained
    ///   - view: The parent view to constrain against
    ///   - frame: The frame of the window
    /// - Returns: A `ConstraintAnchors` object containing all necessary constraints
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
#endif
