//
//  Double+Extension.swift
//  LezhinSnack
//
//  Created by 신진우 on 5/31/25.
//


extension Double {
    /// 소수점 이하가 0이면 정수 문자열을, 그렇지 않으면 소수점 이하를 유지한 문자열을 반환
    var cleanString: String {
        // 소수점 이하가 0인지 확인
        if self.truncatingRemainder(dividingBy: 1) == 0 {
            // 예: 5000.0 → "5000"
            return String(format: "%.0f", self)
        } else {
            // 예: 4999.5 → "4999.5"
            return String(self)
        }
    }
}
