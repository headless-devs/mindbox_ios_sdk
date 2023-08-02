//
//  InappValidator.swift
//  Mindbox
//
//  Created by vailence on 01.08.2023.
//  Copyright © 2023 Mindbox. All rights reserved.
//

import Foundation

class InappValidator: ItemValidator {
    typealias T = InApp

    private let sdkVersionValidator: SDKVersionValidator
    private let variantValidator: InappVariantValidator

    init(sdkVersionValidator: SDKVersionValidator,
         variantValidator: InappVariantValidator) {
        self.sdkVersionValidator = sdkVersionValidator
        self.variantValidator = variantValidator
    }

    func isValid(item: InApp) -> Bool {
        validate(item: item) != nil
    }

    func validate(item: InApp) -> InApp? {
        guard let id = item.id, !id.isEmpty else {
            return nil
        }
        
        if !sdkVersionValidator.isValid(item: item.sdkVersion) {
            return nil
        }
        
        if item.targeting == nil {
            return nil
        }
        
        guard let form = item.form,
              let variants = form.variants else {
            return nil
        }

        let validVariants = variants.filter {
            self.variantValidator.isValid(item: $0)
        }

        guard !validVariants.isEmpty else {
            return nil
        }
        
        return InApp(
            id: item.id,
            sdkVersion: item.sdkVersion,
            targeting: item.targeting,
            form: InAppForm(variants: validVariants)
        )
    }
}

class InappVariantValidator: ItemValidator {
    typealias T = InAppForm.Variant?
    
    func isValid(item: InAppForm.Variant?) -> Bool {
        validate(item: item) != nil
    }
    
    func validate(item: InAppForm.Variant?) -> InAppForm.Variant?? {
        guard let item = item else {
            return nil
        }
        
        guard let type = item.type else {
            return nil
        }
        
        if type == .unknown {
            return nil
        }
        
        guard let content = item.content else {
            return nil
        }
        
        guard let background = content.background else {
            return nil
        }
        
        guard let layers = background.layers, !layers.isEmpty else {
            return nil
        }
        
        let variantLayersValidator = VariantLayersValidator()
        let validVariants = layers.filter {
            variantLayersValidator.isValid(item: $0)
        }

        guard !validVariants.isEmpty else {
            return nil
        }
        
        return InAppForm.Variant(type: type, content: Content(background: Background(layers: validVariants)))
    }
}

class VariantLayersValidator: Validator {
    typealias T = Background.Layer
    
    func isValid(item: Background.Layer) -> Bool {
        guard let type = item.type else {
            return false
        }
        
        if type == .unknown {
            return false
        }
        
        return true
    }
}
