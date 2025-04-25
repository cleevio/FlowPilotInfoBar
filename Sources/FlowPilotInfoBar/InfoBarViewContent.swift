//
//  InfoBarViewContent.swift
//
//
//  Created by Lukáš Valenta on 22.06.2023.
//

import Foundation
import SwiftUI

/// A type alias for a closure that builds a SwiftUI view for an info bar
/// 
/// This typealias is used to create a closure that generates the content view for an info bar
/// 
/// Example:
/// ```swift
/// let viewBuilder: InfoBarViewModelViewBuilder<Text, String> = {
///     Text(viewModel.content)
///         .foregroundColor(.white)
///         .padding()
///         .background(Color.blue)
/// }
/// ```
public typealias InfoBarViewModelViewBuilder<InfoBarView: View, InfoBarContent> = () -> (InfoBarView)
