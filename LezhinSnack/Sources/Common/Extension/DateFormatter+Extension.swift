//
//  DateFormatter+Extension.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/8/25.
//
import Foundation

extension DateFormatter {
    static let rfc1123: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss zzz"  // RFC1123 포맷
        return formatter
    }()
}
