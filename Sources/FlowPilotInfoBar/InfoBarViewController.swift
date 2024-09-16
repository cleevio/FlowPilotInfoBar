//
//  InfoBarViewController.swift
//
//
//  Created by Lukáš Valenta on 22.06.2023.
//

import Foundation
#if canImport(UIKit)
import CleevioUI
import UIKit
import SwiftUI

public final class InfoBarViewController<InfoBarView: View>: UIViewController {
    let serverErrorView: ClearBackgroundUIHostingController<InfoBarView>
    let frame: CGRect
    var onDismiss: (() -> Void)?

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    public init(view: InfoBarView,
         frame: CGRect) {
        self.frame = frame
        self.serverErrorView = .init(rootView: view)
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

        addChild(serverErrorView)
        view.addSubview(serverErrorView.view)

        serverErrorView.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            serverErrorView.view.topAnchor.constraint(equalTo: view.topAnchor),
            serverErrorView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            serverErrorView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            serverErrorView.view.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
    }
}
#endif
