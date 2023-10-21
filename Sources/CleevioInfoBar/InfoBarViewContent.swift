//
//  InfoBarViewContent.swift
//
//
//  Created by Lukáš Valenta on 22.06.2023.
//

import Foundation
import SwiftUI

public typealias InfoBarViewModelViewBuilder<InfoBarView: View, InfoBarContent> = ( InfoBarViewModel<InfoBarContent>) -> (InfoBarView)
