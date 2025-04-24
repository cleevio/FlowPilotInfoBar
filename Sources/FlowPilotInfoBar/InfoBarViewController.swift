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

public final class InfoBarViewController<InfoBarView: View, InfoBarContent>: UIViewController {
    let infoBarViewController: ClearBackgroundUIHostingController<InfoBarView>
    let frame: CGRect
    var onDismiss: (() -> Void)?
    private let viewModel: InfoBarViewModel<InfoBarContent>
    private var positionContstraint: NSLayoutConstraint!

    public override var prefersStatusBarHidden: Bool {
        return UIApplication.shared.windows.first?.rootViewController?.prefersStatusBarHidden ?? false
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIApplication.shared.windows.first?.rootViewController?.preferredStatusBarStyle ?? .default
    }

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
        positionContstraint = constraints.positionConstraint

        NSLayoutConstraint.activate(
            [constraints.positionConstraint] + constraints.otherConstraints
        )
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.async {
            self.showAlertView()
        }
    }

    public func showAlertView() {
        positionContstraint.constant = viewModel.positionConstrainConstant

        if UIAccessibility.isReduceMotionEnabled {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        } else {
            UIView.animate(
                withDuration: 1/3,
                delay: 0,
                options: .curveEaseOut
            ) {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
    }

    public func dismissView() {
        positionContstraint.constant = viewModel.notVisiblePositionConstraintConstant(from: frame)
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
