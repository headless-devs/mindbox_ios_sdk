//
//  InappTTLTests.swift
//  MindboxTests
//
//  Created by vailence on 08.04.2024.
//  Copyright © 2024 Mindbox. All rights reserved.
//

import XCTest
@testable import Mindbox

class InappTTLTests: XCTestCase {
    var container: TestDependencyProvider!
    var persistenceStorage: PersistenceStorage!
    var service: TTLValidationProtocol!

    override func setUp() {
        super.setUp()
        container = try! TestDependencyProvider()
        persistenceStorage = container.persistenceStorage
        service = container.ttlValidationService
    }
    
    override func tearDown() {
        container = nil
        persistenceStorage = nil
        service = nil
        super.tearDown()
    }
    
    func testNeedResetInapps_WithTTL_Exceeds() throws {
        persistenceStorage.configDownloadDate = Calendar.current.date(byAdding: .hour, value: -2, to: Date())
        let service = TTLValidationService(persistenceStorage: persistenceStorage)
        let settings = Settings(operations: nil, ttl: .init(inapps: .init(unit: .hours, value: 1)))
        let config = ConfigResponse(settings: settings)
        let result = service.needResetInapps(config: config)
        XCTAssertTrue(result, "Inapps должны быть сброшены, так как время ttl истекло.")
    }
    
    func testNeedResetInapps_WithTTL_NotExceeded() throws {
        persistenceStorage.configDownloadDate = Calendar.current.date(byAdding: .second, value: -1, to: Date())
        let service = TTLValidationService(persistenceStorage: persistenceStorage)
        let settings = Settings(operations: nil, ttl: .init(inapps: .init(unit: .seconds, value: 1)))
        let config = ConfigResponse(settings: settings)
        let result = service.needResetInapps(config: config)
        XCTAssertFalse(result, "Inapps не должны быть сброшены, так как время ttl еще не истекло.")
    }
    
    func testNeedResetInapps_WithoutTTL() throws {
        persistenceStorage.configDownloadDate = Date()
        let service = TTLValidationService(persistenceStorage: persistenceStorage)
        let settings = Settings(operations: nil, ttl: nil)
        let config = ConfigResponse(settings: settings)
        let result = service.needResetInapps(config: config)
        XCTAssertFalse(result, "Inapps не должны быть сброшены, так как в конфиге отсутствует TTL.")
    }
    
    func testNeedResetInapps_ExactlyAtTTL_ShouldNotReset() throws {
        let service = TTLValidationService(persistenceStorage: persistenceStorage)
        let settings = Settings(operations: nil, ttl: .init(inapps: .init(unit: .seconds, value: 1)))
        let config = ConfigResponse(settings: settings)
        persistenceStorage.configDownloadDate = Calendar.current.date(byAdding: .second, value: -1, to: Date())
        let result = service.needResetInapps(config: config)
        XCTAssertFalse(result, "Inapps не должны сбрасываться, если текущее время точно совпадает с истечением TTL.")
    }
    
    func testNeedResetInapps_WithTTLHalfHourAgo_NotExceeded() throws {
        persistenceStorage.configDownloadDate = Calendar.current.date(byAdding: .minute, value: -30, to: Date())
        let service = TTLValidationService(persistenceStorage: persistenceStorage)
        let settings = Settings(operations: nil, ttl: .init(inapps: .init(unit: .hours, value: 1)))
        let config = ConfigResponse(settings: settings)
        let result = service.needResetInapps(config: config)
        XCTAssertFalse(result, "Inapps не должны быть сброшены, так как время TTL еще не истекло.")
    }
    
    
    func testParseTimeSpanTTLSuccess() {
        
//                    (str: "6:12:14:45", expectation: 562485000),
        let testPositiveCases: Array = [
            (str: "0:0:0.1234567", expectation: 123),
            (str: "0:0:0.1", expectation: 100),
            (str: "0:0:0.01", expectation: 10),
            (str: "0:0:0.001", expectation: 1),
            (str: "0:0:0.0001", expectation: 0),
            (str: "01.01:01:01.10", expectation: 90061100),
            (str: "1.1:1:1.1", expectation: 90061100),
            (str: "1.1:1:1", expectation: 90061000),
            (str: "99.23:59:59", expectation: 8639999000),
            (str: "999.23:59:59", expectation: 86399999000),
            (str: "6:12:14", expectation: 22334000),
            
            (str: "6.12:14:45", expectation: 562485000),

            (str: "1.00:00:00", expectation: 86400000),
            (str: "0.00:00:00.0", expectation: 0),
            (str: "00:00:00", expectation: 0),
            (str: "0:0:0", expectation: 0),
            (str: "-0:0:0", expectation: 0),
            (str: "-0:0:0.001", expectation: -1),
            (str: "-1.0:0:0", expectation: -86400000),
            
//            (str: "10675199.02:48:05.4775807", expectation: 922337203685477),
            (str: "10675199.02:48:05.4775807", expectation: 922337203685478),
            (str: "-10675199.02:48:05.4775808", expectation: -922337203685478)
        ]
        
        for (str, result) in testPositiveCases {
            XCTContext.runActivity(named: "string(\(str)) parse to \(String(describing: result))") { activity in
                do {
                    let milliseconds = try String(str).parseTimeSpanToMillis()
                    XCTAssertEqual(milliseconds, Int64(result))
                } catch {
                    XCTFail("Throw error \(error.localizedDescription) for \(str) but expected \(String(describing: result))")
                }
            }
        }
    }
    
    
    func testParseTTLStringFail() {
        let testNegativeCases: Array = [
            "6",
            "6:12",
            "1.6:12",
            "1.6:12.1",
            "6:12:14:45",
            "6:24:14:45",
            "6:99:14:45",
            "6:00:24:99",
            "6:00:99:45",
            "6:00:60:45",
            "6:00:44:60",
            "6:00:44:60",
            "6:99:99:99",
            "1:1:1:1:1",
            "qwe",
            "",
            "999999999:0:0",
            "0:0:0.12345678",
            ".0:0:0.1234567",
            "0:0:0.",
            "0:000:0",
            "00:000:00",
            "000:00:00",
            "00:00:000",
            "+0:0:0",
            "12345678901234567890.00:00:00.00",
        ]
        
        for str in testNegativeCases {
            XCTContext.runActivity(named: "Parsing \(str) should fail") { activity in
                do {
                    XCTAssertThrowsError(try str.parseTimeSpanToMillis()) { error in
                        XCTAssertEqual((error as NSError).domain, "Invalid timeSpan format")
                    }
                } catch {
                    
                }
                
            }
        }
    }
    
}
