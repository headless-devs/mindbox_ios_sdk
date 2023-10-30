//
//  MBLoggerCoreDataManager.swift
//  MindboxLogger
//
//  Created by Akylbek Utekeshev on 06.02.2023.
//  Copyright © 2023 Mikhail Barilov. All rights reserved.
//

import CoreData
import UIKit

public class MBLoggerCoreDataManager {
    public static let shared = MBLoggerCoreDataManager()
    
    private enum Constants {
        static let model = "CDLogMessage"
        static let dbSizeLimitKB: Int = 10_00
        static let operationLimitBeforeNeedToDelete = 20
    }
    
    private var suspendedLogs: [LogMessage] = []
    private var writeCount = 0 {
        didSet {
            if writeCount > Constants.operationLimitBeforeNeedToDelete {
                writeCount = 0
            }
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        return createNewPersistentContainer()
    }()
    
    private lazy var context: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        return context
    }()
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc private func appDidEnterBackground() {
        if performAndWaitSemaphore.wait(timeout: .now()) == .success {
            // Освобождение persistentStore
            if let store = self.context.persistentStoreCoordinator?.persistentStores.first {
                do {
                    try self.context.persistentStoreCoordinator?.remove(store)
                } catch {
                    // Handle error, for example, log it
                }
            }
            performAndWaitSemaphore.signal()
        }
    }
    
    @objc private func appWillEnterForeground() {
        self.persistentContainer = createNewPersistentContainer()
        self.context = self.persistentContainer.newBackgroundContext()
//        flushTempLogBuffer()
        suspendedLogs.removeAll() // TODO: - remove this line later
    }
    
    private func flushTempLogBuffer() {
        for log in suspendedLogs {
            do {
                try create(message: log.message, timestamp: log.timestamp)
            } catch {
                
            }
        }
        suspendedLogs.removeAll()
    }
    
    private func createNewPersistentContainer() -> NSPersistentContainer {
        MBPersistentContainer.applicationGroupIdentifier = MBLoggerUtilitiesFetcher().applicationGroupIdentifier
        
        #if SWIFT_PACKAGE
        let bundleURL = Bundle.module.url(forResource: Constants.model, withExtension: "momd")
        let mom = NSManagedObjectModel(contentsOf: bundleURL!)
        let container = MBPersistentContainer(name: Constants.model, managedObjectModel: mom!)
        #else
        let podBundle = Bundle(for: MBLoggerCoreDataManager.self)
        let container: MBPersistentContainer
        if let url = podBundle.url(forResource: "MindboxLogger", withExtension: "bundle") {
            let bundle = Bundle(url: url)
            let modelURL = bundle?.url(forResource: Constants.model, withExtension: "momd")
            let mom = NSManagedObjectModel(contentsOf: modelURL!)
            container = MBPersistentContainer(name: Constants.model, managedObjectModel: mom!)
        } else {
            container = MBPersistentContainer(name: Constants.model)
        }
        #endif
        
        let storeURL = FileManager.storeURL(for: MBLoggerUtilitiesFetcher().applicationGroupIdentifier, databaseName: Constants.model)
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.setValue("DELETE" as NSObject, forPragmaNamed: "journal_mode")
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores {
            (storeDescription, error) in
        }

        return container
    }
    
    private let performAndWaitSemaphore = DispatchSemaphore(value: 1)
    
    public func create(message: String, timestamp: Date) throws {
        guard let _ = self.context.persistentStoreCoordinator?.persistentStores.first else {
            suspendedLogs.append(LogMessage(timestamp: timestamp, message: message))
            return
        }
        
        if !suspendedLogs.isEmpty {
            for i in suspendedLogs {
                try actualLog(message: i.message, timestamp: i.timestamp)
            }
            
            suspendedLogs.removeAll()
        }
        
        try actualLog(message: message, timestamp: timestamp)
    }
    
    private func actualLog(message: String, timestamp: Date) throws {
        performAndWaitSemaphore.wait()
        defer {
            performAndWaitSemaphore.signal()
        }
        let isTimeToDelete = writeCount == 0
        writeCount += 1
        if isTimeToDelete && getDBFileSize() > Constants.dbSizeLimitKB {
            try delete()
        }
        
        try self.context.customPerformAndWait {
            let entity = CDLogMessage(context: self.context)
            if let _ = self.context.persistentStoreCoordinator?.persistentStores.first {
                entity.message = message
                entity.timestamp = timestamp
                try self.context.save()
            } else {
                suspendedLogs.append(LogMessage(timestamp: timestamp, message: message))
            }
        }
    }
    
    public func getFirstLog() throws -> LogMessage? { 
        try context.customPerformAndWait {
            let fetchRequest = NSFetchRequest<CDLogMessage>(entityName: Constants.model)
            fetchRequest.predicate = NSPredicate(value: true)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
            fetchRequest.fetchLimit = 1
            let results = try context.fetch(fetchRequest)
            var logMessage: LogMessage?
            if let first = results.first {
                logMessage = LogMessage(timestamp: first.timestamp, message: first.message)
            }
            return logMessage
        }
    }

    public func getLastLog() throws -> LogMessage? {
        try context.customPerformAndWait {
            let fetchRequest = NSFetchRequest<CDLogMessage>(entityName: Constants.model)
            fetchRequest.predicate = NSPredicate(value: true)
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
            fetchRequest.fetchLimit = 1
            let results = try context.fetch(fetchRequest)
            var logMessage: LogMessage?
            if let last = results.last {
                logMessage = LogMessage(timestamp: last.timestamp, message: last.message)
            }
            return logMessage
        }
    }
    
    public func fetchPeriod(_ from: Date, _ to: Date) throws -> [LogMessage] {
        try context.customPerformAndWait {
            let fetchRequest = NSFetchRequest<CDLogMessage>(entityName: Constants.model)
            fetchRequest.predicate = NSPredicate(format: "timestamp >= %@ AND timestamp <= %@",
                                                 from as NSDate,
                                                 to as NSDate)
            let logs = try context.fetch(fetchRequest)
            var fetchedLogs: [LogMessage] = []
            logs.forEach {
                fetchedLogs.append(LogMessage(timestamp: $0.timestamp, message: $0.message))
            }
            return fetchedLogs
        }
    }
    
    public func delete() throws {
        try context.customPerformAndWait {
            guard let _ = self.context.persistentStoreCoordinator?.persistentStores.first else {
                return
            }
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.model)
            let count = try context.count(for: request)
            let limit: Double = (Double(count) * 0.1).rounded()
            request.fetchLimit = Int(limit)
            request.includesPropertyValues = false
            let results = try context.fetch(request)
            results.compactMap { $0 as? NSManagedObject }.forEach {
                context.delete($0)
            }
            try context.save()
        }
        
        Logger.common(message: "10%  logs has been deleted", level: .debug, category: .general)
    }
    
    public func deleteAll() throws {
        try context.customPerformAndWait {
            guard let _ = self.context.persistentStoreCoordinator?.persistentStores.first else {
                return
            }
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.model)
            request.includesPropertyValues = false
            let results = try context.fetch(request)
            results.compactMap { $0 as? NSManagedObject }.forEach {
                context.delete($0)
            }
            try context.save()
        }
    }
    
    private func getDBFileSize() -> Int {
        guard let url = context.persistentStoreCoordinator?.persistentStores.first?.url else {
            return 0
        }
        let size = url.fileSize / 1024
        return Int(size)
    }
}
