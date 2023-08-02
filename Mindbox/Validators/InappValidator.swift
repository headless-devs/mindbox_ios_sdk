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

    private let sdkVersionValidator: AnyValidator
    private let variantValidator: AnyValidator

    init(sdkVersionValidator: AnyValidatorBox<SDKVersionValidator.T>,
         variantValidator: AnyValidatorBox<InappVariantValidator.T>) {
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
    
    private let layersValidator: AnyValidator

    init(layersValidator: AnyValidatorBox<VariantLayersValidator.T>) {
        self.layersValidator = layersValidator
    }
    
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
        
        if item.content == nil && type == .snackbar {
            return nil
        }
        
        guard let background = item.content?.background else {
            return nil
        }
        
        guard let layers = background.layers, !layers.isEmpty else {
            return nil
        }
        
        let validVariants = layers.filter {
            self.layersValidator.isValid(item: $0)
        }

        guard !validVariants.isEmpty else {
            return nil
        }
        
        return InAppForm.Variant(type: type, content: Content(background: Background(layers: validVariants)))
    }
}

class VariantLayersValidator: Validator {
    typealias T = Background.Layer
    
    private let actionValidator: AnyValidator

    init(actionValidator: AnyValidatorBox<InappBackgroundLayerActionValidator.T>) {
        self.actionValidator = actionValidator
    }
    
    func isValid(item: Background.Layer) -> Bool {
        guard let type = item.type else {
            return false
        }
        
        if type == .unknown {
            return false
        }
        
        if item.action == nil && type == .image {
            return false
        }
        
        if !actionValidator.isValid(item: item.action) {
            return false
        }
        
        return true
    }
}

class InappBackgroundLayerActionValidator: ItemValidator {

    
    typealias T = Background.Layer.Action?
    
    func isValid(item: Background.Layer.Action?) -> Bool {
        validate(item: item) != nil
    }
    
    func validate(item: Background.Layer.Action?) -> Background.Layer.Action?? {
        guard let item = item else {
            return nil
        }
        
        if item.type == .unknown {
            return nil 
        }

        if item.type == .redirectUrl && (item.intentPayload == nil || item.value == nil) {
            return nil
        }
        
        return Background.Layer.Action(type: item.type, intentPayload: item.intentPayload, value: item.value)
    }
}
