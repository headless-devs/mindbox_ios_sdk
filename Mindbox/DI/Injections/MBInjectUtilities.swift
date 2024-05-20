//
//  MBInjectUtilities.swift
//  Mindbox
//
//  Created by vailence on 16.05.2024.
//  Copyright © 2024 Mindbox. All rights reserved.
//

import Foundation

extension Container {
    func registerUtilitiesServices() -> Self {
        register(UtilitiesFetcher.self) {
            MBUtilitiesFetcher()
        }
        
        register(PersistenceStorage.self) {
            let uf = self.resolveOrFail(UtilitiesFetcher.self)
            return MBPersistenceStorage(defaults: UserDefaults(suiteName: uf.applicationGroupIdentifier)!)
        }
        
        register(InappFrequencyValidator.self) {
            InappFrequencyValidator()
        }
        
        register(ABTestDeviceMixer.self) {
            ABTestDeviceMixer()
        }
        
        register(TimerManager.self, factory: {
            TimerManager()
        }, isSingleton: true)
        
        return self
    }
    
    func registerStubUtilitiesServices() -> Self {
        register(ABTestDeviceMixer.self) {
            StubABTestDeviceMixer()
        }
        return self
    }
}

