//
//  Date+Extension.swift
//  LezhinSnack
//
//  Created by jinu0115 on 6/2/25.
//

import Foundation

extension Date {
    /// 리전 코드에 맞춰 GMT 오프셋을 적용해 "yyyy.MM.dd HH:mm:ss (GMT±H)" 형태로 반환
    /// - Parameter regionCode: "ko-KR", "zh-CN", "ja-JP", "en-US" 같은 리전 코드
    /// - Returns: 예시: "2025.03.15 12:34:56 (GMT+9)"
    func toStringWithGMT(regionCode: String) -> String {
        // 1) 리전 코드별로 TimeZone 매핑
        let timeZone: TimeZone = {
            switch regionCode {
            case LanguageCode.korean:
                return TimeZone(identifier: "Asia/Seoul")!
            case LanguageCode.simplifiedChinese:
                return TimeZone(identifier: "Asia/Shanghai")!
            case LanguageCode.japanese:
                return TimeZone(identifier: "Asia/Tokyo")!
            case LanguageCode.english:
                // 미국 표준시를 대표로 동부 표준시(EST/GMT-5)로 설정
                return TimeZone(identifier: "America/New_York")!
            default:
                // 그 외에는 기기 설정(TimeZone.current)을 사용
                return TimeZone(identifier:regionCode) ?? TimeZone.current
            }
        }()
        
        // 2) 날짜/시간 포맷터 설정
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // 숫자 형식 고정
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy.MM.dd HH:mm:ss"
        
        let datePart = formatter.string(from: self)  // "2025.03.15 12:34:56"
        
        // 3) GMT 오프셋 문자열 생성 (초→시간 단위)
        let seconds = timeZone.secondsFromGMT(for: self)
        let hoursOffset = seconds / 3600
        let sign = hoursOffset >= 0 ? "+" : "-"
        let hourValue = abs(hoursOffset)
        let gmtString = "GMT\(sign)\(hourValue)"
        
        return "\(datePart) (\(gmtString))"
    }
}
