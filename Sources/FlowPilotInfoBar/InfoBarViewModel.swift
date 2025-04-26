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
    /// The primary constraints that control the position (showing/hiding) of the info bar
    /// Default implementation uses a single constraint, but can be extended for more complex layouts
    var positionConstraints: [NSLayoutConstraint]
    
    /// Additional constraints for proper layout of the info bar
    var otherConstraints: [NSLayoutConstraint]

    /// Initializes a new constraint anchors object
    /// - Parameters:
    ///   - positionConstraints: The constraints controlling the info bar position
    ///   - otherConstraints: Additional constraints for proper layout
    public init(positionConstraints: [NSLayoutConstraint], otherConstraints: [NSLayoutConstraint]) {
        self.positionConstraints = positionConstraints
        self.otherConstraints = otherConstraints
    }
    
    /// Convenience initializer for backward compatibility with a single position constraint
    /// - Parameters:
    ///   - positionConstraint: The primary constraint controlling the info bar position
    ///   - otherConstraints: Additional constraints for proper layout
    public init(positionConstraint: NSLayoutConstraint, otherConstraints: [NSLayoutConstraint]) {
        self.positionConstraints = [positionConstraint]
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
    
    /// Constant value for position constraints, used for positioning the info bar relative to navigation bars or other UI elements
    /// This value is typically set automatically by the coordinator during initialization
    public var positionConstraintConstant: CGFloat = 0
    
    /// Published property indicating whether the info bar message is currently shown
    /// 
    /// This property is observed by the coordinator to trigger the dismissal animation.
    /// It's set to true after the show animation completes and set to false when auto-dismissal
    /// is triggered or when the user manually dismisses the info bar.
    /// When this state changes, the status bar appearance may also need to be updated.
    @Published public var isMessageShown = false

    /// Determines whether the status bar should be hidden
    ///
    /// By default, it inherits this property from the application's root view controller.
    /// This property is used by the info bar view controller to control the status bar visibility
    /// when the info bar is shown, and the status bar appearance is updated after animations.
    open var prefersStatusBarHidden: Bool {
        UIApplication.shared.windows.first?.rootViewController?.prefersStatusBarHidden ?? false
    }

    /// Determines the preferred status bar style
    ///
    /// By default, it inherits this property from the application's root view controller.
    /// This property is used by the info bar view controller to control the status bar style
    /// when the info bar is shown, and the status bar appearance is updated after animations.
    open var preferredStatusBarStyle: UIStatusBarStyle {
        UIApplication.shared.windows.first?.rootViewController?.preferredStatusBarStyle ?? .default
    }

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
    open func calculatedPositionConstraintConstant(window: UIWindow) -> CGFloat {
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
            positionConstraints: [
                infoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: notVisiblePositionConstraintConstant(from: frame))
            ],
            otherConstraints: [
                infoView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
                infoView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
                infoView.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor, constant: -positionConstraintConstant)
            ]
        )
    }
    
    /// Updates position constraints to show the info bar
    /// - Parameter constraints: The position constraints to update
    /// 
    /// When this method is called during presentation, the InfoBarViewController will
    /// also update the status bar appearance using setNeedsStatusBarAppearanceUpdate()
    /// to reflect any changes based on the view controller's status bar preferences.
    open func updateConstraintsToShow(_ constraints: [NSLayoutConstraint]) {
        constraints.forEach { $0.constant = positionConstraintConstant }
    }
    
    /// Updates position constraints to hide the info bar
    /// - Parameters:
    ///   - constraints: The position constraints to update
    ///   - frame: The frame of the window
    /// 
    /// When this method is called during dismissal, the InfoBarViewController will
    /// also update the status bar appearance using setNeedsStatusBarAppearanceUpdate()
    /// to reflect any changes based on the view controller's status bar preferences.
    open func updateConstraintsToHide(_ constraints: [NSLayoutConstraint], frame: CGRect) {
        let notVisibleConstant = notVisiblePositionConstraintConstant(from: frame)
        constraints.forEach { $0.constant = notVisibleConstant }
    }
}
#endif
