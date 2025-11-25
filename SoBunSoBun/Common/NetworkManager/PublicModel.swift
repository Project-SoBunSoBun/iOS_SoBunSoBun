//
//  PublicModel.swift
//  SoBunSoBun
//
//  Created by 김태은 on 11/21/25.
//

import Foundation

struct GeocoderRequestModel: Encodable {
    let service: String = "address"
    let request: String = "getAddress"
    let version: String = "2.0"
    let crs: String = "epsg:4326"
    let point: String
    let format: String = "json"
    let errorformat: String = "json"
    let type: String = "parcel"
    let zipcode: Bool = false
    let simple: Bool = true
    let key: String
}

struct GeocoderResponseModel: Decodable {
    let response: GeocoderResponseInsideModel
}

struct GeocoderResponseInsideModel: Decodable {
    let result: [GeocoderResponseResultModel]
}

struct GeocoderResponseResultModel: Decodable {
    let text: String
    let structure: GeocoderResponseResultStructureModel
}

struct GeocoderResponseResultStructureModel: Decodable {
    let level1: String
    let level2: String
    let level3: String
}
