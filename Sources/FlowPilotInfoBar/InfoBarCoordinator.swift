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
/// A coordinator that manages the lifecycle of an info bar in the application flow
/// 
/// This coordinator integrates with FlowPilot to handle the presentation and dismissal
/// of info bars within the application's navigation flow
/// 
/// Example:
/// ```swift
/// let viewModel = InfoBarViewModel(content: "Alert message")
/// 
/// let coordinator = try InfoBarCoordinator(
///     on: window,
///     viewModel: viewModel
/// ) {
///     InfoBarView(viewModel: viewModel) {
///         Text("Alert message")
///             .padding()
///             .background(Color.blue)
///     }
/// }
/// 
/// navigator.navigate(to: coordinator)
/// ```
open class InfoBarCoordinator<InfoBarView: View, InfoBarContent>: ResponseRouterCoordinator<Void> {
    /// The frame in which the info bar will be displayed
    let frame: CGRect
    
    /// The view model that controls the info bar's state
    let viewModel: InfoBarViewModel<InfoBarContent>
    
    /// A closure that builds the SwiftUI view to display in the info bar
    let viewBuilder: () -> InfoBarView
    
    /// A cancel bag to store subscriptions
    private let cancelBag = CancelBag()

    /// Initializes a new info bar coordinator
    /// - Parameters:
    ///   - window: The window on which to display the info bar
    ///   - viewModel: The view model that controls the info bar's state
    ///   - viewBuilder: A closure that returns the view to display in the info bar
    /// - Throws: `AlertWindowRouterCouldNotBeConstructed` if the window scene is not available
    public init(
        on window: UIWindow,
        viewModel: InfoBarViewModel<InfoBarContent>,
        @ViewBuilder viewBuilder: @escaping () -> InfoBarView
    ) throws {
        let (router, frame, positionConstraintConstant) = try window.alertWindowRouter(calculatedPositionConstraintConstant: viewModel.calculatedPositionConstraintConstant(window:))

        self.viewBuilder = viewBuilder
        self.viewModel = viewModel

        viewModel.positionConstraintConstant = positionConstraintConstant
        self.frame = frame
        super.init(router: router)
    }

    /// Starts the coordinator, creating and presenting the info bar view controller
    /// - Parameter animated: Whether to animate the presentation
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
