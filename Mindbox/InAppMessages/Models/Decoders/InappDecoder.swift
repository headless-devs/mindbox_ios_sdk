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
        let actionValidator = AnyValidatorBox(InappBackgroundLayerActionValidator())
        let layersValidator = AnyValidatorBox(VariantLayersValidator(actionValidator: actionValidator))
        let variantValidator = AnyValidatorBox(InappVariantValidator(layersValidator: layersValidator))
        let sdkValidator = AnyValidatorBox(SDKVersionValidator(sdkVersionNumeric: Constants.Versions.sdkVersionNumeric))
        let inAppValidator = InappValidator(
            sdkVersionValidator: sdkValidator,
            variantValidator: variantValidator
        )
        value = inAppValidator.validate(item: inApp)
    }
}
