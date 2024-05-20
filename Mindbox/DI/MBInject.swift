//
//  MBInject.swift
//  Mindbox
//
//  Created by vailence on 16.05.2024.
//  Copyright © 2024 Mindbox. All rights reserved.
//

import Foundation

protocol ModuleInjecting {
    func inject<Dependency>(_ serviceType: Dependency.Type) -> Dependency?
}

extension Container: ModuleInjecting {
    func inject<Dependency>(_ serviceType: Dependency.Type) -> Dependency? {
        return self.resolve(serviceType)
    }
}

enum MBInject {
    enum InjectionMode {
        case standard
        case stubbed
    }

    static var mode: InjectionMode = .standard {
        didSet {
            switch mode {
            case .standard:
                depContainer = MBInject.buildDefaultContainer()
            case .stubbed:
                depContainer = MBInject.stubContainer
            }
        }
    }

    static var depContainer: Container = MBInject.buildDefaultContainer()

    fileprivate static func buildDefaultContainer() -> Container {
        let container = Container()
        return container
            .registerUtilitiesServices()
    }

    fileprivate static var stubContainer: Container {
        let container = MBInject.buildDefaultContainer()
        return container
            .registerStubUtilitiesServices()
    }
}

var container: Container {
    return MBInject.depContainer
}
