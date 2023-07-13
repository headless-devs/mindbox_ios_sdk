//
//  InappViewFactory.swift
//  Mindbox
//
//  Created by vailence on 12.07.2023.
//  Copyright © 2023 Mindbox. All rights reserved.
//

import UIKit
import Foundation

protocol InappViewFactory {
    func create(inAppUIModel: InAppMessageUIModel,
                onPresented: @escaping () -> Void,
                onTapAction: @escaping () -> Void,
                onClose: @escaping () -> Void) -> UIViewController
}
