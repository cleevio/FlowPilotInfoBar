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
    let view: T

    public init(
        viewModel: InfoBarViewModel<InfoBarContent>,
        viewBuilder: InfoBarViewModelViewBuilder<T, InfoBarContent>
    ) {
        self.viewModel = viewModel
        self.view = viewBuilder(
            viewModel
        )
    }

    public var body: some View {
        content
    }

    @ViewBuilder
    public var content: some View {
        if #available(iOS 14.0, *) {
            if #available(iOS 16.0, *) {
                ViewThatFits(in: .vertical) {
                    view
                        .modifier(DragModifier(onDismiss: onDragDismiss))
                    ScrollView {
                        view
                    }
                    .modifier(DragModifier(onDismiss: onDragDismiss))
                }
            } else {
                view
                    .modifier(DragModifier(onDismiss: onDragDismiss))
            }
        } else {
            view
        }
    }

    func onDragDismiss() {
        DispatchQueue.main.async {
            viewModel.isMessageShown = false
        }
    }
}

@available(iOS 14.0, *)
struct DragModifier: ViewModifier {
    var onDismiss: () -> Void

    @State private var dragPopup = CGSize.zero
    @GestureState private var isDragGestureActive: Bool = false
    @State private var isDraggingActive: Bool = false

    func body(content: Content) -> some View {
        content
            .offset(y: dragPopup.height)
            .gesture(
                DragGesture(minimumDistance: 8) // Set minimum distance, so small drags are ignored
                    .onChanged { value in
                        isDraggingActive = true
                        withPreferredAnimation(.linear) {
                            let height: CGFloat = if value.translation.height < 9 {
                                value.translation.height
                            } else {
                               3*sqrt(value.translation.height)
                            }
                            dragPopup = .init(width: 0, height: height)
                        }
                    }
                    // Workaround: onEnded is not called
                    // When some animation in the content view starts (like dragging slider),
                    // `.onChange` can be called, but `.onEnded` is not called and the gesture is "cancelled" not "ended"
                    // https://forums.developer.apple.com/forums/thread/660070
                    .updating($isDragGestureActive) { _, state, _ in
                        state = true
                    }
                    .onEnded { _ in
                        isDraggingActive = false
                    }
            )
            .onChange(of: isDragGestureActive) { isDragging in
                isDraggingActive = isDragging
            }
            .onChange(of: isDraggingActive) { isDragging in
                guard !isDragging else { return }
                withPreferredAnimation(.linear) {
                    if dragPopup.height < -40 {
                        onDismiss()
                    } else {
                        dragPopup = .zero
                    }
                }
            }
    }
}

@discardableResult
@MainActor
public func withPreferredAnimation<Result>(_ animation: Animation? = .default, _ body: () throws -> Result) rethrows -> Result {
    if UIAccessibility.isReduceMotionEnabled {
        return try body()
    } else {
        return try withAnimation(animation, body)
    }
}
