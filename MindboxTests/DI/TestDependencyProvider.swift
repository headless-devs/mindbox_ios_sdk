//
//  DITest.swift
//  MindboxTests
//
//  Created by Mikhail Barilov on 28.01.2021.
//  Copyright © 2021 Mindbox. All rights reserved.
//


import XCTest
@testable import Mindbox

final class TestDependencyProvider: DependencyContainer {
    var inAppTargetingChecker: InAppTargetingChecker
    let inAppMessagesManager: InAppCoreManagerProtocol
    let utilitiesFetcher: UtilitiesFetcher
    let persistenceStorage: PersistenceStorage
    let databaseLoader: DataBaseLoader
    let databaseRepository: MBDatabaseRepository
    let guaranteedDeliveryManager: GuaranteedDeliveryManager
    let authorizationStatusProvider: UNAuthorizationStatusProviding
    let sessionManager: SessionManager
    let instanceFactory: InstanceFactory
    let uuidDebugService: UUIDDebugService
    let sessionTemporaryStorage: SessionTemporaryStorage
    var inappMessageEventSender: InappMessageEventSender
    var geoService: GeoService
    var customerAbMixer: CustomerAbMixer
    var imageDownloaderService: ImageDownloadServiceProtocol
    var segmentationService: SegmentationService
    
    init() throws {
        sessionTemporaryStorage = SessionTemporaryStorage()
        utilitiesFetcher = MBUtilitiesFetcher()
        persistenceStorage = MockPersistenceStorage()
        databaseLoader = try DataBaseLoader()
        inAppTargetingChecker = InAppTargetingChecker()
        let persistentContainer = try databaseLoader.loadPersistentContainer()
        databaseRepository = try MockDatabaseRepository(persistentContainer: persistentContainer)
        instanceFactory = MockInstanceFactory(
            persistenceStorage: persistenceStorage,
            utilitiesFetcher: utilitiesFetcher,
            databaseRepository: databaseRepository
        )
        guaranteedDeliveryManager = GuaranteedDeliveryManager(
            persistenceStorage: persistenceStorage,
            databaseRepository: databaseRepository,
            eventRepository: instanceFactory.makeEventRepository()
        )
        authorizationStatusProvider = MockUNAuthorizationStatusProvider(status: .authorized)
        sessionManager = SessionManager(trackVisitManager: instanceFactory.makeTrackVisitManager())
        inAppTargetingChecker = InAppTargetingChecker()
        inAppMessagesManager = InAppCoreManagerMock()
        uuidDebugService = MockUUIDDebugService()
        inappMessageEventSender = InappMessageEventSender(inAppMessagesManager: inAppMessagesManager,
                                                          sessionStorage: sessionTemporaryStorage)
        geoService = GeoService(fetcher: instanceFactory.makeNetworkFetcher(),
                                sessionTemporaryStorage: sessionTemporaryStorage,
                                targetingChecker: inAppTargetingChecker)
        customerAbMixer = CustomerAbMixer()
        let mockDownloader = MockImageDownloader()
        mockDownloader.expectedLocalURL = URL(fileURLWithPath: "/path/to/image.jpg")
        mockDownloader.expectedResponse = HTTPURLResponse(url: URL(string: "https://example.com/image.jpg")!, statusCode: 200, httpVersion: nil, headerFields: nil)
        imageDownloaderService = MockImageDownloadService(imageDownloader: mockDownloader)
        segmentationService = SegmentationService(customerSegmentsAPI: .live,
                                                  sessionTemporaryStorage: sessionTemporaryStorage,
                                                  targetingChecker: inAppTargetingChecker)
    }
}

class MockInstanceFactory: InstanceFactory {
    
    private let persistenceStorage: PersistenceStorage
    private let utilitiesFetcher: UtilitiesFetcher
    private let databaseRepository: MBDatabaseRepository
    
    var isFailureNetworkFetcher: Bool = false

    init(persistenceStorage: PersistenceStorage, utilitiesFetcher: UtilitiesFetcher, databaseRepository: MBDatabaseRepository) {
        self.persistenceStorage = persistenceStorage
        self.utilitiesFetcher = utilitiesFetcher
        self.databaseRepository = databaseRepository
    }

    func makeNetworkFetcher() -> NetworkFetcher {
        return isFailureNetworkFetcher ? MockFailureNetworkFetcher() : MockNetworkFetcher()
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

