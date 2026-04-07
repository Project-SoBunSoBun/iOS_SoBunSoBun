//
//  APIError.swift
//  SoBunHaeYo
//
//  Created by 김태은 on 4/5/26.
//

import Foundation
import OSLog
import RxSwift
import Moya
import RxMoya

// Moya 응답 코드
let RESPONSE_CODES: ValidationType = .customCodes(Array(200...299) + [400] + Array(402...499))

// API 에러 모델
struct APIErrorModel: Error {
    let message: String
    let errorCode: String?
}

// 에러 코드에 해당하는 다국어 오류 메시지 변환
func localizedErrorMessage(_ errorCode: String?) -> String {
    guard let errorCode else {
        return String(localized: "ErrorMessage", table: "Error")
    }
    
    let message = NSLocalizedString(errorCode, tableName: "Error", comment: "")
    let fallback = String(format: String(localized: "ErrorMessageWithCode", table: "Error"), errorCode)
    
    return message != errorCode ? message : fallback
}

// Moya tryMap Extension
extension PrimitiveSequence where Trait == SingleTrait, Element == Response {
    /// HTTP 에러를 APIErrorModel로 변환하고, Decode 실패 시 Data 로그를 추가로 출력합니다.
    func tryMap<T: Decodable>(_ type: T.Type) -> Single<T> {
        let logger = Logger(
            subsystem: "SoBunHaeYo",
            category: "MoyaNetworkManager.tryMap"
        )
        
        return flatMap { response in
            // HTTP 에러 상태 코드인 경우 APIErrorModel로 변환
            guard (200..<300).contains(response.statusCode) else {
                if let errorModel = try? response.map(PlainResponseModel.self),
                   let message = errorModel.message {
                    throw APIErrorModel(message: message, errorCode: errorModel.errorCode)
                }
                
                throw MoyaError.statusCode(response)
            }
            
            do {
                return .just(try response.map(type))
            } catch {
                if let json = try? JSONSerialization.jsonObject(with: response.data),
                   let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                   let str = String(data: pretty, encoding: .utf8) {
                    logger.critical("[Decode 오류]\n\ntype: \(type)\nresponse: \(str)")
                } else {
                    logger.critical("[Decode 오류]\n\ntype: \(type)\nresponse(raw): \(String(data: response.data, encoding: .utf8) ?? "String 변환 실패")")
                }
                
                throw error
            }
        }
    }
}
