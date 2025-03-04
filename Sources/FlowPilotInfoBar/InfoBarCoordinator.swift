//
//  InfoBarCoordinator.swift
//  
//
//  Created by Lukáš Valenta on 22.06.2023.
//

import Foundation
import FlowPilot
import SwiftUI
import CleevioCore

#if canImport(UIKit)

public let defaultInfoBarTopPadding: CalculatePaddingClosure = { window in
    let navigationController: UINavigationController? = window.topViewController?.navigationController ?? window.topViewController?.tabBarController.flatMap { $0.selectedViewController as? UINavigationController }

    if let navigationController, !navigationController.isNavigationBarHidden {
        return navigationController.navigationBar.frame.height + 8
    }

    return 8
}

public typealias CalculatePaddingClosure = (UIWindow) throws -> CGFloat
open class InfoBarCoordinator<InfoBarView: View, InfoBarContent>: ResponseRouterCoordinator<Void> {
    let frame: CGRect
    let content: InfoBarContent
    let viewModel: InfoBarViewModel<InfoBarContent>
    let viewBuilder: InfoBarViewModelViewBuilder<InfoBarView, InfoBarContent>

    public init(
        on window: UIWindow,
                 content: InfoBarContent,
                 viewModel: InfoBarViewModel<InfoBarContent>,
                 calculateTopPadding: CalculatePaddingClosure = defaultInfoBarTopPadding,
        viewBuilder: @escaping InfoBarViewModelViewBuilder<InfoBarView, InfoBarContent>
    ) throws {
        let (router, frame, topPadding) = try window.alertWindowRouter(topPadding: calculateTopPadding)

        self.viewBuilder = viewBuilder
        self.viewModel = viewModel
        self.content = content

        viewModel.topPadding = topPadding
        self.frame = frame
        super.init(router: router)
    }

    open override func start(animated: Bool = true) {
        let view = viewBuilder(viewModel)
        let dismissPublisher = viewModel.$isMessageShown
            .dropFirst()
            .filter { !$0 }
            .first()
            .map { _ in }
            .eraseToAnyPublisher()

        let viewController = InfoBarViewController(
            view: view,
            frame: frame,
            topPadding: viewModel.topPadding,
            dismiss: dismissPublisher
        )

        viewController.onDismiss = { [weak self] in
            self?.dismiss()
            self?.response(with: ())
        }

        present(viewController, animated: animated)
    }
}
#endif
