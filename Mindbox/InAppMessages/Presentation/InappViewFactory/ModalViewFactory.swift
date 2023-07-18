//
//  ModalViewFactory.swift
//  Mindbox
//
//  Created by vailence on 13.07.2023.
//  Copyright © 2023 Mindbox. All rights reserved.
//

import UIKit

class ModalViewFactory: InappViewFactory {

    var myViewController: UIViewController?
    
    func create(inAppUIModel: InAppMessageUIModel,
                onPresented: @escaping () -> Void,
                onTapAction: @escaping () -> Void,
                onClose: @escaping () -> Void) -> UIViewController {
        let viewController = ModalViewController(inAppUIModel: inAppUIModel,
                                                        onPresented: onPresented,
                                                        onTapAction: onTapAction,
                                                        onClose: onClose)
        myViewController = viewController
        return viewController
    }
}
