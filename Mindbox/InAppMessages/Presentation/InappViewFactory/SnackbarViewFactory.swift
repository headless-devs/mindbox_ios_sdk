//
//  SnackbarViewFactory.swift
//  Mindbox
//
//  Created by vailence on 12.07.2023.
//

import Foundation
import UIKit

class BottomSnackbarViewFactory: InAppPresentationFactoryProtocol {
    
    var viewController: UIViewController?
    
    func create(inAppUIModel: InAppMessageUIModel) -> UIViewController {
        let viewController = SnackbarViewController(with: inAppUIModel, type: .bottom)
        self.viewController = viewController
        return viewController
    }
}

class TopSnackbarViewFactory: InAppPresentationFactoryProtocol {
    var viewController: UIViewController?
    
    func create(inAppUIModel: InAppMessageUIModel) -> UIViewController {
        let viewController = SnackbarViewController(with: inAppUIModel, type: .top)
        self.viewController = viewController
        return viewController
    }
}
