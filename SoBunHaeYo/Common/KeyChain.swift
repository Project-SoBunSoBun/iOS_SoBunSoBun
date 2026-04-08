//
//  KeyChain.swift
//  SoBunHaeYo
//
//  Created by 허성필 on 9/5/25.
//

import Foundation
import OSLog

final class KeyChain {
    private let logger = Logger(
        subsystem: "SoBunHaeYo",
        category: "KeyChain"
    )
    private let accessQueue = DispatchQueue(label: "SoBunHaeYo.KeyChain.Access")
    
    static let shared = KeyChain()
    
    private init() {}
    
    // keyChain 저장 - C
    func set(key: String, value: String) {
        accessQueue.sync {
            guard let valueData = value.data(using: .utf8) else {
                logger.critical("[KeyChain]\n\nvalue를 data형태로 변환 실패\n\nKEY: \(key)\nVALUE: \(value)")
                
                return
            }
            
            let query: CFDictionary = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: key
            ] as CFDictionary
            let attributesToUpdate: CFDictionary = [
                kSecValueData: valueData
            ] as CFDictionary
            
            let updateStatus = SecItemUpdate(query, attributesToUpdate)
            
            if updateStatus == errSecSuccess {
                logger.debug("[KeyChain]\n\n업데이트 성공\n\nKEY: \(key)\nVALUE: \(value)")
                
                return
            }
            
            let saveData: CFDictionary = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: key,
                kSecValueData: valueData
            ] as CFDictionary
            
            let addStatus = SecItemAdd(saveData, nil)
            
            if addStatus == errSecSuccess {
                logger.debug("[KeyChain]\n\n저장 성공\n\nKEY: \(key)\nVALUE: \(value)")
            } else {
                logger.fault("[KeyChain]\n\n저장 실패\n\nKEY: \(key)\nVALUE: \(value)\nSTATUS: \(addStatus)")
            }
        }
    }
    
    // keyChain 값 출력 - R
    func get(key: String) -> String? {
        accessQueue.sync {
            let savedData: CFDictionary = [kSecClass: kSecClassGenericPassword,
                                     kSecAttrService: key,
                                      kSecReturnData: true] as CFDictionary
            var searchWord: CFTypeRef? = nil
            let searchResult = SecItemCopyMatching(savedData, &searchWord)
            
            // 없으면 미출력
            if searchResult != errSecSuccess {
                return nil
            }
            
            guard let searchData = searchWord as? Data else { return nil }
            
            return String(data: searchData, encoding: .utf8)
        }
    }
    
    // keyChain 값 삭제 - D
    func remove(key: String) {
        accessQueue.sync {
            let savedData: CFDictionary = [kSecClass: kSecClassGenericPassword,
                                     kSecAttrService: key] as CFDictionary
            
            let status = SecItemDelete(savedData)
            
            if status == errSecSuccess {
                logger.debug("[KeyChain]\n\n삭제 성공\n\nKEY: \(key)")
            } else {
                logger.debug("[KeyChain]\n\n삭제 실패\n\nKEY: \(key)")
            }
        }
    }
}
