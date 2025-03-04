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

public final class InfoBarViewController<InfoBarView: View>: UIViewController {
    let serverErrorView: ClearBackgroundUIHostingController<InfoBarView>
    let frame: CGRect
    var onDismiss: (() -> Void)?
    private var topPadding: CGFloat
    private var topConstraint: NSLayoutConstraint!
    private var dismiss: AnyPublisher<Void, Never>
    private let cancelBag = CancelBag()

    public override var prefersStatusBarHidden: Bool {
        return UIApplication.shared.windows.first?.rootViewController?.prefersStatusBarHidden ?? false
    }

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIApplication.shared.windows.first?.rootViewController?.preferredStatusBarStyle ?? .default
    }

    public init(
        view: InfoBarView,
        frame: CGRect,
        topPadding: CGFloat,
        dismiss: AnyPublisher<Void, Never>
    ) {
        self.frame = frame
        self.topPadding = topPadding
        self.serverErrorView = .init(rootView: view)
        self.dismiss = dismiss
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
            serverErrorView.sizingOptions = .intrinsicContentSize
        }

        addChild(serverErrorView)
        view.addSubview(serverErrorView.view)

        serverErrorView.view.translatesAutoresizingMaskIntoConstraints = false
        topConstraint = serverErrorView.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -frame.height)

        NSLayoutConstraint.activate([
            topConstraint,
            serverErrorView.view.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
            serverErrorView.view.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            serverErrorView.view.heightAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.heightAnchor, constant: -topPadding)
        ])

        dismiss
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] in
                self?.dismissView()
            })
            .store(in: cancelBag)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.async {
            self.showAlertView()
        }
    }

    public func showAlertView() {
        topConstraint.constant = topPadding

        // **Animate Into Position Using Transform**
        UIView.animate(
            withDuration: 1/3,
            delay: 0,
            options: .curveEaseOut
        ) {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }

    public func dismissView() {
        topConstraint.constant = -frame.height
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
#endif
