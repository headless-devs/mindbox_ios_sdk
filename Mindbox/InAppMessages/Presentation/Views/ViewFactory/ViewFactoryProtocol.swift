//
//  ViewFactoryProtocol.swift
//  Mindbox
//
//  Created by vailence on 18.07.2023.
//  Copyright © 2023 Mindbox. All rights reserved.
//

import UIKit
import Foundation

protocol ViewFactoryProtocol {
    func create(inAppUIModel: InAppMessageUIModel,
                onPresented: @escaping () -> Void,
                onTapAction: @escaping () -> Void,
                onClose: @escaping () -> Void) -> UIViewController
}
