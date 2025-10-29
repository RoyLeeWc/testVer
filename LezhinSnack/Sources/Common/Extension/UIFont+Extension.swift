//
//  UIFont.swift
//  Bomtoon_Renewal
//
//  Created by 신진우 on 3/3/25.
//

import UIKit
import SwiftyUserDefaults

extension UIFont {
    static func spoqaHanSansNeoRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "SpoqaHanSansNeo-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static func spoqaHanSansNeoMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "SpoqaHanSansNeo-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    public static func pretendardMedium(size: CGFloat) -> UIFont {
        switch Defaults.currentSetLanguageCode {
        case LanguageCode.english:
            return UIFont(name: "Pretendard-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
        case LanguageCode.korean:
            return UIFont(name: "Pretendard-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
        case LanguageCode.japanese:
            return UIFont(name: "PretendardJP-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
        case LanguageCode.simplifiedChinese :
            return UIFont(name: "NotoSansSC-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
        default:
            return UIFont(name: "Pretendard-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }
    
    static func pretendardRegular(size: CGFloat) -> UIFont {
        switch Defaults.currentSetLanguageCode {
        case LanguageCode.english:
            return UIFont(name: "Pretendard-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        case LanguageCode.korean:
            return UIFont(name: "Pretendard-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        case LanguageCode.japanese:
            return UIFont(name: "PretendardJP-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        case LanguageCode.simplifiedChinese :
            return UIFont(name: "NotoSansSC-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        default:
            return UIFont(name: "Pretendard-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
        }
        
    }
    
    static func pretendardBold(size: CGFloat) -> UIFont {
        switch Defaults.currentSetLanguageCode {
        case LanguageCode.english:
            return UIFont(name: "Pretendard-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
        case LanguageCode.korean:
            return UIFont(name: "Pretendard-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
        case LanguageCode.japanese:
            return UIFont(name: "PretendardJP-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
        case LanguageCode.simplifiedChinese :
            return UIFont(name: "NotoSansSC-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
        default:
            return UIFont(name: "Pretendard-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
        }
        
    }
    
    static func pretendardSemiBold(size: CGFloat) -> UIFont {
        switch Defaults.currentSetLanguageCode {
        case LanguageCode.english:
            return UIFont(name: "Pretendard-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size)
        case LanguageCode.korean:
            return UIFont(name: "Pretendard-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size)
        case LanguageCode.japanese:
            return UIFont(name: "PretendardJP-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size)
        case LanguageCode.simplifiedChinese :
            return UIFont(name: "NotoSansSC-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size)
        default:
            return UIFont(name: "Pretendard-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }
    
    
//    static func spoqaHanSansNeoBold(size: CGFloat) -> UIFont {
//        return UIFont(name: "SpoqaHanSansNeo-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
//    }
    
    
}
