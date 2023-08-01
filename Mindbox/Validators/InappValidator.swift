//
//  InappValidator.swift
//  Mindbox
//
//  Created by vailence on 01.08.2023.
//  Copyright © 2023 Mindbox. All rights reserved.
//

import Foundation

class InappValidator: Validator {
    
    typealias T = InApp
    
    private let sdkVersionValidator: SDKVersionValidator
    
    init(sdkVersionValidator: SDKVersionValidator) {
        self.sdkVersionValidator = sdkVersionValidator
    }
    
    func isValid(item: InApp) -> Bool {        
        if item.id.isEmpty {
            return false
        }
        
        if !sdkVersionValidator.isValid(item: item.sdkVersion) {
            return false
        }
        
        if item.form.variants.isEmpty {
            return false
        }
        
        return true
    }
}
