//
//  SnackbarViewFactory.swift
//  Mindbox
//
//  Created by vailence on 12.07.2023.
//

import Foundation
import UIKit

class BottomSnackbarViewFactory: InappViewFactory {
    
    var viewController: UIViewController?
    
    func create(inAppUIModel: InAppMessageUIModel, onPresented: @escaping () -> Void, onTapAction: @escaping () -> Void, onClose: @escaping () -> Void) -> UIViewController {
        let viewController = SnackbarViewController(with: inAppUIModel,
                                                    type: .bottom,
                                                    onPresented: onPresented,
                                                    onTapAction: onTapAction,
                                                    onClose: onClose)
        self.viewController = viewController
        return viewController
    }
}

class TopSnackbarViewFactory: InappViewFactory {
    
    var viewController: UIViewController?
    
    func create(inAppUIModel: InAppMessageUIModel, onPresented: @escaping () -> Void, onTapAction: @escaping () -> Void, onClose: @escaping () -> Void) -> UIViewController {
        let viewController = SnackbarViewController(with: inAppUIModel,
                                                    type: .top,
                                                    onPresented: onPresented,
                                                    onTapAction: onTapAction,
                                                    onClose: onClose)
        self.viewController = viewController
        return viewController
    }
}
