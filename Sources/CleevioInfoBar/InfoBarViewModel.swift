//
//  InfoBarViewModel.swift
//
//
//  Created by Lukáš Valenta on 22.06.2023.
//

import Foundation
import Combine

open class InfoBarViewModel<InfoBarContent>: ObservableObject {
    public let content: InfoBarContent
    @Published public var isMessageShown = false
    public var topPadding: CGFloat = 0

    public init(content: InfoBarContent,
         hideAfter seconds: TimeInterval = 2) {
        self.content = content

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(seconds))) {
            self.isMessageShown = false
        }
    }
}
