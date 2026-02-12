//
//  MoyaLoggingPlugin.swift
//  SoBunSoBun
//
//  Created by 김태은 on 2/6/26.
//

import Foundation
import Moya
import OSLog

/// Moya 로그 플러그인
final class MoyaLoggingPlugin: PluginType {
    private let requestLogger = Logger(
        subsystem: "SoBunSoBun",
        category: "MoyaLoggingPlugin.Request"
    )
    
    private let responseLogger = Logger(
        subsystem: "SoBunSoBun",
        category: "MoyaLoggingPlugin.Response"
    )
    
    // Request를 보낼 때 호출
    func willSend(_ request: RequestType, target: TargetType) {
        guard let httpRequest = request.request else {
            requestLogger.critical("[오류] 유효하지 않은 요청")
            return
        }
        
        let url = httpRequest.description
        let method = httpRequest.httpMethod ?? "unknown method"
        
        var log: String = "[요청 시작]\n"
        log.append("\n")
        log.append("URL: \(url)\n")
        log.append("METHOD: \(method)\n")
        log.append("API: \(target)\n")
        
        if let headers = httpRequest.allHTTPHeaderFields, !headers.isEmpty {
            log.append("HEADER: \(headers)\n")
        }
        
        if let body = httpRequest.httpBody, let bodyString = String(bytes: body, encoding: .utf8) {
            if let json = try? JSONSerialization.jsonObject(with: body, options: .mutableContainers),
               let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                log.append("BODY: ")
                log.append(String(decoding: jsonData, as: UTF8.self))
                log.append("\n")
            } else {
                log.append("BODY: \(bodyString)\n")
            }
        }
        
        log.append("\n")
        log.append("[요청 종료]\n")
        
        requestLogger.debug("\(log)")
    }
    
    // Response가 왔을 때
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            onSuceed(response, target: target, isFromError: false)
        case let .failure(error):
            onFail(error, target: target)
        }
    }
    
    func onSuceed(_ response: Response, target: TargetType, isFromError: Bool) {
        let request = response.request
        let url = request?.url?.absoluteString ?? "nil"
        let statusCode = response.statusCode
        
        var log = "[통신 성공]\n"
        log.append("\n")
        log.append("URL: \(url)\n")
        log.append("STATUS CODE: \(statusCode)\n")
        log.append("API: \(target)\n")
        
        // 2xx로 시작하지 않은 status code만 response 내용을 표시
        if !(200...299).contains(statusCode) {
            response.response?.allHeaderFields.forEach {
                log.append("\($0): \($1)\n")
            }
            
            log.append("RESPONSE:\n")
            if let reString = String(bytes: response.data, encoding: .utf8) {
                if let json = try? JSONSerialization.jsonObject(with: response.data, options: .mutableContainers),
                   let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                    log.append(String(decoding: jsonData, as: UTF8.self))
                } else {
                    log.append(reString)
                }
            }
            log.append("\n")
        }
        
        log.append("\n")
        log.append("\(response.data.count) BYTES\n")
        log.append("\n")
        log.append("[통신 종료]\n")
        
        if (200...299).contains(statusCode) {
            responseLogger.debug("\(log)")
        } else {
            responseLogger.critical("\(log)")
        }
    }
    
    func onFail(_ error: MoyaError, target: TargetType) {
        if let response = error.response {
            onSuceed(response, target: target, isFromError: true)
            return
        }
        
        var log = "[통신 오류]\n"
        log.append("\n")
        log.append("\(error.errorCode) \(target)\n")
        log.append("\(error.failureReason ?? error.errorDescription ?? "unknown error")\n")
        log.append("\n")
        log.append("[통신 종료]\n")
        
        responseLogger.critical("\(log)")
    }
}
