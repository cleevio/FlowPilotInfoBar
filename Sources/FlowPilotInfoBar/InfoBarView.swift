//
//  InfoBarView.swift
//
//
//  Created by Lukáš Valenta on 22.06.2023.
//

import Foundation
import SwiftUI

public struct InfoBarView<T: View, InfoBarContent>: View {
    @ObservedObject private var viewModel: InfoBarViewModel<InfoBarContent>
    let transition: AnyTransition
    let animation: Animation
    let view: T

    public init(viewModel: InfoBarViewModel<InfoBarContent>,
         viewBuilder: InfoBarViewModelViewBuilder<T, InfoBarContent>,
         transition: AnyTransition = .move(edge: .top),
         animation: Animation = .interactiveSpring(response: 0.5, dampingFraction: 0.8)) {
        self.transition = transition
        self.animation = animation
        self.viewModel = viewModel
        self.view = viewBuilder(viewModel)
    }

    public var body: some View {
        ZStack(alignment: .top) {
            Color.clear
                .allowsHitTesting(false)

            if viewModel.isMessageShown {
                view
                    .padding(.top, viewModel.topPadding)
                    .transition(transition)
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                viewModel.isMessageShown = true
            }
        }
        .animation(animation, value: viewModel.isMessageShown)
    }
}
