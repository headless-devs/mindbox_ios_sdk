//
//  TTLValidationService.swift
//  Mindbox
//
//  Created by vailence on 29.03.2024.
//  Copyright © 2024 Mindbox. All rights reserved.
//

import Foundation
import MindboxLogger

protocol TTLValidationProtocol {
    func needResetInapps(config: ConfigResponse) -> Bool
}

class TTLValidationService: TTLValidationProtocol {
    
    let persistenceStorage: PersistenceStorage
    
    init(persistenceStorage: PersistenceStorage) {
        self.persistenceStorage = persistenceStorage
    }
    
    func needResetInapps(config: ConfigResponse) -> Bool {
        guard let configDownloadDate = persistenceStorage.configDownloadDate else {
            Logger.common(message: "[TTL] Config download date is nil. Unable to proceed with inapps reset validation.")
            return false
        }
        
        let now = Date()
        
        guard let ttl = config.settings?.ttl?.inapps,
              let downloadConfigDateWithTTL = getDateWithIntervalByType(ttl: ttl, date: configDownloadDate) else {
            Logger.common(message: "[TTL] Variables are missing or corrupted. Inapps reset will not be performed.")
            return false
        }
        
        let calendar = Calendar.current
        let nowComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        let ttlComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: downloadConfigDateWithTTL)
        
        guard let nowWithoutMilliseconds = calendar.date(from: nowComponents),
              let downloadConfigDateWithTTLWithoutMilliseconds = calendar.date(from: ttlComponents) else {
            Logger.common(message: "[TTL] Error in date components. Inapps reset will not be performed.")
            return false
        }

        let message = """
        [TTL] Current date: \(nowWithoutMilliseconds.asDateTimeWithSeconds).
        Config with TTL valid until: \(downloadConfigDateWithTTLWithoutMilliseconds.asDateTimeWithSeconds).
        Need to reset inapps: \(nowWithoutMilliseconds > downloadConfigDateWithTTLWithoutMilliseconds).
        """
        
        Logger.common(message: message)
        return nowWithoutMilliseconds > downloadConfigDateWithTTLWithoutMilliseconds
    }
    
    private func getDateWithIntervalByType(ttl: Settings.TimeToLive.TTLUnit, date: Date) -> Date? {
        guard let type = ttl.unit, let value = ttl.value else {
            Logger.common(message: "[TTL] Unable to calculate the date with TTL. The unit or value is missing.")
            return nil
        }
        
        let calendar = Calendar.current
        switch type {
            case .seconds:
                return calendar.date(byAdding: .second, value: value, to: date)
            case .minutes:
                return calendar.date(byAdding: .minute, value: value, to: date)
            case .hours:
                return calendar.date(byAdding: .hour, value: value, to: date)
            case .days:
                return calendar.date(byAdding: .day, value: value, to: date)
        }
    }
}

extension String {
    func parseTimeSpanToMillis() throws -> Int64 {
        let regex = try NSRegularExpression(pattern: "^(-)?((\\d+)\\.)?(\\d{1,2}):(\\d{1,2}):(\\d{1,2})(\\.(\\d{1,7}))?$")
        let matches = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
        
        guard let match = matches.first else {
            throw NSError(domain: "Invalid timeSpan format", code: 0, userInfo: nil)
        }
        
        let signRange = Range(match.range(at: 1), in: self)
        let daysRange = Range(match.range(at: 3), in: self)
        let hoursRange = Range(match.range(at: 4), in: self)
        let minutesRange = Range(match.range(at: 5), in: self)
        let secondsRange = Range(match.range(at: 6), in: self)
        let fractionRange = Range(match.range(at: 8), in: self)
        
        let sign = signRange != nil ? String(self[signRange!]) : ""
        let days = daysRange != nil ? String(self[daysRange!]) : "0"
        let hours = hoursRange != nil ? String(self[hoursRange!]) : "0"
        let minutes = minutesRange != nil ? String(self[minutesRange!]) : "0"
        let seconds = secondsRange != nil ? String(self[secondsRange!]) : "0"
        let fraction = fractionRange != nil ? String(self[fractionRange!]) : "0"
        
        print("sign: \(sign), days: \(days), hours: \(hours), minutes: \(minutes), seconds: \(seconds), fraction: \(fraction)")
        
        let daysCorrected = days.isEmpty ? "0" : days
        let fractionCorrected = fraction.isEmpty ? "0" : fraction
        
        let daysInSeconds = NSDecimalNumber(string: daysCorrected).multiplying(by: 86_400)
        let hoursInSeconds = NSDecimalNumber(string: hours).multiplying(by: 3600)
        let minutesInSeconds = NSDecimalNumber(string: minutes).multiplying(by: 60)
        let secondsInSeconds = NSDecimalNumber(string: seconds)
        let fractionInSeconds = NSDecimalNumber(string: "0.\(fractionCorrected)")
        
        let totalSeconds = daysInSeconds
            .adding(hoursInSeconds)
            .adding(minutesInSeconds)
            .adding(secondsInSeconds)
            .adding(fractionInSeconds)
        let totalMilliseconds = totalSeconds.multiplying(by: 1000)
        
        let roundedMilliseconds = totalMilliseconds.rounding(accordingToBehavior: .none)
        
        guard roundedMilliseconds.compare(NSDecimalNumber(value: Int64.max)) != .orderedDescending else {
            throw NSError(domain: "Invalid timeSpan format", code: 1, userInfo: nil)
        }
        
        let millis = roundedMilliseconds.int64Value
        
        return sign == "-" ? -millis : millis
    }
}
