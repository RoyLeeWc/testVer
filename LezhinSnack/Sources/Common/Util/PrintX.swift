//
//  PrintX.swift
//  BalconyShortForm
//
//  Created by jinu0115 on 3/5/25.
//

import Foundation

/// Print문 재 정의
/// - Parameters:
///   - items: 출력시 사용될 내용
///   - separator: 여러 아이템일 경우 아이템 사이사이 넣을 값
///   - terminator: ...
///   - file: 해당파일이름
///   - line: 해당파일의 라인수
///   - function: 해당파일의 호출된 함수
public func printX(_ items: Any...,
                   isBoxMode: Bool = false,
                   separator: String = " ",
                   terminator: String = "\n",
                   file: String = #file,
                   line: Int = #line,
                   function: String = #function) {
    let output = items.map { "\($0)" }.joined(separator: separator)
    
    #if DEBUG
    // 파일 이름 추출
    let fileName = URL(fileURLWithPath: file).lastPathComponent
    
    // 날짜 포맷터 설정
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "ko_KR")
    //dateFormatter.dateFormat = "yyyy-MM-dd a hh:mm:ss.SSS"
    dateFormatter.dateFormat = "a hh:mm:ss"
    let dateString = dateFormatter.string(from: Date())
    
    // 가독성을 높인 출력 메시지 (박스 형태 사용)
    var printString = ""
    
    if isBoxMode {
        printString = """
        ┌──────────────────────────────────────────────────────────────────────────────────────────────
        │ ⏰ 시간  : \(dateString)
        │ 📄 파일  : \(fileName)
        │ 🔢 라인  : \(line)
        │ ⚙️ 함수  : \(function)
        ├──────────────────────────────────────────────────────────────────────────────────────────────
        │ 📄 출력  : \(output)
        └──────────────────────────────────────────────────────────────────────────────────────────────
        """
    } else {
        printString = "[\(dateString)] [\(fileName):\(line)] [\(function)] 📄 → \(output)"
    }
    Swift.print(printString, terminator: terminator)
    #else
    // 릴리즈 모드에서는 출력하지 않음
    
    //Swift.print(output, terminator: terminator)
    #endif
}
