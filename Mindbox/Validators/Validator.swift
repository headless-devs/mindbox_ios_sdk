//
//  Validator.swift
//  Mindbox
//
//  Created by vailence on 15.06.2023.
//  Copyright © 2023 Mindbox. All rights reserved.
//

import Foundation

protocol Validator {
    associatedtype T
    func isValid(item: T) -> Bool
}

protocol ItemValidator: Validator {
    func validate(item: T) -> T?
}

protocol AnyValidator {
    func isValid(item: Any) -> Bool
}

struct AnyValidatorBox<T>: AnyValidator {
    private let _isValid: (T) -> Bool

    init<ValidatorType: Validator>(_ validator: ValidatorType) where ValidatorType.T == T {
        self._isValid = validator.isValid
    }

    func isValid(item: Any) -> Bool {
        guard let item = item as? T else {
            return false
        }
        return _isValid(item)
    }
}
