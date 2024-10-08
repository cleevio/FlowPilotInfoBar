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
open class InfoBarCoordinator<InfoBarView: View, InfoBarContent>: ResponseRouterCoordinator<Void> {
    let frame: CGRect
    let content: InfoBarContent
    let viewModel: InfoBarViewModel<InfoBarContent>
    let viewBuilder: InfoBarViewModelViewBuilder<InfoBarView, InfoBarContent>
    let cancelBag = CancelBag()

    public init?(on window: UIWindow,
                 content: InfoBarContent,
                 viewModel: InfoBarViewModel<InfoBarContent>,
                 viewBuilder: @escaping InfoBarViewModelViewBuilder<InfoBarView, InfoBarContent>) {
        guard let (router, frame, topPadding) = window.alertWindowRouter() else {
            return nil
        }

        self.viewBuilder = viewBuilder
        self.viewModel = viewModel
        self.content = content

        viewModel.topPadding = topPadding + 32
        self.frame = frame
        super.init(router: router)
    }

    open override func start(animated: Bool = true) {
        let view = viewBuilder(viewModel)

        let viewController = InfoBarViewController(
            view: view,
            frame: frame
        )

        viewModel.$isMessageShown
            .dropFirst()
            .filter { !$0 }
            .delay(for: 0.1, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.response(with: ())
                self?.dismiss()
            })
            .store(in: cancelBag)

        present(viewController, animated: animated)
    }
}
#endif
