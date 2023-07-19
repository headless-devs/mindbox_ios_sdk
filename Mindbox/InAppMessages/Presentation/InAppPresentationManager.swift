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

enum ViewPresentationType {
    case modal
    case topSnackbar
    case bottomSnackbar
}

typealias InAppMessageTapAction = (_ tapLink: URL?, _ payload: String) -> Void

final class InAppPresentationManager: InAppPresentationManagerProtocol {

    init(
        displayUseCase: PresentationDisplayUseCase,
        actionUseCase: PresentationActionUseCase
    ) {
        self.displayUseCase = displayUseCase
        self.actionUseCase = actionUseCase
    }

    private let displayUseCase: PresentationDisplayUseCase
    private let actionUseCase: PresentationActionUseCase

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
            
            self?.displayUseCase.changeType(type: .modal)
            self?.displayUseCase.presentInAppUIModel(
                inAppUIModel: inAppUIModel,
                onPresented: onPresented,
                onTapAction: { [weak self] in
                    self?.actionUseCase.onTapAction(
                        inApp: inAppUIModel,
                        onTap: onTapAction,
                        close: {
                            self?.displayUseCase.dismissInAppUIModel(onClose: onPresentationCompleted)
                        })
                },
                onClose: {
                    self?.displayUseCase.dismissInAppUIModel(onClose: onPresentationCompleted)
                }
            )
        }
    }
}
