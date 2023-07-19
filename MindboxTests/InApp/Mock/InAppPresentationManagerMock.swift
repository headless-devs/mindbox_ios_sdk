//
//  InAppPresentationManagerMock.swift
//  MindboxTests
//
//  Created by Максим Казаков on 14.09.2022.
//  Copyright © 2022 Mikhail Barilov. All rights reserved.
//

import Foundation
@testable import Mindbox

class InAppPresentationManagerMock: InAppPresentationManagerProtocol {
    var receivedInAppUIModel: InAppFormData?
    var presentCallsCount = 0
    var receivedOnPresent: (() -> Void)?
    var receivedOnPresentationCompleted: (() -> Void)?
    var receivedOnError: ((InAppPresentationError?) -> Void)?

    func present(inAppFormData: InAppFormData,
                 onPresented: @escaping () -> Void,
                 onTapAction: @escaping InAppMessageTapAction,
                 onPresentationCompleted: @escaping () -> Void,
                 onError: @escaping (InAppPresentationError) -> Void) {
        presentCallsCount += 1
        receivedInAppUIModel = inAppFormData
        receivedOnPresent = onPresented
        receivedOnPresentationCompleted = onPresentationCompleted
    }
}
