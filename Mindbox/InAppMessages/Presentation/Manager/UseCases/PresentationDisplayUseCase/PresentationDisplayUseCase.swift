//
//  PresentationDisplayUseCase.swift
//  Mindbox
//
//  Created by vailence on 18.07.2023.
//  Copyright © 2023 Mindbox. All rights reserved.
//

import UIKit
import MindboxLogger

final class PresentationDisplayUseCase {

    private var presentationStrategy: InAppPresentationStrategy?
    private var presentedVC: UIViewController?
    private var viewFactory: InappViewFactory?

    func presentInAppUIModel(inAppUIModel: InAppMessageUIModel, onPresented: @escaping () -> Void, onTapAction: @escaping () -> Void, onClose: @escaping () -> Void) {
        guard let window = presentationStrategy?.getWindow() else {
            Logger.common(message: "InappWindow creating failed")
            return
        }
        
        let close: () -> Void = { [weak self] in
            self?.dismissInAppUIModel(inAppUIModel: inAppUIModel, onClose: onClose)
        }
        
        guard let viewController = viewFactory?.create(inAppUIModel: inAppUIModel, onPresented: onPresented, onTapAction: onTapAction, onClose: close) else {
            return
        }
        
        presentedVC = viewController
        presentationStrategy?.present(inAppUIModel: inAppUIModel, in: window, using: viewController)
    }

    func dismissInAppUIModel(inAppUIModel: InAppMessageUIModel, onClose: @escaping () -> Void) {
        guard let presentedVC = presentedVC else {
            return
        }
        presentationStrategy?.dismiss(viewController: presentedVC)
        onClose()
        self.presentedVC = nil
    }
    
    func changeType(type: InAppPresentationType) {
        switch type {
        case .modal:
            self.presentationStrategy = ModalPresentationStrategy()
            self.viewFactory = ModalViewFactory()
        case .topSnackbar:
            self.presentationStrategy = SnackbarPresentationStrategy(type: type)
            self.viewFactory = TopSnackbarViewFactory()
        case .bottomSnackbar:
            self.presentationStrategy = SnackbarPresentationStrategy(type: type)
            self.viewFactory = BottomSnackbarViewFactory()
        }
    }
}
