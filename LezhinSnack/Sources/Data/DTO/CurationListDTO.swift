//
//  CurationListDTO.swift
//  LezhinSnack
//
//  Created by lwc on 9/10/25.
//



struct CurationListDTO: Decodable {
    let responseCode: String
    let data: [CurationItemDTO]
    let errorData: ErrorDataDTO?
}

struct CurationItemDTO: Decodable {
    let id: String
    let title: String
    let layoutType: String?
    let mappingType: String?
    let settingInfo: String?
    let userDataType: String?
    let userDataSummeryPeriod: String?
    let curationPersonalType: String?
}
