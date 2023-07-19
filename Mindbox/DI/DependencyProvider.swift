//
//  DIManager.swift
//  Mindbox
//
//  Created by Mikhail Barilov on 13.01.2021.
//  Copyright © 2021 Mindbox. All rights reserved.
//

import CoreData
import Foundation
import UIKit

final class DependencyProvider: DependencyContainer {
    let utilitiesFetcher: UtilitiesFetcher
    let persistenceStorage: PersistenceStorage
    let databaseLoader: DataBaseLoader
    let databaseRepository: MBDatabaseRepository
    let guaranteedDeliveryManager: GuaranteedDeliveryManager
    let authorizationStatusProvider: UNAuthorizationStatusProviding
    let sessionManager: SessionManager
    let instanceFactory: InstanceFactory
    let inAppTargetingChecker: InAppTargetingChecker
    let inAppMessagesManager: InAppCoreManagerProtocol
    let uuidDebugService: UUIDDebugService
    var sessionTemporaryStorage: SessionTemporaryStorage
    var inappMessageEventSender: InappMessageEventSender
    let sdkVersionValidator: SDKVersionValidator
    let geoService: GeoServiceProtocol
    let segmentationSevice: SegmentationServiceProtocol
    var imageDownloadService: ImageDownloadServiceProtocol
    var abTestDeviceMixer: ABTestDeviceMixer

    init() throws {
        utilitiesFetcher = MBUtilitiesFetcher()
        inAppTargetingChecker = InAppTargetingChecker()
        persistenceStorage = MBPersistenceStorage(defaults: UserDefaults(suiteName: utilitiesFetcher.applicationGroupIdentifier)!)
        databaseLoader = try DataBaseLoader(applicationGroupIdentifier: utilitiesFetcher.applicationGroupIdentifier)
        let persistentContainer = try databaseLoader.loadPersistentContainer()
        databaseRepository = try MBDatabaseRepository(persistentContainer: persistentContainer)
        instanceFactory = MBInstanceFactory(
            persistenceStorage: persistenceStorage,
            utilitiesFetcher: utilitiesFetcher,
            databaseRepository: databaseRepository
        )
        guaranteedDeliveryManager = GuaranteedDeliveryManager(
            persistenceStorage: persistenceStorage,
            databaseRepository: databaseRepository,
            eventRepository: instanceFactory.makeEventRepository()
        )
        authorizationStatusProvider = UNAuthorizationStatusProvider()
        sessionManager = SessionManager(trackVisitManager: instanceFactory.makeTrackVisitManager())
        let logsManager = SDKLogsManager(persistenceStorage: persistenceStorage, eventRepository: instanceFactory.makeEventRepository())
        sessionTemporaryStorage = SessionTemporaryStorage()
        sdkVersionValidator = SDKVersionValidator(sdkVersionNumeric: Constants.Versions.sdkVersionNumeric)
        geoService = GeoService(fetcher: instanceFactory.makeNetworkFetcher(),
                                sessionTemporaryStorage: sessionTemporaryStorage,
                                targetingChecker: inAppTargetingChecker)
        segmentationSevice = SegmentationService(customerSegmentsAPI: .live,
                                                 sessionTemporaryStorage: sessionTemporaryStorage,
                                                 targetingChecker: inAppTargetingChecker)
        let imageDownloader = URLSessionImageDownloader(persistenceStorage: persistenceStorage)
        imageDownloadService = ImageDownloadService(imageDownloader: imageDownloader)
        abTestDeviceMixer = ABTestDeviceMixer()
        let tracker = InAppMessagesTracker(databaseRepository: databaseRepository)
        let displayUseCase = PresentationDisplayUseCase()
        let actionUseCase = PresentationActionUseCase(tracker: tracker)
        let presentationManager = InAppPresentationManager(displayUseCase: displayUseCase,
                                                           actionUseCase: actionUseCase)
        inAppMessagesManager = InAppCoreManager(
            configManager: InAppConfigurationManager(
                inAppConfigAPI: InAppConfigurationAPI(persistenceStorage: persistenceStorage),
                inAppConfigRepository: InAppConfigurationRepository(),
                inAppConfigurationMapper: InAppConfigutationMapper(geoService: geoService,
                                                                   segmentationService: segmentationSevice,
                                                                   customerSegmentsAPI: .live,
                                                                   targetingChecker: inAppTargetingChecker,
                                                                   sessionTemporaryStorage: sessionTemporaryStorage,
                                                                   persistenceStorage: persistenceStorage,
                                                                   sdkVersionValidator: sdkVersionValidator,
                                                                   imageDownloadService: imageDownloadService,
                                                                   abTestDeviceMixer: abTestDeviceMixer),
                logsManager: logsManager, sessionStorage: sessionTemporaryStorage),
            presentationManager: presentationManager,
            persistenceStorage: persistenceStorage,
            sessionStorage: sessionTemporaryStorage
        )
        inappMessageEventSender = InappMessageEventSender(inAppMessagesManager: inAppMessagesManager,
                                                          sessionStorage: sessionTemporaryStorage)

        uuidDebugService = PasteboardUUIDDebugService(
            notificationCenter: NotificationCenter.default,
            currentDateProvider: { return Date() },
            pasteboard: UIPasteboard.general
        )
    }
}

class MBInstanceFactory: InstanceFactory {
    private let persistenceStorage: PersistenceStorage
    private let utilitiesFetcher: UtilitiesFetcher
    private let databaseRepository: MBDatabaseRepository

    init(
        persistenceStorage: PersistenceStorage,
        utilitiesFetcher: UtilitiesFetcher,
        databaseRepository: MBDatabaseRepository
    ) {
        self.persistenceStorage = persistenceStorage
        self.utilitiesFetcher = utilitiesFetcher
        self.databaseRepository = databaseRepository
    }

    func makeNetworkFetcher() -> NetworkFetcher {
        return MBNetworkFetcher(
            utilitiesFetcher: utilitiesFetcher,
            persistenceStorage: persistenceStorage
        )
    }

    func makeEventRepository() -> EventRepository {
        return MBEventRepository(
            fetcher: makeNetworkFetcher(),
            persistenceStorage: persistenceStorage
        )
    }

    func makeTrackVisitManager() -> TrackVisitManager {
        return TrackVisitManager(databaseRepository: databaseRepository)
    }
}
