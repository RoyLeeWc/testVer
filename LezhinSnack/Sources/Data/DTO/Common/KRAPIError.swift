//
//  APIErrorModel.swift
//  BalconyShortForm
//
//  Created by 신진우 on 3/8/25.
//


struct KRAPIError: Codable {
    let code: String?
    let message: String?
    let detail: String?
}
