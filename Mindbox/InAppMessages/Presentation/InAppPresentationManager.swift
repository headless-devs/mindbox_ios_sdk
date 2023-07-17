//
//  InAppPresentationManager.swift
//  Mindbox
//
//  Created by Максим Казаков on 06.09.2022.
//  Copyright © 2022 Mikhail Barilov. All rights reserved.
//

import Foundation
import UIKit
import MindboxLogger

struct InAppMessageUIModel {
    struct InAppRedirect {
        let redirectUrl: String
        let payload: String
    }
    let inAppId: String
    let image: UIImage
    let redirect: InAppRedirect
}

protocol InAppPresentationManagerProtocol: AnyObject {
    func present(
        inAppFormData: InAppFormData,
        onPresented: @escaping () -> Void,
        onTapAction: @escaping InAppMessageTapAction,
        onPresentationCompleted: @escaping () -> Void,
        onError: @escaping (InAppPresentationError) -> Void
    )
}

enum InAppPresentationError {
    case failedToLoadImages
    case failedToLoadWindow
}

enum InAppPresentationType {
    case modal
    case topSnackbar
    case bottomSnackbar
}

typealias InAppMessageTapAction = (_ tapLink: URL?, _ payload: String) -> Void

final class InAppPresentationManager: InAppPresentationManagerProtocol {

    init(
        displayUseCase: InAppDisplayUseCase,
        actionUseCase: InAppActionUseCase
    ) {
        self.displayUseCase = displayUseCase
        self.actionUseCase = actionUseCase
    }

    private let displayUseCase: InAppDisplayUseCase
    private let actionUseCase: InAppActionUseCase

    func present(
        inAppFormData: InAppFormData,
        onPresented: @escaping () -> Void,
        onTapAction: @escaping InAppMessageTapAction,
        onPresentationCompleted: @escaping () -> Void,
        onError: @escaping (InAppPresentationError) -> Void
    ) {
        DispatchQueue.main.async { [weak self] in
            let redirectInfo = InAppMessageUIModel.InAppRedirect(
                redirectUrl: inAppFormData.redirectUrl,
                payload: inAppFormData.intentPayload
            )

            let inAppUIModel = InAppMessageUIModel(
                inAppId: inAppFormData.inAppId,
                image: inAppFormData.image,
                redirect: redirectInfo
            )
            
            self?.displayUseCase.changeType(type: .bottomSnackbar)
            self?.displayUseCase.presentInAppUIModel(
                inAppUIModel: inAppUIModel,
                onPresented: onPresented,
                onTapAction: { [weak self] in
                    self?.actionUseCase.onTapAction(
                        inApp: inAppUIModel,
                        onTap: onTapAction,
                        close: { self?.displayUseCase.dismissInAppUIModel(inAppUIModel: inAppUIModel, onClose: onPresentationCompleted) }
                    )
                },
                onClose: {
                    self?.displayUseCase.dismissInAppUIModel(inAppUIModel: inAppUIModel, onClose: onPresentationCompleted)
                }
            )
        }
    }
}

protocol InAppPresentationStrategy {
    func getWindow() -> UIWindow?
    func present(inAppUIModel: InAppMessageUIModel, in window: UIWindow, using viewController: UIViewController)
    func dismiss(viewController: UIViewController)
}

final class ModalPresentationStrategy: InAppPresentationStrategy {
    var inappWindow: UIWindow?
    
    func getWindow() -> UIWindow? {
        return makeInAppMessageWindow()
    }
    
    func present(inAppUIModel: InAppMessageUIModel, in window: UIWindow, using viewController: UIViewController) {
        window.rootViewController = viewController
        window.isHidden = false
        Logger.common(message: "In-app with id \(inAppUIModel.inAppId) presented", level: .info, category: .inAppMessages)
    }

    func dismiss(viewController: UIViewController) {
        viewController.view.window?.isHidden = true
        viewController.view.window?.rootViewController = nil
        Logger.common(message: "InApp presentation dismissed", level: .debug, category: .inAppMessages)
    }
    
    private func makeInAppMessageWindow() -> UIWindow? {
        let window: UIWindow?
        if #available(iOS 13.0, *) {
            window = iOS13PlusWindow
        } else {
            window = UIWindow(frame: UIScreen.main.bounds)
        }
        self.inappWindow = window
        window?.windowLevel = UIWindow.Level.normal
        window?.isHidden = false
        return window
    }

    @available(iOS 13.0, *)
    private var foregroundedScene: UIWindowScene? {
        for connectedScene in UIApplication.shared.connectedScenes {
            if let windowScene = connectedScene as? UIWindowScene, connectedScene.activationState == .foregroundActive {
                return windowScene
            }
        }
    
        return nil
    }

    @available(iOS 13.0, *)
    private var iOS13PlusWindow: UIWindow? {
        if let foregroundedScene = foregroundedScene {
            return UIWindow(windowScene: foregroundedScene)
        } else {
            return UIWindow(frame: UIScreen.main.bounds)
        }
    }
}

final class SnackbarPresentationStrategy: InAppPresentationStrategy {
    private var type: InAppPresentationType = .bottomSnackbar
    init(type: InAppPresentationType) {
        self.type = type
    }
    
    func getWindow() -> UIWindow? {
        return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
    }
    
    func present(inAppUIModel: InAppMessageUIModel, in window: UIWindow, using viewController: UIViewController) {
        window.rootViewController?.addChild(viewController)
        window.rootViewController?.view.addSubview(viewController.view)
        Logger.common(message: "In-app with id \(inAppUIModel.inAppId) presented", level: .info, category: .inAppMessages)
    }

    func dismiss(viewController: UIViewController) {
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
        Logger.common(message: "InApp presentation dismissed", level: .debug, category: .inAppMessages)
    }
}

final class InAppDisplayUseCase {

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

final class InAppActionUseCase {

    private let tracker: InAppMessagesTrackerProtocol

    init(tracker: InAppMessagesTrackerProtocol) {
        self.tracker = tracker
    }

    private var clickTracked = false
    
    func onTapAction(
        inApp: InAppMessageUIModel,
        onTap: @escaping InAppMessageTapAction,
        close: @escaping () -> Void
    ) {
        Logger.common(message: "InApp presentation completed", level: .debug, category: .inAppMessages)
        if !clickTracked {
            do {
                try tracker.trackClick(id: inApp.inAppId)
                clickTracked = true
                Logger.common(message: "Track InApp.Click. Id \(inApp.inAppId)", level: .info, category: .notification)
            } catch {
                Logger.common(message: "Track InApp.Click failed with error: \(error)", level: .error, category: .notification)
            }
        }

        let redirect = inApp.redirect
        
        if redirect.redirectUrl.isEmpty && redirect.payload.isEmpty {
            Logger.common(message: "Redirect URL and Payload are empty.", category: .inAppMessages)
        } else {
            let url = URL(string: redirect.redirectUrl)
            onTap(url, redirect.payload)
            close()
        }
    }
}
