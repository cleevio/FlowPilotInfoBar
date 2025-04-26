//
//  InfoBarView.swift
//
//
//  Created by Lukáš Valenta on 22.06.2023.
//

import Foundation
import SwiftUI

/// A SwiftUI view for displaying an info bar with various content types
/// 
/// The view provides drag-to-dismiss functionality and adapts to different iOS versions
/// 
/// Example:
/// ```swift
/// InfoBarView(viewModel: viewModel) {
///     HStack {
///         Image(systemName: "info.circle")
///         Text("Important notification")
///     }
///     .padding()
///     .background(Color.blue)
///     .foregroundColor(.white)
/// }
/// ```
public struct InfoBarView<T: View, InfoBarContent>: View {
    private var viewModel: InfoBarViewModel<InfoBarContent>
    let view: T

    /// Initializes a new info bar view with the given view model and content builder
    /// - Parameters:
    ///   - viewModel: The view model that controls the info bar's state
    ///   - viewBuilder: A closure that returns the view to display in the info bar
    public init(
        viewModel: InfoBarViewModel<InfoBarContent>,
        viewBuilder: InfoBarViewModelViewBuilder<T, InfoBarContent>
    ) {
        self.viewModel = viewModel
        self.view = viewBuilder()
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
/// A view modifier that adds drag-to-dismiss functionality
/// 
/// The modifier tracks drag gestures and animates the view accordingly,
/// dismissing it if dragged far enough in the negative y direction
struct DragModifier: ViewModifier {
    /// Closure called when the view should be dismissed due to dragging
    var onDismiss: () -> Void

    /// The current offset of the view due to dragging
    @State private var dragPopup = CGSize.zero
    
    /// Indicates whether a drag gesture is currently active
    @GestureState private var isDragGestureActive: Bool = false
    
    /// Indicates whether dragging is active (used to handle gesture cancellation)
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

/// Performs an action with animation, respecting accessibility settings for reduced motion
/// - Parameters:
///   - animation: The animation to use when reduced motion is not enabled
///   - body: The action to perform
/// - Returns: The result of the action
@discardableResult
@MainActor
public func withPreferredAnimation<Result>(_ animation: Animation? = .default, _ body: () throws -> Result) rethrows -> Result {
    if UIAccessibility.isReduceMotionEnabled {
        return try body()
    } else {
        return try withAnimation(animation, body)
    }
}
