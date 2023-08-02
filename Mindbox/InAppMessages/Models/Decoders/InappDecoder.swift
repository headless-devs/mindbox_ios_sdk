//
//  InappDecoder.swift
//  Mindbox
//
//  Created by vailence on 01.08.2023.
//  Copyright © 2023 Mindbox. All rights reserved.
//

import Foundation
import MindboxLogger

struct InAppDecoder: Decodable {
    var value: InApp?

    init(from decoder: Decoder) throws {
        let inApp = try InApp(from: decoder)
        let inAppValidator = InappValidator(
            sdkVersionValidator: SDKVersionValidator(sdkVersionNumeric: Constants.Versions.sdkVersionNumeric),
            variantValidator: InappVariantValidator()
        )
        value = inAppValidator.validate(item: inApp)
    }
}
