//
//  MigrationManager.swift
//  Mindbox
//
//  Created by Sergei Semko on 7/26/24.
//  Copyright © 2024 Mindbox. All rights reserved.
//

import Foundation
import MindboxLogger

fileprivate protocol MigrationProtocol {
    var description: String { get set }
    var run: () -> () { get set }
    
    func isNeeded(persistenceStorage: PersistenceStorage) -> Bool
}

extension MigrationProtocol {
    func isNeeded(persistenceStorage: PersistenceStorage) -> Bool {
        return persistenceStorage.sdkVersionCodeForMigrations! < MigrationConstants.sdkVersionCode
    }
}

fileprivate class Migration: MigrationProtocol {
    
    var description: String
    
    var run: () -> ()
    
    init(description: String, run: @escaping () -> Void) {
        self.description = description
        self.run = run
    }
}

fileprivate enum MigrationConstants {
    static var sdkVersionCode = 1
}







protocol MigrationManagerProtocol {
    func migrateAll()
}

class MigrationManager: MigrationManagerProtocol {
    
    private let migrations: [MigrationProtocol] = []
    private var persistenceStorage: PersistenceStorage
    
    init(persistenceStorage: PersistenceStorage) {
        self.persistenceStorage = persistenceStorage
    }
    
    func migrateAll() {
        migrations.filter { $0.isNeeded(persistenceStorage: persistenceStorage) }.forEach { migration in
            Logger.common(message: "Run migration \(migration.description)")
            migration.run()
            self.persistenceStorage.sdkVersionCodeForMigrations! += 1
        }
        
        if persistenceStorage.sdkVersionCodeForMigrations != MigrationConstants.sdkVersionCode {
            Logger.common(message: "Migrations failed, reset memory")
            persistenceStorage.reset()
            persistenceStorage.sdkVersionCodeForMigrations = MigrationConstants.sdkVersionCode
        }
    }
}

// MARK: - Migrations
private extension MigrationManager {
    private func version1_2() -> MigrationProtocol {
        let closure: () -> () = {
            // self.persistenceStorage.sdkVersionCode! += 1
            // Some code
            print("Hello world")
        }
        return Migration(description: "Some description", run: closure)
    }
}
