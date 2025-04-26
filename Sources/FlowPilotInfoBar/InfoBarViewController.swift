//
//  InfoBarViewController.swift
//
//
//  Created by Lukáš Valenta on 22.06.2023.
//

import Foundation
import CleevioCore
#if canImport(UIKit)
import CleevioUI
import UIKit
import SwiftUI
import Combine

/// A view controller that manages the display and animation of an info bar
/// The info bar is presented as an overlay with animations for showing and dismissing
public final class InfoBarViewController<InfoBarView: View, InfoBarContent>: UIViewController {
    /// The hosting controller that wraps the SwiftUI info bar view
    let infoBarViewController: ClearBackgroundUIHostingController<InfoBarView>
    
    /// The frame in which the info bar will be displayed
    let frame: CGRect
    
    /// Closure that gets called when the info bar is dismissed
    var onDismiss: (() -> Void)?
    
    /// The view model that controls the info bar's state and behavior
    private let viewModel: InfoBarViewModel<InfoBarContent>
    
    /// The constraints that control the position of the info bar (for animations)
    private var positionConstraints: [NSLayoutConstraint] = []

    public override var prefersStatusBarHidden: Bool {
        viewModel.prefersStatusBarHidden
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        viewModel.preferredStatusBarStyle
    }

    /// Initializes a new info bar view controller
    /// - Parameters:
    ///   - view: The SwiftUI view to display in the info bar
    ///   - frame: The frame in which to display the info bar
    ///   - viewModel: The view model that controls the info bar's state
    /// 
    /// Example:
    /// ```swift
    /// let infoBarVC = InfoBarViewController(
    ///     view: InfoBarView(viewModel: viewModel) { AlertView() },
    ///     frame: window.frame,
    ///     viewModel: viewModel
    /// )
    /// ```
    public init(
        view: InfoBarView,
        frame: CGRect,
        viewModel: InfoBarViewModel<InfoBarContent>
    ) {
        self.frame = frame
        self.viewModel = viewModel
        self.infoBarViewController = .init(rootView: view)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        self.view = PassThroughView(frame: frame)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 16.0, *) {
            infoBarViewController.sizingOptions = .intrinsicContentSize
        }

        addChild(infoBarViewController)
        view.addSubview(infoBarViewController.view)

        infoBarViewController.view.translatesAutoresizingMaskIntoConstraints = false
        let constraints = viewModel.constraints(infoView: infoBarViewController.view, on: view, frame: frame)
        positionConstraints = constraints.positionConstraints

        NSLayoutConstraint.activate(
            constraints.positionConstraints + constraints.otherConstraints
        )
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.async {
            self.showAlertView()
        }
    }

    /// Shows the info bar with an animation
    /// 
    /// The animation respects accessibility settings for reduced motion
    public func showAlertView() {
        viewModel.updateConstraintsToShow(positionConstraints)

        if UIAccessibility.isReduceMotionEnabled {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            viewModel.isMessageShown = true
        } else {
            UIView.animate(
                withDuration: 1/3,
                delay: 0,
                options: .curveEaseOut
            ) {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(333)) {
                self.viewModel.isMessageShown = true
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }

    /// Dismisses the info bar with an animation
    /// 
    /// The animation respects accessibility settings for reduced motion
    /// Calls the `onDismiss` closure when the animation completes
    public func dismissView() {
        viewModel.updateConstraintsToHide(positionConstraints, frame: frame)
        
        if UIAccessibility.isReduceMotionEnabled {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.onDismiss?()
        } else {
            UIView.animate(
                withDuration: 1/3,
                delay: 0,
                options: .curveEaseIn
            ) {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            } completion: { _ in
                self.onDismiss?()
            }
        }
    }
}
#endif
