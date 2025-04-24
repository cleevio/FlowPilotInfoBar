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
    let viewModel: InfoBarViewModel<InfoBarContent>
    let viewBuilder: () -> InfoBarView
    private let cancelBag = CancelBag()

    public init(
        on window: UIWindow,
        viewModel: InfoBarViewModel<InfoBarContent>,
        @ViewBuilder viewBuilder: @escaping () -> InfoBarView
    ) throws {
        let (router, frame, positionConstrainConstant) = try window.alertWindowRouter(calculatedPositionContraintConstant: viewModel.calculatedPositionContraintConstant(window:))

        self.viewBuilder = viewBuilder
        self.viewModel = viewModel

        viewModel.positionConstrainConstant = positionConstrainConstant
        self.frame = frame
        super.init(router: router)
    }

    open override func start(animated: Bool = true) {
        let view = viewBuilder()

        let viewController = InfoBarViewController(
            view: view,
            frame: frame,
            viewModel: viewModel
        )

        viewModel.$isMessageShown
            .dropFirst()
            .filter { !$0 }
            .first()
            .map { _ in }
            .sink(receiveValue: { [viewController] _ in
                viewController.dismissView()
            })
            .store(in: cancelBag)

        viewController.onDismiss = { [weak self] in
            self?.dismiss()
            self?.response(with: ())
        }

        present(viewController, animated: animated)
    }
}
#endif
